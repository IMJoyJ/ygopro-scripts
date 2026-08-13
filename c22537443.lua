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
-- 条件判定函数：判定战斗伤害时点是否满足发动条件，要求受到战斗伤害的是对方玩家（ep~=tp），且该伤害来自直接攻击（场上没有攻击对象怪兽，Duel.GetAttackTarget()==nil）。
function c22537443.reccon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定条件：对方玩家受到战斗伤害且攻击对象为空（直接攻击）时，本效果满足发动条件。
	return ep~=tp and Duel.GetAttackTarget()==nil
end
-- 目标处理函数：发动合法性检查时直接放行；正式发动时登记回复对象玩家为自己（tp）、回复数值为本次战斗伤害值（ev），并设置回复LP的操作信息。
function c22537443.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设置为效果发动者自身（tp），即本效果回复基本分的对象是自己。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设置为战斗伤害数值ev，作为随后回复LP的数值。
	Duel.SetTargetParam(ev)
	-- 登记操作信息：本连锁为回复基本分（CATEGORY_RECOVER）效果，不取卡片对象，目标玩家为tp，回复值为ev，供连锁判定和处理时使用。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,ev)
end
-- 效果处理函数：从连锁信息中读取目标玩家和回复数值，对目标玩家执行基本分回复，完成效果处理。
function c22537443.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取得目标玩家p和目标参数d（回复数值），分别赋给局部变量p和d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因（REASON_EFFECT）让玩家p回复d点基本分（LP）。
	Duel.Recover(p,d,REASON_EFFECT)
end
