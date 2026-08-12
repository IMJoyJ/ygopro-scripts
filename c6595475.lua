--オノマト連携
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把1张手卡送去墓地才能发动。从卡组把以下怪兽之内各1只合计最多2只加入手卡。
-- ●「刷拉拉」怪兽
-- ●「我我我」怪兽
-- ●「隆隆隆」怪兽
-- ●「怒怒怒」怪兽
function c6595475.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：把1张手卡送去墓地才能发动。从卡组把以下怪兽之内各1只合计最多2只加入手卡。●「刷拉拉」怪兽●「我我我」怪兽●「隆隆隆」怪兽●「怒怒怒」怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,6595475+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c6595475.cost)
	e1:SetTarget(c6595475.target)
	e1:SetOperation(c6595475.activate)
	c:RegisterEffect(e1)
end
-- 定义发动代价：把1张手卡送去墓地
function c6595475.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在可以作为代价送去墓地的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 玩家选择并以发动代价将1张手牌送去墓地
	Duel.DiscardHand(tp,Card.IsAbleToGraveAsCost,1,1,REASON_COST)
end
-- 过滤条件：卡组中的「刷拉拉」、「我我我」、「隆隆隆」或「怒怒怒」怪兽，且能加入手牌
function c6595475.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x54,0x59,0x82,0x8f) and c:IsAbleToHand()
end
-- 定义发动时的效果目标检查与操作信息设置
function c6595475.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1只满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c6595475.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检查选择的怪兽组是否满足“各1只（不同系列）合计最多2只”的限制条件
function c6595475.check(g)
	if #g==1 then return true end
	local res=0x0
	if g:IsExists(Card.IsSetCard,1,nil,0x54) then res=res+0x1 end
	if g:IsExists(Card.IsSetCard,1,nil,0x59) then res=res+0x2 end
	if g:IsExists(Card.IsSetCard,1,nil,0x82) then res=res+0x4 end
	if g:IsExists(Card.IsSetCard,1,nil,0x8f) then res=res+0x8 end
	return res~=0x1 and res~=0x2 and res~=0x4 and res~=0x8
end
-- 定义效果处理：从卡组检索怪兽加入手牌
function c6595475.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中所有满足条件的怪兽
	local g=Duel.GetMatchingGroup(c6595475.filter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()==0 then return end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	local g1=g:SelectSubGroup(tp,c6595475.check,false,1,2)
	-- 将选中的怪兽加入手牌
	Duel.SendtoHand(g1,nil,REASON_EFFECT)
	-- 让对方玩家确认加入手牌的卡
	Duel.ConfirmCards(1-tp,g1)
end
