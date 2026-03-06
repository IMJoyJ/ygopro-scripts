--セベクの祝福
-- 效果：
-- ①：自己怪兽直接攻击给与对方战斗伤害时才能发动。自己基本分回复那个数值。
function c22537443.initial_effect(c)
	-- ①：自己怪兽直接攻击给与对方战斗伤害时才能发动。自己基本分回复那个数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(c22537443.reccon)
	e1:SetTarget(c22537443.rectg)
	e1:SetOperation(c22537443.recop)
	c:RegisterEffect(e1)
end
-- 效果作用
function c22537443.reccon(e,tp,eg,ep,ev,re,r,rp)
	-- 满足条件：造成战斗伤害的玩家不是自己且攻击怪兽没有攻击目标
	return ep~=tp and Duel.GetAttackTarget()==nil
end
-- 效果作用
function c22537443.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果的目标玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置效果的目标参数为造成的战斗伤害值
	Duel.SetTargetParam(ev)
	-- 设置连锁操作信息为回复效果，目标玩家为自己，回复值为伤害值
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,ev)
end
-- 效果作用
function c22537443.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中目标玩家和目标参数（即伤害值）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 使目标玩家回复目标参数值的LP，原因效果
	Duel.Recover(p,d,REASON_EFFECT)
end
