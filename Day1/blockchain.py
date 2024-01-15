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
class Block:
    def __init__(self,index,transactions,timestamp,previous_hash):
        self.index = index
        self.transactions = transactions
        self.timestamp = timestamp
        self.previous_hash = previous_hash # Adding the previous hash field
    def compute_hash(self):
        block_string = json.dumps(self.__dict__ , sort_keys=True)
        return hashlib.sha256(block_string.encode()).hexdigest()

class Blockchain():
    difficulty = 4 # difficulty of PoW algorithm
    def __init__(self):
        self.chain = []
        self.create_genesis_block()
    def create_genesis_block(self):
        new_block = Block(0,[],time(),"0")
        new_block.hash = new_block.compute_hash()
        self.chain.append(new_block)


    def add_block(self,block,proof):
        if self.last_block.hash !=block.previous_hash:
            return False
        if not Blockchain.is_valid_proof(block,proof):
            return False


    def add_new_transaction(self, transaction):
        self.unconfirmed_transactions.append(transaction)

    def is_valid_proof(self,block,block_hash):
        """
                Check if block_hash is valid hash of block and satisfies
                the difficulty criteria.
                """
        return (block.compute_hash() == block_hash) and block_hash[:4]==('0' * Blockchain.difficulty)
    
    @property
    def last_block(self):
        return self.chain[-1]
    
    @staticmethod
    def proof_of_work(self,block):
        """
            简单的工作量证明:
                 - 查找一个 p' 使得 hash(pp') 以4个0开头
                 - p 是上一个块的证明,  p' 是当前的证明
                """
        block.nonce = 0
        hash = block.compute_hash()
        while hash[:4]!=('0' * Blockchain.difficulty):
            block.nonce +=1
            hash = block.compute_hash()
        return hash
    
    def mine(self):
        """
        This function serves as an interface to add the pending
        transactions to the blockchain by adding them to the block
        and figuring out proof of work.
        """
        if not self.unconfirmed_transactions:
            return False
        last_block = self.last_block
        new_block = Block(index=last_block.index + 1,
                          transactions=self.unconfirmed_transactions,
                          timestamp=time.time(),
                          previous_hash=last_block.hash)
        proof = self.proof_of_work(new_block)
        self.add_block(new_block, proof)
        self.unconfirmed_transactions = []
        return new_block.index

# Press the green button in the gutter to run the script.
if __name__ == '__main__':
    pass
# See PyCharm help at https://www.jetbrains.com/help/pycharm/
