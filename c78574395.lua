--ワンダー・バルーン
-- 效果：
-- ①：1回合1次，把手卡任意数量送去墓地才能发动。送去墓地的那个数量的气球指示物给这张卡放置。
-- ②：只要这张卡在魔法与陷阱区域存在，对方场上的怪兽的攻击力下降这张卡的气球指示物数量×300。
function c78574395.initial_effect(c)
	c:EnableCounterPermit(0x32)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，把手卡任意数量送去墓地才能发动。送去墓地的那个数量的气球指示物给这张卡放置。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(78574395,0))
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c78574395.cost)
	e2:SetTarget(c78574395.target)
	e2:SetOperation(c78574395.operation)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在魔法与陷阱区域存在，对方场上的怪兽的攻击力下降这张卡的气球指示物数量×300。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetValue(c78574395.atkval)
	c:RegisterEffect(e3)
end
c78574395.mentioned_counter={
	[0x32]=true,
}
-- 攻击力下降数值计算：此卡的气球指示物数量×300
function c78574395.atkval(e,c)
	return e:GetHandler():GetCounter(0x32)*-300
end
-- 放置指示物效果的发动代价：将手牌任意数量的卡送去墓地
function c78574395.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：手牌中是否存在可以送去墓地的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
	-- 把手卡任意数量的卡送去墓地，并记录数量
	local ct=Duel.DiscardHand(tp,Card.IsAbleToGraveAsCost,1,60,REASON_COST)
	e:SetLabel(ct)
end
-- 放置指示物效果的发动准备
function c78574395.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanAddCounter(0x32,1) end
	-- 设置连锁操作信息：放置对应代价数量的气球指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,e:GetLabel(),0,0x32)
end
-- 放置指示物效果处理：给这张卡放置送去墓地数量的气球指示物
function c78574395.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		c:AddCounter(0x32,e:GetLabel())
	end
end
