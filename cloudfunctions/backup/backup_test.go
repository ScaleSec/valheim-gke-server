package backup

import (
	"context"
	"testing"

	"cloud.google.com/go/storage"
)

func initClient(t *testing.T) (bucket *storage.BucketHandle) {
	ctx := context.Background()
	client, err := storage.NewClient(ctx)
	if err != nil {
		t.Fatalf("error initializing client")
	}

	bucket = client.Bucket(bucketName)

	return bucket
}

func TestCheckObjectAge(t *testing.T) {
	bucket := initClient(t)

	err := checkObjectAge(bucket)
	if err != nil {
		t.Fatalf("error listing buckets client")
	}
}
