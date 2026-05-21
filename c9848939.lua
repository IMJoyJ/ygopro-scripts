--樹海の射手
-- 效果：
-- 这张卡不能通常召唤。自己墓地通常怪兽有2只以上存在的场合才能特殊召唤。可以把这张卡解放，从自己卡组把1只二重怪兽加入手卡。
function c9848939.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 自己墓地通常怪兽有2只以上存在的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c9848939.spcon)
	c:RegisterEffect(e2)
	-- 可以把这张卡解放，从自己卡组把1只二重怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(9848939,0))  --"检索"
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c9848939.cost)
	e3:SetTarget(c9848939.target)
	e3:SetOperation(c9848939.operation)
	c:RegisterEffect(e3)
end
-- 特殊召唤规则的条件函数：检查怪兽区域是否有空位，以及自己墓地是否存在2张以上的通常怪兽
function c9848939.spcon(e,c)
	if c==nil then return true end
	-- 检查自己场上是否有可以用于特殊召唤怪兽的空位
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
		-- 检查自己墓地是否存在至少2只通常怪兽
		Duel.IsExistingMatchingCard(Card.IsType,c:GetControler(),LOCATION_GRAVE,0,2,nil,TYPE_NORMAL)
end
-- 效果发动的代价函数：检查自身是否可以解放，并执行解放操作
function c9848939.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动效果的代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤条件：卡片是二重怪兽且能加入手卡
function c9848939.filter(c)
	return c:IsType(TYPE_DUAL) and c:IsAbleToHand()
end
-- 效果发动的目标函数：检查卡组中是否存在可检索的二重怪兽，并设置将卡加入手卡的操作信息
function c9848939.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1只满足过滤条件的二重怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c9848939.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置当前连锁的操作信息为：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理的执行函数：从卡组选择1只二重怪兽加入手卡并给对方确认
function c9848939.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1只满足条件的二重怪兽
	local g=Duel.SelectMatchingCard(tp,c9848939.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
