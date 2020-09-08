resource "null_resource" "nullremote1"{
provisioner "local-exec" {
            command = "minikube start"
        }
}

resource "kubernetes_service" "example" {

depends_on=[null_resource.nullremote1]

metadata {
    name = "mywordpress"
  }
  spec {
    selector = {
      app = "${kubernetes_pod.wordp.metadata.0.labels.app}"
    }
    session_affinity = "ClientIP"
    port {
      port        = 80
      target_port = 80
    }

    type = "NodePort"
  }
}

resource "kubernetes_pod" "wordp" {

depends_on=[null_resource.nullremote1]
metadata {
    name = "mywordp"
    labels = {
      app = "MyApp"
    }
  }

  spec {
    container {
      image = "wordpress"
      name  = "wp"
      env{
            name = "WORDPRESS_DB_HOST"
            value = aws_db_instance.mydb.address
          }
          env{
            name = "WORDPRESS_DB_USER"
            value = aws_db_instance.mydb.username
          }
          env{
            name = "WORDPRESS_DB_PASSWORD"
            value = aws_db_instance.mydb.password
          }
          env{
          name = "WORDPRESS_DB_NAME"
          value = aws_db_instance.mydb.name
          }
    }
  }
}

output "wordpressip" {
          value = kubernetes_service.example.load_balancer_ingress
  }

resource "aws_db_instance" "mydb" {
  allocated_storage    = 10
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = "mysqldb"
  username             = "yogesh"
  password             = "redhat123"
  parameter_group_name = "default.mysql5.7"
  vpc_security_group_ids=["sg-012a5e5d7582997de"]
  publicly_accessible=true
}
