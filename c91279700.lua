--ヴェルズ・オピオン
-- 效果：
-- 4星「入魔」怪兽×2
-- ①：只要持有超量素材的这张卡在怪兽区域存在，双方不能把5星以上的怪兽特殊召唤。
-- ②：1回合1次，把这张卡1个超量素材取除才能发动。从卡组把1张「侵略的」魔法·陷阱卡加入手卡。
function c91279700.initial_effect(c)
	-- 设置超量召唤手续：4星「入魔」怪兽×2
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0xa),4,2)
	c:EnableReviveLimit()
	-- ①：只要持有超量素材的这张卡在怪兽区域存在，双方不能把5星以上的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,1)
	e1:SetTarget(c91279700.sumlimit)
	e1:SetCondition(c91279700.dscon)
	c:RegisterEffect(e1)
	-- ②：1回合1次，把这张卡1个超量素材取除才能发动。从卡组把1张「侵略的」魔法·陷阱卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(91279700,0))  --"加入手卡"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c91279700.cost)
	e2:SetTarget(c91279700.target)
	e2:SetOperation(c91279700.operation)
	c:RegisterEffect(e2)
end
-- 判断自身是否持有超量素材，作为永续效果的适用条件
function c91279700.dscon(e)
	return e:GetHandler():GetOverlayCount()~=0
end
-- 限制特殊召唤的怪兽等级为5星以上
function c91279700.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return c:IsLevelAbove(5)
end
-- 去除1个超量素材的代价检测与执行
function c91279700.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤卡组中「侵略的」魔法·陷阱卡且能加入手牌的卡
function c91279700.filter(c)
	return c:IsSetCard(0x65) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 检测卡组中是否存在符合条件的卡，并设置将卡加入手牌的效果处理信息
function c91279700.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动效果前，检测我方卡组是否存在至少1张满足条件的「侵略的」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c91279700.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息，表示该效果会将我方卡组的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 从卡组选择1张「侵略的」魔法·陷阱卡加入手牌并给对方确认
function c91279700.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的「侵略的」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,c91279700.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡给对方玩家确认
		Duel.ConfirmCards(1-tp,g)
	end
end
