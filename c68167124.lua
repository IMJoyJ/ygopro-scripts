--針剣士
-- 效果：
-- 这张卡给与对方基本分战斗伤害时，对方的魔法与陷阱卡区域表侧表示存在的卡全部回到持有者手卡。
function c68167124.initial_effect(c)
	-- 这张卡给与对方基本分战斗伤害时，对方的魔法与陷阱卡区域表侧表示存在的卡全部回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(68167124,0))  --"返回手牌"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(c68167124.condition)
	e1:SetTarget(c68167124.target)
	e1:SetOperation(c68167124.operation)
	c:RegisterEffect(e1)
end
-- 判断造成战斗伤害的对象是否为对方玩家
function c68167124.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 过滤出表侧表示且位于魔法与陷阱区域（序号小于5，即不包括场地区）的卡片
function c68167124.filter(c)
	return c:IsFaceup() and c:GetSequence()<5
end
-- 效果发动的目标确认，由于是必发效果，直接返回true，并设置将对方魔陷区表侧表示卡片送回手牌的操作信息
function c68167124.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取对方魔法与陷阱卡区域表侧表示存在的卡片组
	local g=Duel.GetMatchingGroup(c68167124.filter,tp,0,LOCATION_SZONE,nil)
	-- 设置效果处理信息为将对方魔陷区表侧表示的卡片送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果处理，获取对方魔陷区表侧表示的卡片并将其全部送回持有者手牌
function c68167124.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时对方魔法与陷阱卡区域表侧表示存在的卡片组
	local g=Duel.GetMatchingGroup(c68167124.filter,tp,0,LOCATION_SZONE,nil)
	-- 将目标卡片全部送回持有者的手牌
	Duel.SendtoHand(g,nil,REASON_EFFECT)
end
