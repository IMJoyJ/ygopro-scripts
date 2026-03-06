--魔轟神グリムロ
-- 效果：
-- ①：自己场上有「魔轰神」怪兽存在的场合，把这张卡从手卡送去墓地才能发动。从卡组把「魔轰神 葛琳萝」以外的1只「魔轰神」怪兽加入手卡。
function c24040093.initial_effect(c)
	-- 效果原文内容：①：自己场上有「魔轰神」怪兽存在的场合，把这张卡从手卡送去墓地才能发动。从卡组把「魔轰神 葛琳萝」以外的1只「魔轰神」怪兽加入手卡。
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
-- 过滤函数，用于判断场上是否存在表侧表示的「魔轰神」怪兽
function c24040093.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x35)
end
-- 效果条件函数，检查自己场上是否存在至少1只「魔轰神」怪兽
function c24040093.con(e,tp,eg,ep,ev,re,r,rp)
	-- 检查以自己为玩家，在自己的主要怪兽区是否存在至少1张满足cfilter条件的卡
	return Duel.IsExistingMatchingCard(c24040093.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果代价函数，将此卡从手卡送去墓地作为发动代价
function c24040093.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将此卡从手卡送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤函数，用于筛选卡组中满足条件的「魔轰神」怪兽（不包括葛琳萝）
function c24040093.filter(c)
	return c:IsSetCard(0x35) and c:IsType(TYPE_MONSTER) and not c:IsCode(24040093) and c:IsAbleToHand()
end
-- 效果目标函数，检查卡组中是否存在至少1张满足filter条件的卡，并设置操作信息
function c24040093.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查以自己为玩家，在卡组中是否存在至少1张满足filter条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c24040093.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示将从卡组检索1张「魔轰神」怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，选择并把符合条件的卡加入手牌
function c24040093.op(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足filter条件的卡
	local g=Duel.SelectMatchingCard(tp,c24040093.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认所选的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
