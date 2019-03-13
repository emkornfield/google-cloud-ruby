# Release History

### 1.9.0 / 2019-03-08

* Spanner Batch DML.
  * Add Transaction#batch_update.
  * Add BatchUpdate.
  * Add BatchUpdateError.
  * Add SpannerClient#execute_batch_dml.

### 1.8.0 / 2019-02-01

* Make use of Credentials#project_id
  * Use Credentials#project_id
    If a project_id is not provided, use the value on the Credentials object.
    This value was added in googleauth 0.7.0.
  * Loosen googleauth dependency
    Allow for new releases up to 0.10.
    The googleauth devs have committed to maintaining the current API
    and will not make backwards compatible changes before 0.10.
* Performance improvements for Data#to_h
  * Add Data skip_dup_check optional arg
    * This enhancement allows users to skip the dupplicate name check
      when serializing Data to a Ruby Hash or Array.
      This speeds up the serialization, but data may be lost.
* Update network configuration
* Update Client#close to block on session release

### 1.7.2 / 2018-11-15

* Allow Spanner streams to recover from more errors.

### 1.7.1 / 2018-10-08

* Add DML and Partitioned DML support
  * Add execute_update to process DML statements
  * Add execute_partition_update for Partitioned DML
* Rename execute_query method
  * Maintain naming consistency with execute_update method.
  * Maintain compatibility by adding query, execute and execute_sql aliases.

### 1.6.4 / 2018-09-20

* Update Spanner generated files.
  * Add DML/PDML code structures.
* Update documentation.
  * Change documentation URL to googleapis GitHub org.
* Fix circular require warning.

### 1.6.3 / 2018-09-12

* Add missing documentation files to package.

### 1.6.2 / 2018-09-10

* Update documentation.

### 1.6.1 / 2018-08-21

* Update documentation.

### 1.6.0 / 2018-06-28

* Add Session labels
  * Add labels optional argument to Project#client and #batch_client.
  * Add labels optional argument to Project#batch_client.
* Bug fix when an error is raised while returning results.

### 1.5.0 / 2018-06-12

* Support STRUCT values in query parameters.
  * Add `Fields#struct` to create a `Data` object.
* Documentation updates.

### 1.4.0 / 2018-03-26

* Add support for commit_timestamp.

### 1.3.1 / 2018-02-27

* Add Batch Client
  * Support partitioned reads and queries.
* Support Shared Configuration.
* Fix issue with IAM Policy not refreshing properly.
* Fix issue when using Time objects as keys.

### 1.2.0 / 2017-12-19

* Update Low Level API code
  * Remove deprecated constructor arguments.
  * Update documentation.
* Update google-gax dependency to 1.0.

### 1.1.1 / 2017-11-15

* Fix Admin Credentials (GAPIC) environment variable names.

### 1.1.0 / 2017-11-14

* Add `Google::Cloud::Spanner::Credentials` class.
* Rename constructor arguments to `project_id` and `credentials`.
  (The previous arguments `project` and `keyfile` are still supported.)
* Document `Google::Auth::Credentials` as `credentials` value.
* Update generated low level GAPIC code.
* Updated `google-gax` (`grpc`, `google-protobuf`), `googleauth` dependencies.

### 1.0.0 / 2017-09-29

* Release 1.0

### 0.23.2 / 2017-09-12

* Update connection configuration.

### 0.23.1 / 2017-08-18

* Update connection configuration.

### 0.23.0 / 2017-07-27

* Add `Job#error` returning `Spanner::Status`.

### 0.22.0 / 2017-07-11

* Remove `Policy#deep_dup`.
* Add thread pool size to `Session` pool configuration.
* Add error handling for some GRPC errors.
* Do not allow nested snapshots or transactions.
* Update initialization to raise a better error if project ID is not specified.
* Update GAPIC configuration to exclude `UNAVAILABLE` errors from automatic retry.
* Update example code in the API documentation and guide.

### 0.21.0 / 2017-06-08

Initial implementation of the Google Cloud Spanner API Ruby client.
