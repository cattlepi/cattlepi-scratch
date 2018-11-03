This documents how to configure a pi that runs the builder.   
sample config that can be used for build control - only relevant part shown.  

```json
{
  "config": {
    "buildcontrol": {
      "aws_ak": "aws access_key",
      "aws_sk": "aws secret key",
      "aws_sqs_queue": "aws sqs queue URL",
      "build_machines": [
        "ip of build machine1",
        "ip of build machine2",
        "ip of build machine3"
      ],
      "builders_api_key": "cattlepi api key of the build machines",
      "gh_token": "github token - used to make api calls to github"
    },
  }
}
```