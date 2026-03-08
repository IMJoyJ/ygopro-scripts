--竜の霊廟
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组把1只龙族怪兽送去墓地。这个效果送去墓地的怪兽是龙族通常怪兽的场合，可以再从卡组把1只龙族怪兽送去墓地。
function c41620959.initial_effect(c)
	-- 创建效果，设置为发动时点，可以发动一次，效果分类为送去墓地
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,41620959+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c41620959.target)
	e1:SetOperation(c41620959.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选龙族且可以送去墓地的怪兽
function c41620959.tgfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsAbleToGrave()
end
-- 效果的发动条件判断，检查是否满足发动条件
function c41620959.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否在卡组中存在至少一张龙族且可以送去墓地的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c41620959.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理时的操作信息，表示将要从卡组送去墓地的卡
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，执行效果的处理逻辑
function c41620959.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组中选择一张龙族且可以送去墓地的怪兽
	local g=Duel.SelectMatchingCard(tp,c41620959.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	-- 判断所选怪兽是否成功送去墓地且为龙族通常怪兽
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_GRAVE) and tc:IsRace(RACE_DRAGON) and tc:IsType(TYPE_NORMAL)
		-- 检查卡组中是否还存在满足条件的龙族怪兽
		and Duel.IsExistingMatchingCard(c41620959.tgfilter,tp,LOCATION_DECK,0,1,nil)
		-- 询问玩家是否再从卡组送去一张龙族怪兽
		and Duel.SelectYesNo(tp,aux.Stringid(41620959,0)) then  --"是否再从卡组把1只龙族怪兽送去墓地？"
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 从卡组中选择一张龙族且可以送去墓地的怪兽
		local g1=Duel.SelectMatchingCard(tp,c41620959.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
		-- 将所选怪兽送去墓地
		Duel.SendtoGrave(g1,REASON_EFFECT)
	end
end
