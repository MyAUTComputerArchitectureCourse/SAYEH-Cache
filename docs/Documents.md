# Documents

## Modules

Modules used in this Cach implementation of the SAYEH basic computer is :

* **Data Array**: This module is the storage module of the cache.

* **Tag Valid Array**: A module for storing the tags and retrieving them with index.

* **HIT MISSS Logic**: This module is an async module with gate level design. It can determine wether the given address is stored in the cache or not with the appropriate data.

* **Controller**: This module will produce the control signals for the cache and reading/writing to the memory. It is also responsible for the data array writing and reading. This module is implemented with a 3 state FSM.

* **Counter Array**: Will store the number of reading for each index in each set of cache storage.

## Replacement Policy

In case of data miss the MRU(Most recently used) is our data replacement policy. The new data should be stored in the place of the data that is most used earlier. For detecting the most used data we count the number of each access to each cell of the data path.