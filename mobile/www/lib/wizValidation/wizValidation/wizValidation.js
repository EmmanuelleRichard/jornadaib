angular.module('wiz.validation', [
	'wiz.validation.integer',
	'wiz.validation.decimal',
	'wiz.validation.dateOfBirth',
	'wiz.validation.postcode',
	'wiz.validation.zipcode',
	'wiz.validation.atLeastOne',
	'wiz.validation.equalTo',
	'wiz.validation.notEqualTo',
	'wiz.validation.unique',
	'wiz.validation.startsWith',
	'wiz.validation.endsWith',
	'wiz.validation.file',
	'wiz.validation.blacklist',
	'wiz.validation.whitelist',
	'wiz.validation.conditions'
]);

angular.module('wiz.validation.atLeastOne', []);
angular.module('wiz.validation.blacklist', []);
angular.module('wiz.validation.conditions', []);
angular.module('wiz.validation.dateOfBirth', []);

angular.module('wiz.validation.decimal', []);
angular.module('wiz.validation.endsWith', []);

angular.module('wiz.validation.equalTo', []);
angular.module('wiz.validation.file', []);
angular.module('wiz.validation.integer', []);
angular.module('wiz.validation.notEqualTo', []);
angular.module('wiz.validation.postcode', []);
angular.module('wiz.validation.startsWith', []);
angular.module('wiz.validation.unique', []);
angular.module('wiz.validation.whitelist', []);
angular.module('wiz.validation.zipcode', []);
angular.module('wiz.validation.atLeastOne')

	.service('wizAtLeastOneSvc', function () {
		this.values = [];

		this.cleanup = function () {
			this.values = [];
		};

		this.addValue = function (value) {
			if (typeof value.value === "undefined") {
				value.value = "";
			}

			var existingValue = false;
			for (var i = 0; i < this.values.length; i++) {
				if (this.values[i].name === value.name) {
					this.values[i] = value;
					existingValue = true;
					break;
				}
			}
			if (!existingValue) {
				this.values.push(value);
			}
		};

		this.isEmpty = function (group) {
			var isEmpty = true;
			for (var i = 0; i < this.values.length; i++) {
				if (this.values[i].value &&
					this.values[i].group === group &&
					this.values[i].value.length > 0) {
					isEmpty = false;
					break;
				}
			}
			return isEmpty;
		};
	});
angular.module('wiz.validation.equalTo')

	.service('wizEqualToSvc', ['$filter', function ($filter) {
		this.values = [];

		this.cleanup = function () {
			this.values = [];
		};

		this.addValue = function (value) {
			if (typeof value.value === "undefined") {
				value.value = "";
			}

			var existingValue = false;
			for (var i = 0; i < this.values.length; i++) {
				if (this.values[i].name === value.name) {
					this.values[i] = value;
					existingValue = true;
					break;
				}
			}
			if (!existingValue) {
				this.values.push(value);
			}
		};

		this.isEqual = function (group) {
			var isEqual = true;
			var groupValues = $filter('filter')(this.values, { group: group }, true);
			for (var i = 0; i < groupValues.length; i++) {
				if (groupValues[i].value !== groupValues[0].value) {
					isEqual = false;
					break;
				}
			}
			return isEqual;
		};
	}]);
angular.module('wiz.validation.notEqualTo')

	.service('wizNotEqualToSvc', ['$filter', function ($filter) {
		this.values = [];

		this.cleanup = function () {
			this.values = [];
		};

		this.addValue = function (value) {
			if (typeof value.value === "undefined") {
				value.value = "";
			}

			var existingValue = false;
			for (var i = 0; i < this.values.length; i++) {
				if (this.values[i].name === value.name) {
					this.values[i] = value;
					existingValue = true;
					break;
				}
			}
			if (!existingValue) {
				this.values.push(value);
			}
		};

		this.isEqual = function (group) {
			var isEqual = true;
			var groupValues = $filter('filter')(this.values, { group: group }, true);
			for (var i = 0; i < groupValues.length; i++) {
				if (groupValues[i].value !== groupValues[0].value) {
					isEqual = false;
					break;
				}
			}
			return isEqual;
		};
	}]);
angular.module('wiz.validation.unique')

	.service('wizUniqueSvc', ['$filter', function ($filter) {
		this.values = [];

		this.cleanup = function () {
			this.values = [];
		};

		this.addValue = function (value) {
			if (typeof value.value === "undefined") {
				value.value = "";
			}

			var existingValue = false;
			for (var i = 0; i < this.values.length; i++) {
				if (this.values[i].name === value.name) {
					this.values[i] = value;
					existingValue = true;
					break;
				}
			}

			if (!existingValue) {
				this.values.push(value);
			}
		};

		this.isUnique = function (group) {
			var isUnique = true;
			var groupValues = $filter('filter')(this.values, { group: group }, true);
			for (var i = 0; i < groupValues.length; i++) {
				if (!isUnique) {
					break;
				}

				for (var j = 0; j < groupValues.length; j++) {
					if (i === j) {
						continue;
					}

					if (groupValues[i].value === groupValues[j].value) {
						isUnique = false;
						break;
					}
				}
			}
			return isUnique;
		};
	}]);
angular.module('wiz.validation.atLeastOne')

	.directive('wizValAtLeastOne', ['wizAtLeastOneSvc', function (wizAtLeastOneSvc) {
		return {
			restrict: 'A',
			require: 'ngModel',
			link: function (scope, elem, attrs, ngModel) {

				//For DOM -> model validation
				ngModel.$parsers.unshift(function (value) {
					addValue(value);
					return value;
				});

				//For model -> DOM validation
				ngModel.$formatters.unshift(function (value) {
					addValue(value);
					return value;
				});

				function addValue(value) {
					wizAtLeastOneSvc.addValue({
						name: attrs.ngModel,
						group: attrs.wizValAtLeastOne,
						value: value
					});
				}

				function validate() {
					var valid = false;

					if (!wizAtLeastOneSvc.isEmpty(attrs.wizValAtLeastOne)) {
						valid = true;
					}

					ngModel.$setValidity('wizValAtLeastOne', valid);
				}

				scope.$watch(function () {
					return wizAtLeastOneSvc.values;
				}, function () {
					validate();
				}, true);

				scope.$on('$destroy', function () {
					wizAtLeastOneSvc.cleanup();
				});
			}
		};
	}]);

angular.module('wiz.validation.blacklist')

	.directive('wizValBlacklist', function () {
		return {
			restrict: 'A',
			require: 'ngModel',
			scope: { blacklist: '=wizValBlacklist' },
			link: function (scope, elem, attrs, ngModel) {

				//For DOM -> model validation
				ngModel.$parsers.unshift(function (value) {
					return validate(value);
				});

				//For model -> DOM validation
				ngModel.$formatters.unshift(function (value) {
					return validate(value);
				});

				function validate(value) {
					var valid = true;

					if (typeof value === "undefined") {
						value = "";
					}

					if (typeof scope.blacklist !== "undefined") {
						for (var i = scope.blacklist.length - 1; i >= 0; i--) {
							if (value === scope.blacklist[i]) {
								valid = false;
								break;
							}
						}
					}
					ngModel.$setValidity('wizValBlacklist', valid);
					return value;
				}
			}
		};
	});
angular.module('wiz.validation.conditions')

	.directive('wizValConditions', function () {
		return {
			restrict: 'A',
			require: 'ngModel',
			scope: {
				conditions: '=wizValConditions'
			},
			link: function (scope, elem, attrs, ngModel) {

				//For DOM -> model validation
				ngModel.$parsers.unshift(function (value) {
					return validate(value);
				});

				//For model -> DOM validation
				ngModel.$formatters.unshift(function (value) {
					return validate(value);
				});

				if (typeof scope.conditions !== "undefined") {
					scope.$watch('conditions',
						function () {
							validate(ngModel.$viewValue);
						}, true);
				}

				function validate(value) {
					var valid = true;
					if (typeof scope.conditions !== "undefined") {
						for (var i = 0; i < scope.conditions.length; i++) {
							if (scope.conditions[i] === false) {
								valid = false;
								break;
							}
						}
					}

					ngModel.$setValidity('wizValConditions', valid);
					return value;
				}
			}
		};
	});

angular.module('wiz.validation.dateOfBirth')

	.directive('wizValDateOfBirth', function () {
		return {
			restrict: 'A',
			require: 'ngModel',
			scope: {
				wizValDateOfBirth: '=wizValDateOfBirth'
			},
			link: function (scope, elem, attrs, ngModel) {

				//For DOM -> model validation
				ngModel.$parsers.unshift(function (value) {
					return validate(value);
				});

				//For model -> DOM validation
				ngModel.$formatters.unshift(function (value) {
					return validate(value);
				});

				function validate(value) {
					var valid = true;
					if (angular.isDefined(value) && value.length > 0) {
						if (value && /^\d+$/.test(scope.wizValDateOfBirth)) {
							// If positive integer used for age then use to check input value
							var today = new Date();
							var birthDate = new Date(value);
							var age = today.getFullYear() - birthDate.getFullYear();
							var m = today.getMonth() - birthDate.getMonth();
							if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate())) {
								age--;
							}
							if (age < scope.wizValDateOfBirth) {
								valid = false;
							}
						}
					}

					ngModel.$setValidity('wizValDateOfBirth', valid);
					return value;
				}
			}
		};
	});

angular.module('wiz.validation.decimal')

	.directive('wizValDecimal', function () {
		return {
			restrict: 'A',
			require: 'ngModel',
			scope: {
				decimalPlaces: '=wizValDecimal'
			},
			link: function (scope, elem, attrs, ngModel) {

				//For DOM -> model validation
				ngModel.$parsers.unshift(function (value) {
					return validate(value);
				});

				//For model -> DOM validation
				ngModel.$formatters.unshift(function (value) {
					return validate(value);
				});

				function validate(value) {
					var valid = true;
					if (angular.isDefined(value) && value.length > 0) {
						var pattern = "^-?([0-9]+)\\.([0-9]+)$";
						if (/^-?[0-9]+$/.test(scope.decimalPlaces)) {
							pattern = "^-?([0-9]+)\\.([0-9]{1," + scope.decimalPlaces + "})$";
						}
						var regEx = new RegExp(pattern);
						valid = regEx.test(value);
					}
					ngModel.$setValidity('wizValDecimal', valid);
					return value;
				}
			}
		};
	});

angular.module('wiz.validation.endsWith')

	.directive('wizValEndsWith', function () {
		return {
			restrict: 'A',
			require: 'ngModel',
			scope: {
				endsWith: '=wizValEndsWith'
			},
			link: function (scope, elem, attrs, ngModel) {

				//For DOM -> model validation
				ngModel.$parsers.unshift(function (value) {
					return validate(value);
				});

				//For model -> DOM validation
				ngModel.$formatters.unshift(function (value) {
					return validate(value);
				});

				function validate(value) {
					var valid = false;
					if (typeof value === "undefined") {
						value = "";
					}

					if (typeof scope.endsWith !== "undefined") {
						valid = value.indexOf(scope.endsWith, value.length - scope.endsWith.length) !== -1;
					}
					ngModel.$setValidity('wizValEndsWith', valid);
					return value;
				}
			}
		};
	});

angular.module('wiz.validation.equalTo')

	.directive('wizValEqualTo', ['wizEqualToSvc', function (wizEqualToSvc) {
		return {
			restrict: 'A',
			require: 'ngModel',
			link: function (scope, elem, attrs, ngModel) {

				//For DOM -> model validation
				ngModel.$parsers.unshift(function (value) {
					addValue(value);
					return value;
				});

				//For model -> DOM validation
				ngModel.$formatters.unshift(function (value) {
					addValue(value);
					return value;
				});

				function addValue(value) {
					wizEqualToSvc.addValue({
						name: attrs.ngModel,
						group: attrs.wizValEqualTo,
						value: value
					});
				}

				function validate() {
					var valid = wizEqualToSvc.isEqual(attrs.wizValEqualTo);
					ngModel.$setValidity('wizValEqualTo', valid);
				}

				scope.$watch(function () {
					return wizEqualToSvc.values;
				}, function () {
					validate();
				}, true);

				scope.$on('$destroy', function () {
					wizEqualToSvc.cleanup();
				});
			}
		};
	}]);

angular.module('wiz.validation.file')

	.directive('wizValFile', function () {
		return {
			restrict: 'A',
			require: 'ngModel',
			scope: {
				// array of valid file types e.g ['image/jpeg','image/gif']
				fileTypes: '=wizValFileTypes',
				// maximum file size in bytes
				fileSize: '=wizValFileSize',
				// number of files integer
				fileNumber: '=wizValFileNumber'
			},
			link: function (scope, elem, attrs, ngModel) {

				elem.bind('change', function () {
					validate(elem[0].files);
				});

				function validate(files) {
					var validType = true;
					var validSize = true;
					var validNumber = true;

					// if file type attribute exists check it.
					if (angular.isUndefined(scope.fileTypes)) {
						scope.fileTypes = [];
					}

					// if file number is not defined set it to one.
					if (angular.isDefined(scope.fileNumber) && files.length > scope.fileNumber) {
						validNumber = false;
					}

					for (var i = 0; i < files.length; i++) {
						var file = files[i];
						// Check file type and size of each file
						if (scope.fileTypes.indexOf(file.type) === -1 && scope.fileTypes.length > 0) {
							validType = false;
						}
						if (angular.isNumber(scope.fileSize) && file.size > scope.fileSize) {
							validSize = false;
						}
						if (!validType || !validSize) {
							break;
						}
					}

					ngModel.$setValidity('wizValFileTypes', validType);
					ngModel.$setValidity('wizValFileSize', validSize);
					ngModel.$setValidity('wizValFileNumber', validNumber);
				}
			}
		};
	});
angular.module('wiz.validation.integer')

	.directive('wizValInteger', function () {
		return {
			restrict: 'A',
			require: 'ngModel',
			link: function (scope, elem, attrs, ngModel) {

				//For DOM -> model validation
				ngModel.$parsers.unshift(function (value) {
					return validate(value);
				});

				//For model -> DOM validation
				ngModel.$formatters.unshift(function (value) {
					return validate(value);
				});

				function validate(value) {
					var valid = true;
					if (angular.isDefined(value) && value.length > 0) {
						valid = /^-?[0-9]+$/.test(value);
					}

					ngModel.$setValidity('wizValInteger', valid);
					return value;
				}
			}
		};
	});

angular.module('wiz.validation.notEqualTo')

	.directive('wizValNotEqualTo', ['wizNotEqualToSvc', function (wizNotEqualToSvc) {
		return {
			restrict: 'A',
			require: 'ngModel',
			link: function (scope, elem, attrs, ngModel) {

				//For DOM -> model validation
				ngModel.$parsers.unshift(function (value) {
					addValue(value);
					return value;
				});

				//For model -> DOM validation
				ngModel.$formatters.unshift(function (value) {
					addValue(value);
					return value;
				});

				function addValue(value) {
					wizNotEqualToSvc.addValue({
						name: attrs.ngModel,
						group: attrs.wizValNotEqualTo,
						value: value
					});
				}

				function validate() {
					var valid = !wizNotEqualToSvc.isEqual(attrs.wizValNotEqualTo);
					ngModel.$setValidity('wizValNotEqualTo', valid);
				}

				scope.$watch(function () {
					return wizNotEqualToSvc.values;
				}, function () {
					validate();
				}, true);

				scope.$on('$destroy', function () {
					wizNotEqualToSvc.cleanup();
				});
			}
		};
	}]);

angular.module('wiz.validation.postcode')

	.directive('wizValPostcode', function () {
		return {
			restrict: 'A',
			require: 'ngModel',
			link: function (scope, elem, attrs, ngModel) {

				//For DOM -> model validation
				ngModel.$parsers.unshift(function (value) {
					return validate(value);
				});

				//For model -> DOM validation
				ngModel.$formatters.unshift(function (value) {
					return validate(value);
				});

				function validate(value) {
					var valid = true;
					if (angular.isDefined(value) && value.length > 0) {
						// GOV Postcode regex: http://webarchive.nationalarchives.gov.uk/+/http://www.cabinetoffice.gov.uk/media/291370/bs7666-v2-0-xsd-PostCodeType.htm
						valid = /^\b(GIR ?0AA|SAN ?TA1|(?:[A-PR-UWYZ](?:\d{0,2}|[A-HK-Y]\d|[A-HK-Y]\d\d|\d[A-HJKSTUW]|[A-HK-Y]\d[ABEHMNPRV-Y])) ?\d[ABD-HJLNP-UW-Z]{2})\b$/i.test(value);
					}
					ngModel.$setValidity('wizValPostcode', valid);
					return value;
				}
			}
		};
	});

angular.module('wiz.validation.startsWith')

	.directive('wizValStartsWith', function () {
		return {
			restrict: 'A',
			require: 'ngModel',
			scope: {
				startsWith: '=wizValStartsWith'
			},
			link: function (scope, elem, attrs, ngModel) {

				//For DOM -> model validation
				ngModel.$parsers.unshift(function (value) {
					return validate(value);
				});

				//For model -> DOM validation
				ngModel.$formatters.unshift(function (value) {
					return validate(value);
				});

				function validate(value) {
					if (typeof value === "undefined") {
						value = "";
					}

					var valid = value.lastIndexOf(scope.startsWith, 0) === 0;
					ngModel.$setValidity('wizValStartsWith', valid);
					return value;
				}
			}
		};
	});

angular.module('wiz.validation.unique')

	.directive('wizValUnique', ['wizUniqueSvc', function (wizUniqueSvc) {
		return {
			restrict: 'A',
			require: 'ngModel',
			link: function (scope, elem, attrs, ngModel) {

				//For DOM -> model validation
				ngModel.$parsers.unshift(function (value) {
					addValue(value);
					return value;
				});

				//For model -> DOM validation
				ngModel.$formatters.unshift(function (value) {
					addValue(value);
					return value;
				});

				function addValue(value) {
					wizUniqueSvc.addValue({
						name: attrs.ngModel,
						group: attrs.wizValUnique,
						value: value
					});
				}

				function validate() {
					var valid = wizUniqueSvc.isUnique(attrs.wizValUnique);
					ngModel.$setValidity('wizValUnique', valid);
				}

				scope.$watch(function () {
					return wizUniqueSvc.values;
				}, function () {
					validate();
				}, true);

				scope.$on('$destroy', function () {
					wizUniqueSvc.cleanup();
				});
			}
		};
	}]);

angular.module('wiz.validation.whitelist')

	.directive('wizValWhitelist', function () {
		return {
			restrict: 'A',
			require: 'ngModel',
			scope: { whitelist: '=wizValWhitelist' },
			link: function (scope, elem, attrs, ngModel) {

				//For DOM -> model validation
				ngModel.$parsers.unshift(function (value) {
					return validate(value);
				});

				//For model -> DOM validation
				ngModel.$formatters.unshift(function (value) {
					return validate(value);
				});

				function validate(value) {
					var valid = false;
					if (typeof value === "undefined") {
						value = "";
					}

					if (typeof scope.whitelist !== "undefined") {
						for (var i = scope.whitelist.length - 1; i >= 0; i--) {
							if (value === scope.whitelist[i]) {
								valid = true;
								break;
							}
						}
					}
					ngModel.$setValidity('wizValWhitelist', valid);
					return value;
				}
			}
		};
	});

angular.module('wiz.validation.zipcode')

	.directive('wizValZipcode', function () {
		return {
			restrict: 'A',
			require: 'ngModel',
			link: function (scope, elem, attrs, ngModel) {

				//For DOM -> model validation
				ngModel.$parsers.unshift(function (value) {
					return validate(value);
				});

				//For model -> DOM validation
				ngModel.$formatters.unshift(function (value) {
					return validate(value);
				});

				function validate(value) {
					var valid = true;
					if (angular.isDefined(value) && value.length > 0) {
						valid = /(^\d{5}-?\d{4}$)|(^\d{5}$)/.test(value);
					}

					ngModel.$setValidity('wizValZipcode', valid);
					return value;
				}
			}
		};
	});
