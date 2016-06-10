# Trinamo

[![Build Status](https://travis-ci.org/cignoir/trinamo.svg?branch=master)](https://travis-ci.org/cignoir/trinamo)
[![Coverage Status](https://coveralls.io/repos/github/cignoir/trinamo/badge.svg?branch=master)](https://coveralls.io/github/cignoir/trinamo?branch=master)

Trinamo generates HiveQL using YAML to mount tables of DynamoDB, S3 and local HDFS.

```
Notice:
This is experimental stuff! Do not use in production.
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'trinamo'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install trinamo

## Usage

## Table Definition
### Generate a template for DDL
* RUN:
```ruby
Trinamo::Converter.generate_ddl_template(out_file_path = 'ddl.yml')
```

* OUTPUT:
```yaml
tables:
  - name: comments
    s3_location: s3://path/to/s3/table/location
    s3_partition:
      - name: date
        type: string
    hash_key:
      - name: user_id
        type: bigint
    range_key:
      - name: comment_id
        type: bigint
    attributes:
      - name: title
        type: string
      - name: content
        type: string
      - name: rate
        type: double
  - name: authors
    hash_key:
      - name: author_id
        type: bigint
    attributes:
      - name: name
        type: string
```

### Generate a template for hive options
* RUN:
```ruby
Trinamo::Converter.generate_options_template(out_file_path = 'ddl.yml')
```

* OUTPUT:
```yaml
options:
  dynamodb.throughput.read.percent: 0.5
  hive.exec.compress.output: true
  io.seqfile.compression.type: BLOCK
  mapred.output.compression.codec: com.hadoop.compression.lzo.LzoCodec

```

Then, modify table-definitions and hive-settings as you like.

## Create DDLs in HiveQL
### For Options
* RUN:
```ruby
Trinamo::Converter.load('ddl.yml', :option).convert
```
or
```ruby
Trinamo::Converter.load_options('options.yml').convert
```

* OUTPUT:
```hql
SET dynamodb.throughput.read.percent = 0.5;
SET hive.exec.compress.output=true;
SET io.seqfile.compression.type=BLOCK;
SET mapred.output.compression.codec = com.hadoop.compression.lzo.LzoCodec;
```

### For DynamoDB

* RUN:
```ruby
Trinamo::Converter.load('ddl.yml', :dynamodb).convert
```

* OUTPUT:
```hql
-- comments_ddb
CREATE EXTERNAL TABLE comments_ddb (
  user_id BIGINT,comment_id BIGINT,title STRING,content STRING,rate DOUBLE
)
STORED BY 'org.apache.hadoop.hive.dynamodb.DynamoDBStorageHandler'
TBLPROPERTIES (
  'dynamodb.table.name' = 'comments',
  'dynamodb.column.mapping' = 'user_id:user_id,comment_id:comment_id,title:title,content:content,rate:rate'
);

-- authors_ddb
CREATE EXTERNAL TABLE authors_ddb (
  author_id BIGINT,name STRING
)
STORED BY 'org.apache.hadoop.hive.dynamodb.DynamoDBStorageHandler'
TBLPROPERTIES (
  'dynamodb.table.name' = 'authors',
  'dynamodb.column.mapping' = 'author_id:author_id,name:name'
);
```

### For S3
* RUN:
```ruby
Trinamo::Converter.load('ddl.yml', :s3).convert
```

* OUTPUT:
```hql
-- comments_s3
CREATE EXTERNAL TABLE comments_s3 (
  user_id BIGINT,comment_id BIGINT,title STRING,content STRING,rate DOUBLE
) PARTITIONED BY (date STRING)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n'
LOCATION 's3://path/to/s3/table/location';
```

### For HDFS
* RUN:
```ruby
Trinamo::Converter.load('ddl.yml', :hdfs).convert
```

* OUTPUT:
```hql
-- comments_hdfs
CREATE TABLE comments_hdfs (
  user_id BIGINT,comment_id BIGINT,title STRING,content STRING,rate DOUBLE
);

-- authors_hdfs
CREATE TABLE authors_hdfs (
  author_id BIGINT,name STRING
);
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/cignoir/trinamo.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

