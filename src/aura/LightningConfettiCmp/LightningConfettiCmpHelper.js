/**
 Author:         Paul Lucas
 Company:        Salesforce
 Description:    LightningConfettiCmpHelper.js
 Date:           06-Sep-2019

 History:
 When           Who                 What

 TODO:

 */
({
	// Enumerations
	EFFECTS: {
		"CANNON": "cannon",
		"FIREWORKS": "fireworks",
		"CONFETTI_SHOWER": "confettiShower",
		"WINNER_CELEBRATION": "winnerCelebration",
		"CANVAS_CONFETTI": "canvasConfetti",
		"BURST_MODE": "burstMode"
	},

	/**
	 * bindEffects
	 *
	 * @param component
	 * @param event
	 * @param helper
	 */
	bindEffects: function (component, event, helper) {
		const args = event.getParam('arguments');

		let effects = [],
			duration = 0;

		if (args) {
			effects = args.effects;
			duration = args.duration;

			// Save the celebrations
			effects.forEach(e => {
				component.set(`v.${e}`, e);
			});

			component.set('v.duration', duration);
		}
	},

	/**
	 * celebrate
	 *
	 * @param component
	 * @param event
	 * @param helper
	 */
	celebrate: function (component, event, helper) {
		let effects = [],
			effect;

		// Get the list of celebrations
		Object.values(helper.EFFECTS)
			.forEach(e => {
				if (component.get(`v.${e}`)) {
					effects.push(e);
				}
			});

		try {
			// Fire the effects
			effects.forEach((e) => {
				effect = e;
				helper[e](component, event, helper);
			})
		} catch (e) {
			console.log('Effect is unsupported: ' + effect);
		}
	},

	/**
	 * cannon
	 *
	 * @param component
	 * @param event
	 * @param helper
	 */
	cannon: function (component, event, helper) {
		confetti({
			particleCount: 200,
			startVelocity: 60,
			spread: 150,
			origin: {
				y: 0.9
			},
			colors: component.get("v.colors")
		});
	},

	/**
	 * fireworks
	 *
	 * @param component
	 * @param event
	 * @param helper
	 */
	fireworks: function (component, event, helper) {
		let duration = isNaN(parseInt(component.get("v.duration"), 10)) ? 2 : parseInt(component.get("v.duration"), 10);
		let end = Date.now() + (duration * 1000);

		let interval = setInterval(function () {
			if (Date.now() > end) {
				return clearInterval(interval);
			}

			confetti({
				particleCount: 450,
				startVelocity: 30,
				spread: 360,
				ticks: 60,
				origin: {
					x: Math.random(),
					// since they fall down, start a bit higher than random
					y: Math.random() - 0.2
				},
				colors: component.get("v.colors")
			});
		}, 300);
	},

	/**
	 * confettiShower
	 *
	 * @param component
	 * @param event
	 * @param helper
	 */
	confettiShower: function (component, event, helper) {
		let duration = isNaN(parseInt(component.get("v.duration"), 10)) ? 2 : parseInt(component.get("v.duration"), 10);
		let end = Date.now() + (duration * 1000);

		(function frame() {
			confetti({
				particleCount: 10,
				startVelocity: 0,
				ticks: 300,
				origin: {
					x: Math.random(),
					// since they fall down, start a bit higher than random
					y: 0
				},
				colors: component.get("v.colors")
			});

			if (Date.now() < end) {
				requestAnimationFrame(frame);
			}
		}());
	},

	/**
	 * winnerCelebration
	 *
	 * @param component
	 * @param event
	 * @param helper
	 */
	winnerCelebration: function (component, event, helper) {
		let duration = isNaN(parseInt(component.get("v.duration"), 10)) ? 2 : parseInt(component.get("v.duration"), 10);
		let end = Date.now() + (duration * 1000);

		(function frame() {
			confetti({
				particleCount: 10,
				angle: 60,
				spread: 25,
				origin: {
					x: 0,
					y: 0.65
				},
				colors: component.get("v.colors")
			});
			confetti({
				particleCount: 10,
				angle: 120,
				spread: 25,
				origin: {
					x: 1,
					y: 0.65
				},
				colors: component.get("v.colors")
			});

			if (Date.now() < end) {
				requestAnimationFrame(frame);
			}
		}());
	},

	/**
	 * canvasConfetti
	 *
	 * @param component
	 * @param event
	 * @param helper
	 */
	canvasConfetti: function (component, event, helper) {
		let canvas = document.getElementById("customCanvas"); //component.find("customCanvas");

		// save this function... we'll save it to the canvas itself for
		// the purpose of this demo
		canvas.confetti = canvas.confetti || confetti.create(canvas, {
			resize: true
		});

		canvas.confetti({
			spread: 70,
			origin: {
				y: 1.2
			},
			colors: component.get("v.colors")
		});
	},

	/**
	 * burstMode
	 *
	 * @param component
	 * @param event
	 * @param helper
	 */
	burstMode: function (component, event, helper) {
		let duration = isNaN(parseInt(component.get("v.duration"), 10)) ? 2 : parseInt(component.get("v.duration"), 10);
		let end = Date.now() + (duration * 750);

		// go Buckeyes!
		let colors = ['#610B0B', '#FFFF00', '#FF00BF', '#0040FF', '#585858', '#00FFBF', '#FE642E', '#FFBF00', '#0101DF', '#FF8000', '#00FF00', '#FF0040', '#A901DB', '#0B0B3B', '#FF0000'];

		(function frame() {
			confetti({
				particleCount: 7,
				startVelocity: 25,
				angle: 335,
				spread: 10,
				origin: {
					x: 0,
					y: 0,
				},
				colors: colors
			});
			confetti({
				particleCount: 7,
				startVelocity: 25,
				angle: 205,
				spread: 10,
				origin: {
					x: 1,
					y: 0,
				},
				colors: colors
			});

			confetti({
				particleCount: 7,
				startVelocity: 35,
				angle: 140,
				spread: 30,
				origin: {
					x: 1,
					y: 1,
				},
				colors: colors
			});

			confetti({
				particleCount: 7,
				startVelocity: 35,
				angle: 40,
				spread: 30,
				origin: {
					x: 0,
					y: 1,
				},
				colors: colors
			});

			if (Date.now() < end) {
				requestAnimationFrame(frame);
			}
		}());
	},

	/**
	 * addListeners
	 *
	 * @param component
	 * @param event
	 * @param helper
	 */
	addListeners: function (component, event, helper) {
		window.addEventListener("keyup", function (event) {
			if (event.keyCode === 49) {
				component.celebrate(['cannon1', 'fireworks', 'winnerCelebration'], 1);
			}
		});
	},
})