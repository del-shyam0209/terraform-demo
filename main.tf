
# Create IAM role for EC2 instance
resource "aws_iam_role" "ec2_role" {
  name = "EC2_SSM_Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach AmazonSSMManagedInstanceCore policy to the IAM role
resource "aws_iam_role_policy_attachment" "ec2_role_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.ec2_role.name
}

# Create an instance profile for the EC2 instance and associate the IAM role
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "EC2_SSM_Instance_Profile"
  role = aws_iam_role.ec2_role.name
}


# EC2 creation
resource "aws_instance" "ec2_instance" {
  for_each                    = toset(var.patch_groups)
  ami                         = data.aws_ami.amazon_linux_2_ssm.id
  subnet_id                   = var.subnet_id
  instance_type               = "t2.micro"
  iam_instance_profile        = aws_iam_instance_profile.ec2_instance_profile.name
  associate_public_ip_address = true
  tags                        = merge(var.tags, { PatchGroup = each.key }, { Name = "del-lza-demo-instances" })
}


# Patching 

resource "aws_ssm_maintenance_window" "install-a" {
  name              = "del-lza-demo-maintenance-window-1"
  cutoff            = 1
  description       = "Maintenance window for applying patches"
  duration          = 2
  schedule          = "cron(15 14 ? * TUE *)"
  tags              = var.tags
  schedule_timezone = "NZ"
}

resource "aws_ssm_maintenance_window" "install-b" {
  name              = "del-lza-demo-maintenance-window-2"
  cutoff            = 1
  description       = "Maintenance window for applying patches"
  duration          = 2
  schedule          = "cron(30 14 ? * TUE *)"
  tags              = var.tags
  schedule_timezone = "NZ"

}

resource "aws_ssm_maintenance_window_target" "install-a" {

  window_id     = aws_ssm_maintenance_window.install-a.id
  name          = "maintenance-window-target-1"
  description   = "This is a maintenance window target"
  resource_type = "INSTANCE"

  targets {
    key    = "tag:PatchGroup"
    values = ["Group 1"]
  }
}

resource "aws_ssm_maintenance_window_target" "install-b" {

  window_id     = aws_ssm_maintenance_window.install-b.id
  name          = "maintenance-window-target-2"
  description   = "This is a maintenance window target"
  resource_type = "INSTANCE"

  targets {
    key    = "tag:PatchGroup"
    values = ["Group 2"]
  }
}

resource "aws_ssm_maintenance_window_task" "install-a" {
  name            = "InstallPatches"
  max_concurrency = 2
  max_errors      = 1
  priority        = 1
  task_type       = "RUN_COMMAND"
  task_arn        = "AWS-RunPatchBaseline"
  window_id       = aws_ssm_maintenance_window.install-a.id
  targets {
    key    = "WindowTargetIds"
    values = [aws_ssm_maintenance_window_target.install-a.id]
  }
  task_invocation_parameters {
    run_command_parameters {
      comment         = "Installs necessary patches"
      timeout_seconds = 120

      parameter {
        name   = "Operation"
        values = ["Install"]
      }

    }
  }
}


resource "aws_ssm_maintenance_window_task" "install-b" {
  name            = "InstallPatches"
  max_concurrency = 2
  max_errors      = 1
  priority        = 1
  task_type       = "RUN_COMMAND"
  task_arn        = "AWS-RunPatchBaseline"
  window_id       = aws_ssm_maintenance_window.install-b.id
  targets {
    key    = "WindowTargetIds"
    values = [aws_ssm_maintenance_window_target.install-b.id]
  }
  task_invocation_parameters {
    run_command_parameters {
      comment         = "Installs necessary patches"
      timeout_seconds = 120

      parameter {
        name   = "Operation"
        values = ["Install"]
      }

    }
  }
}

# Backups

resource "aws_backup_plan" "plan" {
  name = "del-lza-demo-plan"
  rule {
    rule_name         = "del-lza-demo-rule"
    target_vault_name = var.vault_name
    schedule          = "cron(15 1 ? * TUE *)"
    lifecycle {
      delete_after = 7
    }
  }
  advanced_backup_setting {
    backup_options = {
      WindowsVSS = "enabled"
    }
    resource_type = "EC2"
  }

}

resource "aws_iam_role" "backup" {
  name               = "del-lza-demo-backup-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_backup.json
}

resource "aws_iam_role_policy_attachment" "backup" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
  role       = aws_iam_role.backup.name
}



resource "aws_backup_selection" "selection_default" {
  iam_role_arn = aws_iam_role.backup.arn
  name         = "del-lza-demo-backup_selection"
  plan_id      = aws_backup_plan.plan.id
  selection_tag {
    type  = "STRINGEQUALS"
    key   = "backup"
    value = "true"
  }
}