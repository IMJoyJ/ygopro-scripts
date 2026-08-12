--自業自得
-- 效果：
-- ①：给与对方为对方场上的怪兽数量×500伤害。
function c24068492.initial_effect(c)
	-- ①：给与对方为对方场上的怪兽数量×500伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,0x1c1)
	e1:SetTarget(c24068492.target)
	e1:SetOperation(c24068492.activate)
	c:RegisterEffect(e1)
end
-- 定义效果的目标处理函数：检查对方场上有怪兽，设置目标玩家和伤害值，并登记伤害操作信息。
function c24068492.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动条件检查中，确认对方主要怪兽区至少存在一只怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 设置效果的目标玩家为对方玩家。
	Duel.SetTargetPlayer(1-tp)
	-- 计算伤害值：对方场上怪兽数量乘以500。
	local dam=Duel.GetFieldGroupCount(1-tp,LOCATION_MZONE,0)*500
	-- 设置效果的目标参数为计算出的伤害值。
	Duel.SetTargetParam(dam)
	-- 设置操作信息：登记为伤害效果，目标玩家为对方，伤害值为计算值。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 定义效果的处理函数：获取目标玩家和伤害值，并给予对方相应伤害。
function c24068492.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中获取之前设置的目标玩家。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 在效果处理时重新计算伤害值：对方场上怪兽数量乘以500。
	local dam=Duel.GetFieldGroupCount(1-tp,LOCATION_MZONE,0)*500
	-- 执行伤害操作，给予目标玩家计算出的伤害值。
	Duel.Damage(p,dam,REASON_EFFECT)
end
