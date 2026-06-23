--スプリガンズ・ウォッチ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组把1张「大沙海 黄金戈尔工达」加入手卡。自己的场地区域有「大沙海 黄金戈尔工达」存在的场合，可以作为代替让以下效果适用。
-- ●从卡组把1只「护宝炮妖」怪兽加入手卡，从卡组把1只「护宝炮妖」怪兽送去墓地。
function c23499963.initial_effect(c)
	-- 记录此卡与「大沙海 黄金戈尔工达」的关联
	aux.AddCodeList(c,60884672)
	-- ①：从卡组把1张「大沙海 黄金戈尔工达」加入手卡。自己的场地区域有「大沙海 黄金戈尔工达」存在的场合，可以作为代替让以下效果适用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,23499963+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c23499963.target)
	e1:SetOperation(c23499963.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于检索卡组中可加入手牌的「大沙海 黄金戈尔工达」
function c23499963.filter(c)
	return c:IsCode(60884672) and c:IsAbleToHand()
end
-- 过滤函数，用于检索卡组中可加入手牌的「护宝炮妖」怪兽
function c23499963.thfilter(c,tp)
	-- 判断是否为「护宝炮妖」怪兽且可加入手牌，并确认卡组中存在可送去墓地的「护宝炮妖」怪兽
	return c:IsSetCard(0x155) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand() and Duel.IsExistingMatchingCard(c23499963.tgfilter,tp,LOCATION_DECK,0,1,c)
end
-- 过滤函数，用于检索卡组中可送去墓地的「护宝炮妖」怪兽
function c23499963.tgfilter(c)
	return c:IsSetCard(0x155) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 效果处理的初始化函数，判断是否满足发动条件并设置操作信息
function c23499963.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断当前是否处于「大沙海 黄金戈尔工达」场地效果下
	local b=Duel.IsEnvironment(60884672,tp,LOCATION_FZONE)
	-- 检查是否满足发动条件，即卡组中存在「大沙海 黄金戈尔工达」或「护宝炮妖」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c23499963.filter,tp,LOCATION_DECK,0,1,nil) or b and Duel.IsExistingMatchingCard(c23499963.thfilter,tp,LOCATION_DECK,0,1,nil,tp) end
	-- 设置操作信息，表示将从卡组检索1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置操作信息，表示将从卡组检索1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,0,tp,LOCATION_DECK)
end
-- 效果处理函数，根据是否满足条件决定执行哪种检索方式
function c23499963.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否处于「大沙海 黄金戈尔工达」场地效果下
	local b=Duel.IsEnvironment(60884672,tp,LOCATION_FZONE)
	-- 判断是否满足使用「护宝炮妖」效果的条件，包括场地存在、有可检索的「护宝炮妖」怪兽，以及玩家选择
	if b and Duel.IsExistingMatchingCard(c23499963.thfilter,tp,LOCATION_DECK,0,1,nil,tp) and (not Duel.IsExistingMatchingCard(c23499963.filter,tp,LOCATION_DECK,0,1,nil) or Duel.SelectYesNo(tp,aux.Stringid(23499963,0))) then  --"是否检索「护宝炮妖」怪兽？"
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 选择满足条件的「护宝炮妖」怪兽加入手牌
		local g=Duel.SelectMatchingCard(tp,c23499963.thfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
		local tc=g:GetFirst()
		-- 判断是否成功将卡加入手牌
		if Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) then
			-- 向对方确认已加入手牌的卡
			Duel.ConfirmCards(1-tp,tc)
			-- 提示玩家选择要送去墓地的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
			-- 选择满足条件的「护宝炮妖」怪兽送去墓地
			local tg=Duel.SelectMatchingCard(tp,c23499963.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
			-- 将选中的卡送去墓地
			Duel.SendtoGrave(tg,REASON_EFFECT)
		end
	else
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 选择满足条件的「大沙海 黄金戈尔工达」加入手牌
		local g=Duel.SelectMatchingCard(tp,c23499963.filter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的卡加入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方确认已加入手牌的卡
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
