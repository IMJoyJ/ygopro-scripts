--氷水揺籃
-- 效果：
-- ①：同名卡不在自己的场上·墓地存在的1只「冰水」怪兽从卡组加入手卡。
function c55343303.initial_effect(c)
	-- ①：同名卡不在自己的场上·墓地存在的1只「冰水」怪兽从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c55343303.thtg)
	e1:SetOperation(c55343303.thop)
	c:RegisterEffect(e1)
end
-- 过滤函数：检查场上表侧表示或不在场上（即墓地中）是否存在指定卡名的卡
function c55343303.cfilter(c,code)
	return c:IsCode(code) and (c:IsFaceup() or not c:IsOnField())
end
-- 过滤函数：筛选卡组中满足“同名卡不在自己场上·墓地存在”的「冰水」怪兽
function c55343303.thfilter(c,tp)
	return c:IsSetCard(0x16c) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
		-- 检查自己的场上（表侧表示）和墓地中是否不存在该卡名的同名卡
		and not Duel.IsExistingMatchingCard(c55343303.cfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil,c:GetCode())
end
-- 效果发动的Target函数：检查卡组中是否存在可检索的卡，并设置操作信息
function c55343303.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段（chk==0）检查卡组中是否存在至少1只满足条件的「冰水」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c55343303.thfilter,tp,LOCATION_DECK,0,1,nil,tp) end
	-- 设置操作信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理的Operation函数：从卡组选择1只满足条件的「冰水」怪兽加入手卡并给对方确认
function c55343303.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1只满足条件的「冰水」怪兽
	local g=Duel.SelectMatchingCard(tp,c55343303.thfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
