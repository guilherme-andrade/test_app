const images = require.context('../../images', true);
const bootstrapIcons = require.context('bootstrap-icons/icons', true);
console.log(images);
const imagePath = (name) => images(name, true);
const iconsPath = (name) => bootstrapIcons(name, true);


