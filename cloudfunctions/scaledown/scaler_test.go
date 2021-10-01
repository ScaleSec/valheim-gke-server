package scaler

import (
	
	"context"
	"fmt"
	"testing"
)

var (
	ctx context.Context
)
func init() {
	ctx = context.Background()
}

func TestMetrics(t *testing.T) {
	cpu := getMetrics(ctx)
	fmt.Println(cpu)
}

func TestGetPod(t *testing.T) {
	fmt.Println(getPodAge(ctx))
}

// func TestScaler(t *testing.T) {
// 	Scaler(ctx, "")
// }