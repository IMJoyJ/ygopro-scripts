--魔轟神グリムロ
-- 效果：
-- ①：自己场上有「魔轰神」怪兽存在的场合，把这张卡从手卡送去墓地才能发动。从卡组把「魔轰神 葛琳萝」以外的1只「魔轰神」怪兽加入手卡。
function c24040093.initial_effect(c)
	-- ①：自己场上有「魔轰神」怪兽存在的场合，把这张卡从手卡送去墓地才能发动。从卡组把「魔轰神 葛琳萝」以外的1只「魔轰神」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(24040093,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c24040093.con)
	e1:SetCost(c24040093.cost)
	e1:SetTarget(c24040093.tg)
	e1:SetOperation(c24040093.op)
	c:RegisterEffect(e1)
end
-- 过滤条件：卡片为表侧表示且属于「魔轰神」系列，用于判定自己场上是否存在满足条件的怪兽。
function c24040093.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x35)
end
-- 发动条件判定：自己场上有表侧表示的「魔轰神」怪兽存在。
function c24040093.con(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上主要怪兽区域是否存在至少1只表侧表示的「魔轰神」怪兽，满足条件才能发动。
	return Duel.IsExistingMatchingCard(c24040093.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 代价处理：先确认这张卡能否作为代价送去墓地，若可以则将其从手卡送去墓地作为发动代价。
function c24040093.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将这张卡本身从手卡送去墓地，作为发动效果所需支付的代价。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 检索目标过滤：是「魔轰神」怪兽、不是「魔轰神 葛琳萝」自身、并且可以加入手卡。
function c24040093.filter(c)
	return c:IsSetCard(0x35) and c:IsType(TYPE_MONSTER) and not c:IsCode(24040093) and c:IsAbleToHand()
end
-- 目标阶段：检查卡组是否存在符合条件的检索目标，并设置效果处理信息为从卡组将怪兽加入手牌。
function c24040093.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时检查卡组中是否存在至少1张满足检索条件的「魔轰神」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c24040093.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果处理为从卡组把1张卡加入手牌的检索效果。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：选择1张符合条件的「魔轰神」怪兽加入手牌，并向对方展示该卡。
function c24040093.op(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，要求玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中挑选1张满足条件的「魔轰神」怪兽作为效果对象。
	local g=Duel.SelectMatchingCard(tp,c24040093.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入其持有者的手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡，以公开检索到的卡片信息。
		Duel.ConfirmCards(1-tp,g)
	end
end
