## MakeableDKPagingMediator - Private Repo ##

*Automatic handling of Paging enabled Network calls for swift.*

This framework enables tableViews showing data that contains thousand of items, to fetch items automatically when scrolling down the tableView.

# Example usage: #

**To use the PagingMediator, start by creating a Network call in the supported form**
![Image of NetworkCall](https://github.com/makeabledk/swift-paging-framework/blob/master/PagingMediatorFramework/NetworkCallExample.png)


**Next, wrap the Network call in a PagingMediator object. Specify the parameter type, and the return type of the call**
![Image of PagingMediator](https://github.com/makeabledk/swift-paging-framework/blob/master/PagingMediatorFramework/PagingMediatorExample.png)

**Now in your CellForRowAt() function, check the Mediator if the tableView should fetch more data**
![Image of CellForRowAt](https://github.com/makeabledk/swift-paging-framework/blob/master/PagingMediatorFramework/cellForRowAtExample.png)

**When searching for a new searchTerm, reset the mediator**
![Image of SearchExample](https://github.com/makeabledk/swift-paging-framework/blob/master/PagingMediatorFramework/searchExample.png)
