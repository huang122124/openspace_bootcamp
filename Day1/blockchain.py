# This is a sample Python script.
import hashlib
import json
from time import time
# Press ⌃R to execute it or replace it with your code.
# Press Double ⇧ to search everywhere for classes, files, tool windows, actions, and settings.
'''
block = {
    'index': 1,
    'timestamp': 1506057125.900785,
    'transactions': [
        {
            'sender': "8527147fe1f5426f9dd545de4b27ee00",
            'recipient': "a77f5cdfa2934df3954a5c7c7da5df1f",
            'amount': 5,
        }
    ],
    'proof': 324984774000,
    'previous_hash': "2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824"
}
'''
class Blockchain():
    def __init__(self):
        self.current_transactions = []
        self.chain = []

    def new_block(self,proof,previous_hash):
        block = {
            'index': len(self.chain)+1,
            'timestamp': time(),
            'transactions': self.current_transactions,
            'proof': proof,
            'previous_hash':previous_hash
        }
        self.current_transactions = []
        self.chain.append(block)
        return block

    def new_transaction(self,sender,recipient,amount):
        transaction = {
            'sender': sender,
            'recipient': recipient,
            'amount': amount,
        }
        self.current_transactions.append(transaction)


    def hash(block):
        data = json.dumps(block).encode()
        return hashlib.sha3_256(data).hexdigest()

    @property
    def last_block(self):
        return self.chain[-1]



    #找到一个数字 P ，使得它与前一个区块的 Proof 拼接成的字符串的 Hash 值以 4 个零开头。
    @staticmethod
    def proof_of_work(self,proof):
        p = 0
        while hashlib.sha256(f'{proof}{p}'.encode()).hexdigest()[:4] != '0000':
            p += 1
        return p


# Press the green button in the gutter to run the script.
if __name__ == '__main__':
    pass
# See PyCharm help at https://www.jetbrains.com/help/pycharm/
