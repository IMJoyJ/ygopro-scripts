--義賊の入門書
-- 效果：
-- 对方手卡有5张以上时才能发动。对方随机丢弃1张手卡。
function c69091732.initial_effect(c)
	-- 对方手卡有5张以上时才能发动。对方随机丢弃1张手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_HANDES_OPPO)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetHintTiming(0,TIMING_TOHAND)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c69091732.condition)
	e1:SetTarget(c69091732.target)
	e1:SetOperation(c69091732.activate)
	c:RegisterEffect(e1)
end
-- 发动条件判定函数
function c69091732.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方手卡数量是否在5张以上（大于4张）
	return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>4
end
-- 效果发动时的目标选择与操作信息注册函数
function c69091732.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的对象玩家为对方
	Duel.SetTargetPlayer(1-tp)
	Duel.SetOperationInfo(0,CATEGORY_HANDES_OPPO,nil,0,1-tp,1)
end
-- 效果处理的执行函数
function c69091732.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象玩家（即对方玩家）
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 获取该玩家的所有手卡
	local g=Duel.GetFieldGroup(p,LOCATION_HAND,0)
	local dg=g:RandomSelect(tp,1)
	-- 将随机选出的卡片以效果丢弃的方式送去墓地
	Duel.SendtoGrave(dg,REASON_EFFECT+REASON_DISCARD)
end
