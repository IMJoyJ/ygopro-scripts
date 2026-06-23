--奇跡の穿孔
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组把1只4星以下的岩石族怪兽送去墓地。自己墓地有「化石融合」存在的场合，再让自己从卡组抽1张。
function c44297127.initial_effect(c)
	-- 记录此卡与「化石融合」之间的关联
	aux.AddCodeList(c,59419719)
	-- ①：从卡组把1只4星以下的岩石族怪兽送去墓地。自己墓地有「化石融合」存在的场合，再让自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,44297127+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c44297127.target)
	e1:SetOperation(c44297127.activate)
	c:RegisterEffect(e1)
end
-- 定义过滤函数，用于筛选4星以下的岩石族怪兽
function c44297127.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_ROCK) and c:IsLevelBelow(4) and c:IsAbleToGrave()
end
-- 判断是否满足发动条件，检查卡组是否存在符合条件的怪兽以及是否可以抽卡
function c44297127.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在「化石融合」
	local draw=Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,59419719)
	-- 检查卡组中是否存在符合条件的岩石族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c44297127.tgfilter,tp,LOCATION_DECK,0,1,nil)
		-- 若墓地无「化石融合」则无需检查抽卡条件，否则检查是否可以抽卡
		and (not draw or Duel.IsPlayerCanDraw(tp,1)) end
	-- 设置效果处理时将要送去墓地的卡
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	if draw then
		-- 设置效果处理时将要抽卡的数量
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	end
end
-- 效果发动时执行的操作，包括选择怪兽送去墓地并可能抽卡
function c44297127.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择1只符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c44297127.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 确认选择的怪兽成功送去墓地且位于墓地
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)~=0 and g:GetFirst():IsLocation(LOCATION_GRAVE)
		-- 确认自己墓地存在「化石融合」
		and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,59419719) then
		-- 中断当前效果处理，使后续效果不与当前效果同时处理
		Duel.BreakEffect()
		-- 让玩家从卡组抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
