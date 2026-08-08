variable "DOM" {
   // type = list(string)
    default = [
        "example.com", 
        "test.com",
         "demo.com"]
}
    

output "print" {
    value = var.DOM
}