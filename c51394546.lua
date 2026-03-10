--セメタリー・ボム
-- 效果：
-- 对方受到对方墓地卡数×100的伤害。
function c51394546.initial_effect(c)
	-- 对方受到对方墓地卡数×100的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_TOGRAVE+TIMING_END_PHASE)
	e1:SetTarget(c51394546.target)
	e1:SetOperation(c51394546.activate)
	c:RegisterEffect(e1)
end
-- 效果作用
function c51394546.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方墓地是否有卡
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_GRAVE)>0 end
	-- 设置伤害对象为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 计算对方墓地卡数并乘以100作为伤害值
	local dam=Duel.GetFieldGroupCount(tp,0,LOCATION_GRAVE)*100
	-- 设置连锁操作参数为伤害值
	Duel.SetTargetParam(dam)
	-- 设置连锁操作信息为伤害效果
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 效果作用
function c51394546.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 再次计算对方墓地卡数并乘以100作为伤害值
	local dam=Duel.GetFieldGroupCount(1-tp,LOCATION_GRAVE,0)*100
	-- 对目标玩家造成指定伤害
	Duel.Damage(p,dam,REASON_EFFECT)
end
