--RR－フォース・ストリクス
-- 效果：
-- 4星怪兽×2
-- ①：这张卡的攻击力·守备力上升自己场上的其他的鸟兽族怪兽数量×500。
-- ②：1回合1次，把这张卡1个超量素材取除才能发动。从卡组把1只鸟兽族·暗属性·4星怪兽加入手卡。
function c73347079.initial_effect(c)
	-- 设置超量召唤手续：4星怪兽×2。
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- ①：这张卡的攻击力·守备力上升自己场上的其他的鸟兽族怪兽数量×500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(c73347079.adval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	-- ②：1回合1次，把这张卡1个超量素材取除才能发动。从卡组把1只鸟兽族·暗属性·4星怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(c73347079.thcost)
	e3:SetTarget(c73347079.thtg)
	e3:SetOperation(c73347079.thop)
	c:RegisterEffect(e3)
end
-- 过滤条件：场上表侧表示的鸟兽族怪兽。
function c73347079.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_WINDBEAST)
end
-- 攻击力·守备力上升数值的计算函数。
function c73347079.adval(e,c)
	-- 返回自己场上除自身以外的表侧表示鸟兽族怪兽数量×500的数值。
	return Duel.GetMatchingGroupCount(c73347079.filter,c:GetControler(),LOCATION_MZONE,0,c)*500
end
-- 效果发动代价：取除这张卡的1个超量素材。
function c73347079.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤条件：卡组中4星、鸟兽族、暗属性且能加入手牌的怪兽。
function c73347079.thfilter(c)
	return c:IsLevel(4) and c:IsRace(RACE_WINDBEAST) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToHand()
end
-- 效果发动目标：确认卡组中是否存在符合条件的怪兽，并设置检索的操作信息。
function c73347079.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1只符合条件的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c73347079.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果运行空间：从卡组选择1只符合条件的怪兽加入手牌并给对方确认。
function c73347079.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1只符合条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c73347079.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
