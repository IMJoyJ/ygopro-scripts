--ブロッサム・ボンバー
-- 效果：
-- 自己场上存在的植物族怪兽战斗破坏对方怪兽送去墓地时才能发动。给与对方基本分那次战斗破坏的怪兽的攻击力数值的伤害。
function c13438207.initial_effect(c)
	-- 自己场上存在的植物族怪兽战斗破坏对方怪兽送去墓地时才能发动。给与对方基本分那次战斗破坏的怪兽的攻击力数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetCondition(c13438207.condition)
	e1:SetTarget(c13438207.target)
	e1:SetOperation(c13438207.activate)
	c:RegisterEffect(e1)
end
-- 效果发动条件判定：取出被战斗破坏的对方怪兽及其战斗对象，确认被破坏怪兽与本次战斗关联、曾与对方怪兽战斗、控制者为自己且种族为植物族，同时其战斗对象因战斗被破坏并处于墓地。
function c13438207.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local bc=tc:GetBattleTarget()
	return tc:IsRelateToBattle() and tc:IsStatus(STATUS_OPPO_BATTLE) and tc:IsControler(tp) and tc:IsRace(RACE_PLANT)
		and bc:IsLocation(LOCATION_GRAVE) and bc:IsReason(REASON_BATTLE)
end
-- 发动时的目标设定：确认可发动后，将伤害对象设为对方玩家，并计算被战斗破坏的对方怪兽的攻击力作为伤害值（攻击力为负时按0处理），同时登记操作信息。
function c13438207.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设置为对方玩家，作为伤害的承受者。
	Duel.SetTargetPlayer(1-tp)
	local atk=eg:GetFirst():GetBattleTarget():GetAttack()
	if atk<0 then atk=0 end
	-- 将当前连锁的对象参数设置为伤害数值，即被战斗破坏的对方怪兽的攻击力（负数按0处理）。
	Duel.SetTargetParam(atk)
	-- 登记当前连锁的操作信息：效果分类为伤害效果，目标玩家为对方，预计伤害值为atk，供其他效果检测与处理。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,atk)
end
-- 效果处理函数：从连锁信息中读取之前预设的伤害对象玩家和伤害数值，对对方玩家造成等量的效果伤害。
function c13438207.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中获取之前设置的对象玩家p和伤害参数d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 给予玩家p以d点数值的效果伤害，伤害原因记为效果。
	Duel.Damage(p,d,REASON_EFFECT)
end
