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
-- 检查事件是否为对方玩家受到战斗伤害，且攻击对象为空（即直接攻击）
function c22537443.reccon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认伤害来源不是自己，且没有攻击目标（表示是直接攻击造成的伤害）
	return ep~=tp and Duel.GetAttackTarget()==nil
end
-- 设置回复效果的目标玩家和参数，并记录操作信息以便后续处理
function c22537443.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前效果的目标玩家设为自己（tp）
	Duel.SetTargetPlayer(tp)
	-- 将当前效果的参数设为战斗伤害的数值（ev）
	Duel.SetTargetParam(ev)
	-- 设置操作信息，表明这是一个回复LP的效果，回复量为ev，由自己执行
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,ev)
end
-- 从连锁中获取之前设置的目标玩家和回复数值，并执行回复LP的操作
function c22537443.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的目标玩家和参数，即之前设置的tp和ev
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因使目标玩家回复指定数值的基本分
	Duel.Recover(p,d,REASON_EFFECT)
end
