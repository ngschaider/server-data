(() => {

	NGX = {};
	
	window.onData = (data) => {
		switch (data.action) {
			case 'actionTypeExample': {
				break;
			}
		}
	};

	window.onload = function (e) {
		window.addEventListener('message', (event) => {
			onData(event.data);
		});
	};

})();
