(() => {

	NGX = {};
	NGX.HUDElements = [];

	NGX.setHUDDisplay = function (opacity) {
		$('#hud').css('opacity', opacity);
	};

	NGX.insertHUDElement = function (name, index, priority, html, data) {
		NGX.HUDElements.push({
			name: name,
			index: index,
			priority: priority,
			html: html,
			data: data
		});

		NGX.HUDElements.sort((a, b) => {
			return a.index - b.index || b.priority - a.priority;
		});
	};

	NGX.updateHUDElement = function (name, data) {
		for (let i = 0; i < NGX.HUDElements.length; i++) {
			if (NGX.HUDElements[i].name == name) {
				NGX.HUDElements[i].data = data;
			}
		}

		NGX.refreshHUD();
	};

	NGX.deleteHUDElement = function (name) {
		for (let i = 0; i < NGX.HUDElements.length; i++) {
			if (NGX.HUDElements[i].name == name) {
				NGX.HUDElements.splice(i, 1);
			}
		}

		NGX.refreshHUD();
	};

	NGX.resetHUDElements = function () {
		NGX.HUDElements = [];
		NGX.refreshHUD();
	};

	NGX.refreshHUD = function () {
		$('#hud').html('');

		for (let i = 0; i < NGX.HUDElements.length; i++) {
			let html = Mustache.render(NGX.HUDElements[i].html, NGX.HUDElements[i].data);
			$('#hud').append(html);
		}
	};

	NGX.inventoryNotification = function (add, label, count) {
		let notif = '';

		if (add) {
			notif += '+';
		} else {
			notif += '-';
		}

		if (count) {
			notif += count + ' ' + label;
		} else {
			notif += ' ' + label;
		}

		let elem = $('<div>' + notif + '</div>');
		$('#inventory_notifications').append(elem);

		$(elem).delay(3000).fadeOut(1000, function () {
			elem.remove();
		});
	};

	window.onData = (data) => {
		switch (data.action) {
			case 'setHUDDisplay': {
				NGX.setHUDDisplay(data.opacity);
				break;
			}

			case 'insertHUDElement': {
				NGX.insertHUDElement(data.name, data.index, data.priority, data.html, data.data);
				break;
			}

			case 'updateHUDElement': {
				NGX.updateHUDElement(data.name, data.data);
				break;
			}

			case 'deleteHUDElement': {
				NGX.deleteHUDElement(data.name);
				break;
			}

			case 'resetHUDElements': {
				NGX.resetHUDElements();
				break;
			}

			case 'inventoryNotification': {
				NGX.inventoryNotification(data.add, data.item, data.count);
			}
		}
	};

	window.onload = function (e) {
		window.addEventListener('message', (event) => {
			onData(event.data);
		});
	};

})();
