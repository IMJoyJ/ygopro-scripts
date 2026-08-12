--虹の行方
-- 效果：
-- 对方怪兽的攻击宣言时，选择自己的魔法与陷阱卡区域存在的1张名字带有「宝玉兽」的卡送去墓地发动。可以把1只对方怪兽的攻击无效，从自己卡组选择1张名字带有「究极宝玉神」的卡加入手卡。
function c7617253.initial_effect(c)
	-- 对方怪兽的攻击宣言时，选择自己的魔法与陷阱卡区域存在的1张名字带有「宝玉兽」的卡送去墓地发动。可以把1只对方怪兽的攻击无效
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c7617253.condition)
	e1:SetCost(c7617253.cost)
	e1:SetTarget(c7617253.target)
	e1:SetOperation(c7617253.activate)
	c:RegisterEffect(e1)
end
-- 定义效果发动条件（对方怪兽攻击宣言时）
function c7617253.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否不是自己（即对方的回合）
	return tp~=Duel.GetTurnPlayer()
end
-- 过滤自己魔陷区表侧表示且可以送去墓地的「宝玉兽」卡片
function c7617253.costfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1034) and c:IsAbleToGraveAsCost()
end
-- 定义效果发动代价（Cost）的处理函数
function c7617253.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段（chk==0），检查自己魔陷区是否存在至少1张满足条件的「宝玉兽」卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c7617253.costfilter,tp,LOCATION_SZONE,0,1,nil) end
	-- 给玩家发送提示信息，提示选择要送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从自己魔陷区选择1张满足条件的「宝玉兽」卡片
	local g=Duel.SelectMatchingCard(tp,c7617253.costfilter,tp,LOCATION_SZONE,0,1,1,nil)
	-- 将选择的卡片作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 定义效果对象选择（Target）的处理函数
function c7617253.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前进行攻击宣言的怪兽
	local tg=Duel.GetAttacker()
	if chkc then return chkc==tg end
	if chk==0 then return tg:IsOnField() and tg:IsCanBeEffectTarget(e) end
	-- 将该攻击怪兽设为效果处理的对象
	Duel.SetTargetCard(tg)
end
-- 过滤卡组中可以加入手牌的「究极宝玉神」卡片
function c7617253.filter(c)
	return c:IsSetCard(0x2034) and c:IsAbleToHand()
end
-- 定义效果处理（Operation）的执行函数
function c7617253.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前进行攻击的怪兽
	local tg=Duel.GetAttacker()
	if not tg:IsRelateToEffect(e) or tg:IsStatus(STATUS_ATTACK_CANCELED)
		-- 尝试无效该怪兽的攻击，若无效失败则结束效果处理
		or not Duel.NegateAttack() then return end
	-- 获取自己卡组中所有名字带有「究极宝玉神」且能加入手牌的卡片
	local g=Duel.GetMatchingGroup(c7617253.filter,tp,LOCATION_DECK,0,nil)
	-- 若卡组中存在符合条件的卡，询问玩家是否选择将其加入手牌
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(7617253,0)) then  --"是否要把一张「究极宝玉神」的卡加入手牌？"
		-- 给玩家发送提示信息，提示选择要加入手牌的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 中断当前效果处理，使后续的检索处理与无效攻击不视为同时进行
		Duel.BreakEffect()
		-- 将选择的「究极宝玉神」卡片加入玩家手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方玩家展示并确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,sg)
	end
end
