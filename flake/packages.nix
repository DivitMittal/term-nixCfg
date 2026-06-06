{inputs, ...}: {
  perSystem = {system, ...}: {
    packages.workmux = inputs.llm-agents.packages.${system}.workmux;
  };
}
