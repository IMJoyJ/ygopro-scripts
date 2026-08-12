--ベアルクティ・ディパーチャー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：丢弃1张手卡才能发动。从卡组把2只「北极天熊」怪兽加入手卡。
-- ②：自己为让「北极天熊」怪兽的效果发动而把怪兽解放的场合，可以作为代替把墓地的这张卡除外。这个效果在这张卡送去墓地的回合不能使用。
function c16471775.initial_effect(c)
	-- ①：丢弃1张手卡才能发动。从卡组把2只「北极天熊」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,16471775)
	e1:SetCost(c16471775.cost)
	e1:SetTarget(c16471775.target)
	e1:SetOperation(c16471775.activate)
	c:RegisterEffect(e1)
	-- ②：自己为让「北极天熊」怪兽的效果发动而把怪兽解放的场合，可以作为代替把墓地的这张卡除外。这个效果在这张卡送去墓地的回合不能使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(16471775)
	e2:SetRange(LOCATION_GRAVE)
	-- 设置效果条件为：这张卡送去墓地的回合不能发动这个效果
	e2:SetCondition(aux.exccon)
	e2:SetCountLimit(1,16471776)
	c:RegisterEffect(e2)
end
-- 效果发动时的费用处理：丢弃1张手卡
function c16471775.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否满足丢弃手卡的条件
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,c) end
	-- 执行丢弃1张手卡的操作
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD,nil)
end
-- 检索过滤函数：选择怪兽卡且为北极天熊卡组且可以加入手牌的卡
function c16471775.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x163) and c:IsAbleToHand()
end
-- 效果发动时的处理目标设定：从卡组检索2只北极天熊怪兽
function c16471775.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的2张怪兽卡
	if chk==0 then return Duel.IsExistingMatchingCard(c16471775.filter,tp,LOCATION_DECK,0,2,nil) end
	-- 设置连锁操作信息：将2张卡从卡组加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
-- 效果发动时的处理执行：选择并加入手牌2只北极天熊怪兽
function c16471775.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的2张卡
	local g=Duel.SelectMatchingCard(tp,c16471775.filter,tp,LOCATION_DECK,0,2,2,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
