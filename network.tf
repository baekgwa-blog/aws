resource "aws_route53_zone" "private" {
  name = "internal.baekgwa.blog"

  vpc {
    vpc_id = aws_vpc.main.id
  }
}