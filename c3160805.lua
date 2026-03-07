--明と宵の逆転
-- 效果：
-- 可以从以下效果选择1个发动。「明与宵的逆转」的效果1回合只能使用1次。
-- ●从手卡把1只战士族·光属性怪兽送去墓地。那之后，和那只怪兽相同等级的1只战士族·暗属性怪兽从卡组加入手卡。
-- ●从手卡把1只战士族·暗属性怪兽送去墓地。那之后，和那只怪兽相同等级的1只战士族·光属性怪兽从卡组加入手卡。
function c3160805.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e1)
	-- 发动效果
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(3160805,0))  --"发动效果"
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1,3160805)
	e2:SetTarget(c3160805.target)
	e2:SetOperation(c3160805.operation)
	c:RegisterEffect(e2)
end
-- 从手卡把1只战士族·光属性怪兽送去墓地。那之后，和那只怪兽相同等级的1只战士族·暗属性怪兽从卡组加入手卡。
function c3160805.tgfilter1(c,tp)
	return c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_LIGHT)
		-- 检查卡组中是否存在与所选光属性怪兽等级相同的暗属性战士族怪兽
		and Duel.IsExistingMatchingCard(c3160805.thfilter1,tp,LOCATION_DECK,0,1,nil,c:GetLevel())
end
-- 筛选等级等于指定等级、种族为战士族、属性为暗属性且能加入手牌的怪兽
function c3160805.thfilter1(c,lv)
	return c:IsLevel(lv) and c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToHand()
end
-- 从手卡把1只战士族·暗属性怪兽送去墓地。那之后，和那只怪兽相同等级的1只战士族·光属性怪兽从卡组加入手卡。
function c3160805.tgfilter2(c,tp)
	return c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_DARK)
		-- 检查卡组中是否存在与所选暗属性怪兽等级相同的光属性战士族怪兽
		and Duel.IsExistingMatchingCard(c3160805.thfilter2,tp,LOCATION_DECK,0,1,nil,c:GetLevel())
end
-- 筛选等级等于指定等级、种族为战士族、属性为光属性且能加入手牌的怪兽
function c3160805.thfilter2(c,lv)
	return c:IsLevel(lv) and c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToHand()
end
-- 判断是否满足发动条件并选择发动效果
function c3160805.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在满足条件的光属性战士族怪兽
	local b1=Duel.IsExistingMatchingCard(c3160805.tgfilter1,tp,LOCATION_HAND,0,1,nil,tp)
	-- 检查手卡中是否存在满足条件的暗属性战士族怪兽
	local b2=Duel.IsExistingMatchingCard(c3160805.tgfilter2,tp,LOCATION_HAND,0,1,nil,tp)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		-- 选择发动效果1：光属性怪兽送去墓地，暗属性怪兽加入手卡
		op=Duel.SelectOption(tp,aux.Stringid(3160805,2),aux.Stringid(3160805,3))  --"光属性怪兽送去墓地，暗属性怪兽加入手卡/暗属性怪兽送去墓地，光属性怪兽加入手卡"
	elseif b1 then
		-- 选择发动效果1：光属性怪兽送去墓地，暗属性怪兽加入手卡
		op=Duel.SelectOption(tp,aux.Stringid(3160805,2))  --"光属性怪兽送去墓地，暗属性怪兽加入手卡"
	else
		-- 选择发动效果2：暗属性怪兽送去墓地，光属性怪兽加入手卡
		op=Duel.SelectOption(tp,aux.Stringid(3160805,3))+1  --"暗属性怪兽送去墓地，光属性怪兽加入手卡"
	end
	e:SetLabel(op)
	-- 设置操作信息：将1张手牌送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
	-- 设置操作信息：将1张卡从卡组加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行效果处理
function c3160805.operation(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 选择1张满足条件的手卡光属性战士族怪兽
		local g=Duel.SelectMatchingCard(tp,c3160805.tgfilter1,tp,LOCATION_HAND,0,1,1,nil,tp)
		-- 将所选怪兽送去墓地
		if Duel.SendtoGrave(g,REASON_EFFECT)~=0 then
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 提示玩家选择要加入手牌的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			-- 选择1张与所选怪兽等级相同的暗属性战士族怪兽加入手牌
			local tg=Duel.SelectMatchingCard(tp,c3160805.thfilter1,tp,LOCATION_DECK,0,1,1,nil,g:GetFirst():GetLevel())
			-- 将所选怪兽加入手牌
			Duel.SendtoHand(tg,nil,REASON_EFFECT)
			-- 向对方确认所选怪兽
			Duel.ConfirmCards(1-tp,tg)
		end
	else
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 选择1张满足条件的手卡暗属性战士族怪兽
		local g=Duel.SelectMatchingCard(tp,c3160805.tgfilter2,tp,LOCATION_HAND,0,1,1,nil,tp)
		-- 将所选怪兽送去墓地
		if Duel.SendtoGrave(g,REASON_EFFECT)~=0 then
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 提示玩家选择要加入手牌的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			-- 选择1张与所选怪兽等级相同的光属性战士族怪兽加入手牌
			local tg=Duel.SelectMatchingCard(tp,c3160805.thfilter2,tp,LOCATION_DECK,0,1,1,nil,g:GetFirst():GetLevel())
			-- 将所选怪兽加入手牌
			Duel.SendtoHand(tg,nil,REASON_EFFECT)
			-- 向对方确认所选怪兽
			Duel.ConfirmCards(1-tp,tg)
		end
	end
end
