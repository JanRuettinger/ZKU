module.exports = {
  useTabs: false,
  printWidth: 80,
  tabWidth: 2,
  semi: false,
  trailingComma: 'none',
  singleQuote: true,
  plugins: [require('prettier-plugin-solidity')],
  overrides: [
    {
      files: '*.sol',
      options: {
        printWidth: 80,
        tabWidth: 4,
        useTabs: false,
        singleQuote: false,
        bracketSpacing: false,
        explicitTypes: 'always',
      },
    },
  ],
}
