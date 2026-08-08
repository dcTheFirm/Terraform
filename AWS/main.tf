provider "aws" {

    region = "ap-south-1"

}


#create IAM uSEr. 

resource "aws_iam_user" "Security_user" {

name = "DC"
tags = {
    Project = "IAM-SECURITY-CENTER"
}
}


# create IAM GROUP

resource "aws_iam_group" "Security_group" {

    name = "Security_Admins"
}
