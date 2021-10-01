package backup

import (
	"context"
	"fmt"

	"io/ioutil"

	"os"
	"time"

	log "github.com/sirupsen/logrus"

	"cloud.google.com/go/storage"
	"google.golang.org/api/iterator"
)

var (
	bucketName, bucketNamePresent = os.LookupEnv("BUCKET_NAME")
	// secondary bucket for DR
	bucketNameDr, drBucketPresent = os.LookupEnv("BUCKET_NAME_DR")
	backupName, backupNamePresent = os.LookupEnv("BACKUP_FILE_NAME")
	t                             = time.Now()
)

// get objects in bucket and checks if older than 7
func checkObjectAge(bucket *storage.BucketHandle) error {
	// create a timeout
	ctx, cancel := context.WithTimeout(context.Background(), time.Second*10)
	defer cancel()

	iter := bucket.Objects(ctx, nil)

	for {
		attrs, err := iter.Next()

		if err == iterator.Done {
			break
		}

		if err != nil {
			return fmt.Errorf("%v", err)
		}

		createdStamp := attrs.Created
		objectName := attrs.Name

		// if the object is 7 days old, delete
		if t.After(createdStamp.Add(168 * time.Hour)) {
			fmt.Printf("%s is over 7 days old\n", objectName)
			if err = deleteObject(ctx, bucket, objectName); err != nil {
				return err
			}
		}
	}

	return nil
}

// deletes an object
func deleteObject(ctx context.Context, bucket *storage.BucketHandle, objectName string) error {

	// just in case
	if objectName == "scaleheim.zip" {
		fmt.Println("Skipping scaleheim.zip, refusing to delete")
	}

	fmt.Printf("Deleting %s\n", objectName)

	obj := bucket.Object(objectName)
	if err := obj.Delete(ctx); err != nil {
		return err
	}

	return nil
}

// read the backup zip from gcs into an object
func readObject(ctx context.Context, bucket *storage.BucketHandle) (data []byte) {
	obj := bucket.Object(fmt.Sprintf("%s.zip", backupName))
	reader, err := obj.NewReader(ctx)

	if err != nil {
		log.Fatal("Could not read backup zip file from bucket")
	}

	data, err = ioutil.ReadAll(reader)
	reader.Close()

	if err != nil {
		log.Fatal("Failed to read the bucket data with ioutil")
	}

	return data
}

// write the object to a copy in the bucket
func writeObject(ctx context.Context, bucket *storage.BucketHandle, date string, data []byte, bucketOutput string) {
	// make a new object name
	obj := bucket.Object(fmt.Sprintf("%s-%s.zip", backupName, date))

	// make a writer
	log.Println("Creating new writer")
	w := obj.NewWriter(ctx)

	// write the data into new object. This is asynchronous so error may not be known until close
	log.Printf("Writing file to %s", bucketOutput)
	if _, err := w.Write(data); err != nil {
		log.Error("Failed to write data to new object. Probably exists already")
	}

	err := w.Close()
	if err != nil {
		log.Error("Failed to write data to new object. Probably exists already")
	}
	
	log.Info("Finished writing")
}

// Main runs  the logic
func Backup(ctx context.Context, e interface{}) error {
	// check that vars are present
	if !backupNamePresent {
		log.Fatal("BACKUP_FILE_NAME is unset")
	}

	if !bucketNamePresent {
		log.Fatal("BUCKET_NAME is unset")
	}

	// init the client
	client, err := storage.NewClient(ctx)
	defer client.Close()
	if err != nil {
		log.Fatal("Could not initialize storage client")
	}

	// init bucket objects
	bucket := client.Bucket(bucketName)
	bucketDr := client.Bucket(bucketNameDr)

	log.Info("Starting backup")

	// get the current date
	date := t.Format("01-02-2006")
	log.Infof("Date is %s\n", date)

	// get the data to write
	log.Info("Reading main backup file")
	data := readObject(ctx, bucket)

	// write daily backup file
	log.Info("Writing daily backup")
	writeObject(ctx, bucket, date, data, bucketName)

	if drBucketPresent {
		log.Println("Backing up to secondary bucket")
		// write a copy to a DR bucket
		writeObject(ctx, bucketDr, date, data, bucketNameDr)
	}

	// delete objects older than 7 days
	log.Info("Checking object ages")
	err = checkObjectAge(bucket)
	if err != nil {
		log.Error(err)
	}

	return err
}
