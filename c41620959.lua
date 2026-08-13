--竜の霊廟
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组把1只龙族怪兽送去墓地。这个效果送去墓地的怪兽是龙族通常怪兽的场合，可以再从卡组把1只龙族怪兽送去墓地。
function c41620959.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从卡组把1只龙族怪兽送去墓地。这个效果送去墓地的怪兽是龙族通常怪兽的场合，可以再从卡组把1只龙族怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,41620959+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c41620959.target)
	e1:SetOperation(c41620959.activate)
	c:RegisterEffect(e1)
end
-- 定义筛选函数：判断卡是否为龙族怪兽且可以被送去墓地。
function c41620959.tgfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsAbleToGrave()
end
-- 发动时的目标处理：检查是否满足发动条件（卡组存在可送墓的龙族怪兽），并设置本次效果将把卡送去墓地的操作信息。
function c41620959.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时（chk==0）检查卡组是否存在至少1只满足条件的龙族怪兽，作为发动是否合法的条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c41620959.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本次效果处理的操作信息：效果分类为送去墓地，预计从卡组送去墓地1张卡（处理时选择目标，因此目标暂不指定）。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1只龙族怪兽送去墓地，若该怪兽是龙族通常怪兽且卡组仍有龙族怪兽可送，则询问是否再选1只送去墓地。
function c41620959.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送“请选择要送去墓地的卡”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1只满足条件的龙族怪兽。
	local g=Duel.SelectMatchingCard(tp,c41620959.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	-- 判断第一张卡是否成功因效果送去墓地，且该卡在墓地中同时满足龙族、通常怪兽的条件。
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_GRAVE) and tc:IsRace(RACE_DRAGON) and tc:IsType(TYPE_NORMAL)
		-- 判断卡组中是否还存在至少1只可以送去墓地的龙族怪兽。
		and Duel.IsExistingMatchingCard(c41620959.tgfilter,tp,LOCATION_DECK,0,1,nil)
		-- 询问玩家是否再发动追加处理，从卡组把1只龙族怪兽送去墓地。
		and Duel.SelectYesNo(tp,aux.Stringid(41620959,0)) then  --"是否再从卡组把1只龙族怪兽送去墓地？"
		-- 再次向玩家发送“请选择要送去墓地的卡”的提示消息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 让玩家从卡组再选择1只满足条件的龙族怪兽。
		local g1=Duel.SelectMatchingCard(tp,c41620959.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
		-- 将第二张选择的龙族怪兽因效果送去墓地。
		Duel.SendtoGrave(g1,REASON_EFFECT)
	end
end
