# Configure BiocParallel to use serial processing globally for all tests
# This prevents "package:stats may not be available when loading" warnings
# that occur with parallel processing in test environments

if (requireNamespace("BiocParallel", quietly = TRUE)) {
  # Register SerialParam as the default backend
  BiocParallel::register(BiocParallel::SerialParam())
  message("BiocParallel configured for serial processing (no multithreading)")
}
