# CloudStorage

Very simple wrapper for cloud storages (gcs, s3), methods:

- list files
- download file
- file exist?
- upload file
- signed url
- delete file

## Installation

Add to your Gemfile:

```ruby
gem 'cloud_storage'
```

Gcs wrapper requires [google-cloud-storage](https://github.com/googleapis/google-cloud-ruby/tree/master/google-cloud-storage) gem<br>
S3 wrapper requires [aws-sdk-s3](https://github.com/aws/aws-sdk-ruby)

## client

gcs example:

```ruby
require 'cloud_storage/wrappers/gcs'

cli = CloudStorage::Client.new(
  :gcs,
  bucket: 'some-bucket',
  project_id: 'some-project-id',
  credentials: 'secrets/some-secrets.json',
  # endpoint: 'http://gcs:8080/'
)
```

s3 (Aws, Yandex, Minio) example:

```ruby
require 'cloud_storage/wrappers/s3'

cli = CloudStorage::Client.new(
  :s3,
  bucket: 'some-bucket',
  endpoint: 'http://s3:4569', # https://storage.yandexcloud.net
  region: 'RU',
  access_key_id: 'some-id',
  secret_access_key: 'some-secret'
)
```

### list files (enumerable):

```ruby
> cli.files(prefix: 'some_dir').map { |f| [f.name, f.size] }
=> [["some_dir/test.txt", 22]]
```

### delete file:

```ruby
> f = cli.files.first
> f.delete!
=> nil
```

### delete files:

```ruby
> cli.delete_files(['some_dir/test1.txt', 'some_dir/test2.txt'])
```

### check file:

```ruby
> cli.exist?('test.txt')
=> false
```

### upload file:

```ruby
> f = cli.upload_file(key: 'test.txt', file: File.open('test.txt', 'rb'))
> f.name
=> 'test.txt'

> stream = StringIO.new('test')
> f = cli.upload_file(key: 'test.txt', file: stream)
> f.name
=> 'test.txt'
```

### signed url:

`expires_in` - seconds, optional. You can also pass any arg specific for a gcs or s3 client:

```ruby
# gcs
> key = OpenSSL::PKey::RSA.new(File.read('dummy.key'))
> f.signed_url(expires: 10, issuer: 'max@tretyakov-ma.ru', signing_key: key)
=> "https://storage.googleapis.com/some-bucket/test.txt?GoogleAccessId=max%40tretyakov-ma.ru&Expires=1615375291&Signature=FIwtDC%2FkURL%2F9JaKOWmqXgTbvdtilQH4Wsf18rPfLvn1eg6zqZ1pjY4PB82D82Spo5iQbepwnE5OozGxL0B3sliZPcut67kPulCnEXz8IRvbeJ4VY2kFXMg0KThyrZwXhF3kHu7YiKQn8tcf6NmHrKEjKNeioAcO4fnbm8f9k7AlhpwOhQayTzHceSqJlxty7M7stLbSezh7CxEV%2F1M8oTvreg57t3J%2FPG9qhtWrPZoKJS1tScpFQpWH%2F5SiCdyn56WLYf4XKpyHx3%2FaBDBvlYsWB8cRWCFPnuSPif8ePkEI2pZDaG%2FNTW0X%2BhGEWcp6Db4VnbB1s%2BK0mhUxNy8ATg%3D%3D"

# s3
> f.signed_url(expires_in: 10)
=> "http://wallarm-devtmp-ipfeeds-presigned-urls-research.s3:4569/Gemfile?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=...&X-Amz-Date=20210310T061122Z&X-Amz-Expires=10&X-Amz-SignedHeaders=host&X-Amz-Signature=..."
```

### Download

```ruby
> cli.find('test.txt').download.read
=> "This is a test download\n"

s = StringIO.new
> cli.find('test.txt').download(s)
> s.read
=> "This is a test download\n"
```

```ruby
> f = cli.files.first
> f.download.read
=> "This is a test download\n"
```

### Find

```ruby
> cli.find('test.txt').to_s
=> "#<CloudStorage::Objects::S3:0x00007f778ed685c8>"
```

See the specs for more examples
