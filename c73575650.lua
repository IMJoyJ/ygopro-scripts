--サブテラーの継承
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以从以下效果选择1个发动。发动后这张卡不送去墓地，直接盖放。
-- ●从手卡以及自己场上的表侧表示怪兽之中选1只怪兽送去墓地，相同属性而卡名不同的1只反转怪兽从卡组加入手卡。
-- ●从手卡以及自己场上的表侧表示怪兽之中选1只反转怪兽送去墓地，相同属性而原本等级低的1只怪兽从卡组加入手卡。
function c73575650.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：可以从以下效果选择1个发动。发动后这张卡不送去墓地，直接盖放。●从手卡以及自己场上的表侧表示怪兽之中选1只怪兽送去墓地，相同属性而卡名不同的1只反转怪兽从卡组加入手卡。●从手卡以及自己场上的表侧表示怪兽之中选1只反转怪兽送去墓地，相同属性而原本等级低的1只怪兽从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,73575650+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c73575650.target)
	e1:SetOperation(c73575650.activate)
	c:RegisterEffect(e1)
end
-- 过滤手卡或场上表侧表示的、且卡组存在相同属性而卡名不同的反转怪兽的怪兽
function c73575650.tgfilter1(c,tp)
	return (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
		-- 检查卡组中是否存在相同属性且卡名不同的反转怪兽
		and Duel.IsExistingMatchingCard(c73575650.thfilter1,tp,LOCATION_DECK,0,1,nil,c:GetAttribute(),c:GetCode())
end
-- 过滤卡组中与送去墓地的怪兽相同属性、卡名不同且可以加入手卡的反转怪兽
function c73575650.thfilter1(c,att,code)
	return c:IsAttribute(att) and not c:IsCode(code) and c:IsType(TYPE_FLIP) and c:IsAbleToHand()
end
-- 过滤手卡或场上表侧表示的、且卡组存在相同属性而原本等级更低怪兽的反转怪兽
function c73575650.tgfilter2(c,tp)
	return (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsType(TYPE_FLIP) and c:IsAbleToGrave()
		-- 检查卡组中是否存在相同属性且原本等级更低的怪兽
		and Duel.IsExistingMatchingCard(c73575650.thfilter2,tp,LOCATION_DECK,0,1,nil,c:GetAttribute(),c:GetOriginalLevel())
end
-- 过滤卡组中与送去墓地的怪兽相同属性、原本等级更低且可以加入手卡的怪兽
function c73575650.thfilter2(c,att,clv)
	local lv=c:GetOriginalLevel()
	return lv>0 and c:IsAttribute(att) and lv<clv and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果发动的目标过滤与效果选择处理
function c73575650.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足第一个效果的发动条件（手卡或场上有可送墓怪兽，且卡组有可检索的同属性不同名反转怪兽）
	local b1=Duel.IsExistingMatchingCard(c73575650.tgfilter1,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,tp)
	-- 检查是否满足第二个效果的发动条件（手卡或场上有可送墓反转怪兽，且卡组有可检索的同属性低等级怪兽）
	local b2=Duel.IsExistingMatchingCard(c73575650.tgfilter2,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,tp)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		-- 让玩家在两个效果中选择一个发动
		op=Duel.SelectOption(tp,aux.Stringid(73575650,0),aux.Stringid(73575650,1))  --"检索卡名不同的反转怪兽/检索等级低的怪兽"
	elseif b1 then
		-- 只满足第一个效果的条件时，强制选择第一个效果
		op=Duel.SelectOption(tp,aux.Stringid(73575650,0))  --"检索卡名不同的反转怪兽"
	else
		-- 只满足第二个效果的条件时，强制选择第二个效果
		op=Duel.SelectOption(tp,aux.Stringid(73575650,1))+1  --"检索等级低的怪兽"
	end
	e:SetLabel(op)
	-- 设置将1张卡送去墓地的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND+LOCATION_MZONE)
	-- 设置将1张卡从卡组加入手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理的执行函数
function c73575650.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		-- 提示玩家选择要送去墓地的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 让玩家从手卡或场上的表侧表示怪兽中选择1只送去墓地的怪兽
		local g1=Duel.SelectMatchingCard(tp,c73575650.tgfilter1,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,tp)
		local tc1=g1:GetFirst()
		-- 将选中的怪兽送去墓地，并确认其成功送去墓地
		if tc1 and Duel.SendtoGrave(tc1,REASON_EFFECT)~=0 and tc1:IsLocation(LOCATION_GRAVE) then
			-- 提示玩家选择要加入手卡的反转怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			-- 让玩家从卡组选择1只相同属性而卡名不同的反转怪兽
			local g2=Duel.SelectMatchingCard(tp,c73575650.thfilter1,tp,LOCATION_DECK,0,1,1,nil,tc1:GetAttribute(),tc1:GetCode())
			if g2:GetCount()>0 then
				-- 将选中的反转怪兽加入手卡
				Duel.SendtoHand(g2,nil,REASON_EFFECT)
				-- 向对方玩家确认加入手卡的卡片
				Duel.ConfirmCards(1-tp,g2)
			end
		end
	else
		-- 提示玩家选择要送去墓地的反转怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 让玩家从手卡或场上的表侧表示怪兽中选择1只送去墓地的反转怪兽
		local g1=Duel.SelectMatchingCard(tp,c73575650.tgfilter2,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,tp)
		local tc1=g1:GetFirst()
		-- 将选中的反转怪兽送去墓地，并确认其成功送去墓地
		if tc1 and Duel.SendtoGrave(tc1,REASON_EFFECT)~=0 and tc1:IsLocation(LOCATION_GRAVE) then
			-- 提示玩家选择要加入手卡的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			-- 让玩家从卡组选择1只相同属性而原本等级低的怪兽
			local g2=Duel.SelectMatchingCard(tp,c73575650.thfilter2,tp,LOCATION_DECK,0,1,1,nil,tc1:GetAttribute(),tc1:GetOriginalLevel())
			if g2:GetCount()>0 then
				-- 将选中的怪兽加入手卡
				Duel.SendtoHand(g2,nil,REASON_EFFECT)
				-- 向对方玩家确认加入手卡的卡片
				Duel.ConfirmCards(1-tp,g2)
			end
		end
	end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsCanTurnSet() then
		-- 中断当前效果，使后续的盖放处理不与检索同时处理
		Duel.BreakEffect()
		c:CancelToGrave()
		-- 将这张卡在场上直接盖放
		Duel.ChangePosition(c,POS_FACEDOWN)
		-- 触发魔法·陷阱卡被盖放的时点
		Duel.RaiseEvent(c,EVENT_SSET,e,REASON_EFFECT,tp,tp,0)
	end
end
