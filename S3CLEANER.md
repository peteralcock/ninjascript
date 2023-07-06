# Clear all your unused AWS S3 Buckets

- Delete all S3 buckets stored in your AWS account (including not empty):

```
aws s3 ls | cut -d" " -f 3 | xargs -I{} aws s3 rb s3://{} --force
```


- Delete only empty buckets (without --force flag):

```
aws s3 ls | cut -d" " -f 3 | xargs -I{} aws s3 rb s3://{}
```


- Delete only buckets with the prefix old_:
  
````
aws s3 ls | grep 'old_*' | cut -d" " -f 3 | xargs -I{} aws s3 rb s3://{} --force

```
