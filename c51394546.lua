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
-- 效果发动的目标确认与准备函数
function c51394546.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查发动条件：对方墓地的卡片数量是否大于0
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_GRAVE)>0 end
	-- 设置效果的对象玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 计算发动时的预计伤害值（对方墓地卡片数量×100）
	local dam=Duel.GetFieldGroupCount(tp,0,LOCATION_GRAVE)*100
	-- 设置效果的对象参数为预计伤害值
	Duel.SetTargetParam(dam)
	-- 设置操作信息为对对方造成伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 效果处理函数
function c51394546.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的对象玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 计算效果处理时对方墓地的卡片数量×100作为实际伤害值
	local dam=Duel.GetFieldGroupCount(1-tp,LOCATION_GRAVE,0)*100
	-- 给予目标玩家效果伤害
	Duel.Damage(p,dam,REASON_EFFECT)
end
