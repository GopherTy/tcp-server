package cmd

import (
	"server/cmd/daemon"
	"server/configure"
	"server/logger"
	"server/utils"
	"log"

	"github.com/spf13/cobra"
)

func init() {
	var filename string
	basePath := utils.BasePath()
	cmd := &cobra.Command{
		Use:   "daemon",
		Short: "run as daemon",
		Run: func(cmd *cobra.Command, args []string) {
			// load configure
			cnf := configure.Single()
			e := cnf.Load(filename)
			if e != nil {
				log.Fatalln(e)
			}
			e = cnf.Format(basePath)
			if e != nil {
				log.Fatalln(e)
			}

			// init logger
			e = logger.Init(basePath, &cnf.Logger)
			if e != nil {
				log.Fatalln(e)
			}

			// run
			daemon.Run()
		},
	}
	flags := cmd.Flags()
	flags.StringVarP(&filename, "config",
		"c",
		utils.Abs(basePath, "server.jsonnet"),
		"configure file",
	)
	rootCmd.AddCommand(cmd)
}
