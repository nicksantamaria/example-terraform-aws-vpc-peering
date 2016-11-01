provider "aws" {
  region = "ap-southeast-2"
}

resource "aws_vpc_peering_connection" "primary2secondary" {
  peer_owner_id = "316714384374"
  peer_vpc_id = "${aws_vpc.secondary.id}"
  vpc_id = "${aws_vpc.primary.id}"
  auto_accept = true

  accepter {
#    allow_remote_vpc_dns_resolution = true
  }

  requester {
#    allow_remote_vpc_dns_resolution = true
  }
}
