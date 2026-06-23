--災いの像
-- 效果：
-- 当这张卡因对方控制的卡的效果从手卡被送去墓地时，给与对方基本分2000分的伤害。
function c12160911.initial_effect(c)
	-- 当这张卡因对方控制的卡的效果从手卡被送去墓地时，给与对方基本分2000分的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12160911,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c12160911.condition)
	e1:SetTarget(c12160911.target)
	e1:SetOperation(c12160911.operation)
	c:RegisterEffect(e1)
end
-- 效果触发条件判断函数
function c12160911.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND) and rp==1-tp and bit.band(r,REASON_EFFECT)==REASON_EFFECT
end
-- 效果处理目标设定函数
function c12160911.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁处理的目标参数为2000点伤害
	Duel.SetTargetParam(2000)
	-- 设置连锁操作信息为对对方造成2000点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,2000)
end
-- 效果处理执行函数
function c12160911.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家和伤害值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成指定伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
