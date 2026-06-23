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
-- 条件函数，用于判断是否满足发动花朵炸弹的效果条件
function c13438207.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local bc=tc:GetBattleTarget()
	return tc:IsRelateToBattle() and tc:IsStatus(STATUS_OPPO_BATTLE) and tc:IsControler(tp) and tc:IsRace(RACE_PLANT)
		and bc:IsLocation(LOCATION_GRAVE) and bc:IsReason(REASON_BATTLE)
end
-- 目标设定函数，用于设置伤害效果的目标玩家和伤害值
function c13438207.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将连锁效果的目标玩家设置为对手
	Duel.SetTargetPlayer(1-tp)
	local atk=eg:GetFirst():GetBattleTarget():GetAttack()
	if atk<0 then atk=0 end
	-- 将连锁效果的目标参数设置为战斗破坏怪兽的攻击力
	Duel.SetTargetParam(atk)
	-- 设置连锁操作信息为伤害效果，目标玩家为对手，伤害值为攻击力
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,atk)
end
-- 效果发动时的处理函数，用于执行伤害效果
function c13438207.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成指定数值的伤害，伤害原因为效果
	Duel.Damage(p,d,REASON_EFFECT)
end
