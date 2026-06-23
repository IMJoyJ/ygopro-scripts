--苦渋の決断
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组把1只4星以下的通常怪兽送去墓地，那1只同名怪兽从卡组加入手卡。
function c1033312.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从卡组把1只4星以下的通常怪兽送去墓地，那1只同名怪兽从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,1033312+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c1033312.target)
	e1:SetOperation(c1033312.activate)
	c:RegisterEffect(e1)
end
-- 过滤卡组中符合条件的4星以下通常怪兽，且卡组中还存在另一张同名卡
function c1033312.tgfilter(c,tp)
	return c:IsLevelBelow(4) and c:IsType(TYPE_NORMAL) and c:IsAbleToGrave()
		-- 且卡组中存在与自身同名且可以加入手卡的另一张卡
		and Duel.IsExistingMatchingCard(c1033312.thfilter,tp,LOCATION_DECK,0,1,c,c:GetCode())
end
-- 过滤卡组中与指定卡名相同且可以加入手卡的卡
function c1033312.thfilter(c,code)
	return c:IsCode(code) and c:IsAbleToHand()
end
-- 效果发动的目标
function c1033312.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组中是否存在可以送去墓地且有同名卡能加入手卡的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c1033312.tgfilter,tp,LOCATION_DECK,0,1,nil,tp) end
	-- 设置操作信息：从卡组将1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	-- 设置操作信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果发动的具体操作
function c1033312.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从自己卡组选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c1033312.tgfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
	local tc=g:GetFirst()
	-- 若选中的怪兽成功送去墓地并存在于墓地
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE) then
		-- 提示玩家选择要加入手卡的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从自己卡组选择1只与送墓怪兽同名的怪兽
		local sg=Duel.SelectMatchingCard(tp,c1033312.thfilter,tp,LOCATION_DECK,0,1,1,nil,tc:GetCode())
		if sg:GetCount()>0 then
			-- 将选中的同名怪兽加入手卡
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			-- 向对方玩家确认加入手卡的卡
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end
