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
-- 效果发动时的目标处理函数：检查发动条件，将对方玩家设为对象，计算伤害值并设定为对象参数，同时写入操作信息。
function c24068492.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：只有对方场上有1只以上怪兽时，该效果才满足发动条件。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 将本连锁的效果对象玩家设置为对方玩家（1-tp），表明伤害对象为对方。
	Duel.SetTargetPlayer(1-tp)
	-- 计算对方场上怪兽数量并乘以500，得到本次效果应给予的伤害值。
	local dam=Duel.GetFieldGroupCount(1-tp,LOCATION_MZONE,0)*500
	-- 将计算出的伤害数值设为当前连锁的对象参数，供效果处理时使用。
	Duel.SetTargetParam(dam)
	-- 写入连锁的操作信息：效果类别为伤害，针对的玩家是对方，预估伤害值为dam，以便其他卡片/效果正确响应。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 效果处理函数：从连锁信息中取出对象玩家，重新计算对方场上当前怪兽数量×500的伤害值，并对该玩家造成伤害。
function c24068492.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中获取效果对象玩家（即之前设置的对方玩家）。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 在处理阶段重新统计对方场上怪兽数量并乘以500，以决定实际造成的伤害值。
	local dam=Duel.GetFieldGroupCount(1-tp,LOCATION_MZONE,0)*500
	-- 以效果原因对玩家p造成dam点伤害。
	Duel.Damage(p,dam,REASON_EFFECT)
end
