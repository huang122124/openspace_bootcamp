import  hashlib





data = 'hello'
result = hashlib.sha256(data.encode()).hexdigest()
print(result)