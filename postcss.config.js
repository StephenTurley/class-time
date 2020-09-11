module.exports = {
    plugins: [
        require('tailwindcss'),
        require('postcss-elm-tailwind')({
            elmFile: 'web/TW.elm',
            elmModuleName: 'TW'
        })
    ]
}

