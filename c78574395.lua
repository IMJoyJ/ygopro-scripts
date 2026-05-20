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
-- 计算攻击力下降的数值，为这张卡的气球指示物数量×300
function c78574395.atkval(e,c)
	return e:GetHandler():GetCounter(0x32)*-300
end
-- 效果①的代价处理：玩家将手卡任意数量的卡送去墓地，并记录送去墓地的卡片数量
function c78574395.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段（chk==0）检查手牌中是否存在至少1张可以作为代价送去墓地的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家选择手卡任意数量（1到60张）可以送去墓地的卡送去墓地，并返回实际送去墓地的卡片数量
	local ct=Duel.DiscardHand(tp,Card.IsAbleToGraveAsCost,1,60,REASON_COST)
	e:SetLabel(ct)
end
-- 效果①的靶向处理：检查这张卡是否能放置气球指示物，并设置放置指示物的操作信息
function c78574395.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanAddCounter(0x32,1) end
	-- 设置操作信息，表示此效果的处理为放置对应数量的气球指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,e:GetLabel(),0,0x32)
end
-- 效果①的效果处理：若这张卡在场上表侧表示存在，则给这张卡放置对应数量的气球指示物
function c78574395.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		c:AddCounter(0x32,e:GetLabel())
	end
end
