# GUI provisioning walkthrough

1. Open Catalog page within project and filter output

![Filtered Project Catalog](./images/catalog-filtered.jpeg)

2. Walkthrough the wizard and enter the size requested (in GB)

![Add NFS Service - page 1](./images/nfs-wizard-p1.jpeg)

![Enter Size in GB - page 2](./images/nfs-wizard-p2.jpeg)

![Finish Wizard - page 3](./images/nfs-wizard-p3.jpeg)

3. Check ServiceInstance for ansyncronous provisioning (this may take a few minutes
while the storage and filesystem is created)

![Monitor service instances](./images/nfs-service-pending.jpeg)

4. Once the ServiceInstance has completed provisioning you can see your PVC.

![View provisioned storage](./images/nfs-storage-complete.jpeg)