from pathlib import Path

for root in ['/tmp/openhands-bulk-proof-repo', '/tmp/openhands-bulk-proof-baseline']:
    scripts = Path(root) / '.agents/skills/verify-openhands/scripts'
    daemon = scripts / 'browser-daemon.mjs'
    source = daemon.read_text()
    anchor = '  async tabs() {'
    addition = '''  async offline({ enabled }) {
    if (typeof enabled !== "boolean") throw new Error("offline requires a boolean");
    await context.setOffline(enabled);
    return { offline: enabled, online: await activePage.evaluate(() => navigator.onLine) };
  },
'''
    assert anchor in source and 'async offline(' not in source
    daemon.with_suffix('.mjs.tmp').write_text(source.replace(anchor, addition + anchor))
    cli = scripts / 'control-openhands.mjs'
    source = cli.read_text()
    anchor = '    case "tab":\n'
    addition = '''    case "offline":
      need(1, "control-openhands browser offline on|off");
      if (!["on", "off"].includes(rest[0])) throw new Error("offline requires on|off");
      result = await browserCall(run, "offline", { enabled: rest[0] === "on" });
      break;
'''
    assert anchor in source
    source = source.replace(anchor, addition + anchor)
    source = source.replace('  tabs | tab <i>', '  offline on|off   disconnect/reconnect the real browser network (no response mocking)\n  tabs | tab <i>')
    cli.with_suffix('.mjs.tmp').write_text(source)
    import subprocess
    for path in [daemon, cli]:
        staged = path.with_suffix('.mjs.tmp')
        # Node's check command requires a recognized JavaScript suffix.
        check = path.with_name(path.stem + '-check.mjs')
        staged.rename(check)
        subprocess.run(['/tmp/openhands-bulk-proof-tools/node-v24.11.1-linux-x64/bin/node', '--check', str(check)], check=True)
        check.replace(path)
    print(root + ': offline command installed; both syntax checks passed')
