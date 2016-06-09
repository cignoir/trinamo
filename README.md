# Trinamo

Trinamo generates DDL for Hive from YAML
to mount tables of DynamoDB, S3 and local HDFS.

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

### Create a DDL template

* RUN:
```ruby
Trinamo::Converter.generate_template(out_file_path = 'ddl.yml')
```

* OUTPUT:
```yaml
dynamo_read_percent: 0.75
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

### Create a mapper for DynamoDB

* RUN:
```ruby
Trinamo::Converter.generate_ddl_ddb('ddl.yml')
```

* OUTPUT:
```hql
SET dynamodb.throughput.read.percent = 0.75;
SET hive.exec.compress.output=true;
SET io.seqfile.compression.type=BLOCK;
SET mapred.output.compression.codec = com.hadoop.compression.lzo.LzoCodec;

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

### Create a mapper for S3
* RUN:
```ruby
Trinamo::Converter.generate_ddl_s3('ddl.yml')
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

### Create a mapper for HDFS local
* RUN:
```ruby
Trinamo::Converter.generate_ddl_hdfs('ddl.yml')
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

