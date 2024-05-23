
  deploy:
    needs: build
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4 # updated to match node.js 20
      
      - name: Azure Login
        env:
          AZURE_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
          AZURE_CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
          AZURE_CLIENT_SECRET: ${{ secrets.AZURE_CLIENT_SECRET }}
          AZURE_TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
        run: |
          az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET --tenant $AZURE_TENANT_ID > /dev/null
          az aks get-credentials --resource-group retail-haven-rg-8366 --name aks-retail-haven-rg-8366 --overwrite-existing
      
      - name: Install Helm
        run: |
          curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
          chmod +x get_helm.sh
          ./get_helm.sh
  
      - name: Deploy with Helm
        run: |
          helm upgrade --install retail-therapy-app ./helm
