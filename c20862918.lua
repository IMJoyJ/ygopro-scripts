--クロス・ブリード
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从手卡以及自己场上的表侧表示怪兽之中把2只原本的种族·属性相同而卡名不同的怪兽除外才能发动。和那些怪兽是原本的种族·属性相同而卡名不同的1只怪兽从卡组加入手卡。
function c20862918.initial_effect(c)
	-- 效果原文内容：这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,20862918+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c20862918.cost)
	e1:SetTarget(c20862918.target)
	e1:SetOperation(c20862918.activate)
	e1:SetLabel(0)
	c:RegisterEffect(e1)
end
-- 效果作用：设置发动标记为100，表示进入发动阶段
function c20862918.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
-- 效果作用：过滤手牌或场上的怪兽，满足条件的怪兽需在手牌或正面表示、为怪兽卡、可作为除外的代价，并且存在满足条件的第二只怪兽
function c20862918.costfilter1(c,tp)
	return (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
		-- 效果作用：检查是否存在满足条件的第二只怪兽，其种族、属性与第一只怪兽相同，且卡名不同
		and Duel.IsExistingMatchingCard(c20862918.costfilter2,tp,LOCATION_HAND+LOCATION_MZONE,0,1,c,c:GetOriginalRace(),c:GetOriginalAttribute(),c:GetCode(),tp)
end
-- 效果作用：过滤手牌或场上的怪兽，满足条件的怪兽需在手牌或正面表示、为怪兽卡、可作为除外的代价，并且种族、属性与第一只怪兽相同，卡名与第一只怪兽不同，同时卡组中存在满足条件的检索怪兽
function c20862918.costfilter2(c,race,att,code,tp)
	return (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
		and c:GetOriginalRace()==race and c:GetOriginalAttribute()==att and not c:IsCode(code)
		-- 效果作用：检查卡组中是否存在满足条件的怪兽，其种族、属性与第一只怪兽相同，卡名与第一只或第二只怪兽不同
		and Duel.IsExistingMatchingCard(c20862918.thfilter,tp,LOCATION_DECK,0,1,nil,race,att,code,c:GetCode())
end
-- 效果作用：过滤卡组中的怪兽，满足条件的怪兽需种族、属性与第一只怪兽相同，卡名与第一只或第二只怪兽不同，且可加入手牌
function c20862918.thfilter(c,race,att,code1,code2)
	return c:GetOriginalRace()==race and c:GetOriginalAttribute()==att and not c:IsCode(code1,code2)
		and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果作用：判断是否满足发动条件并选择除外的两只怪兽，然后将它们除外，设置后续操作信息
function c20862918.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 效果作用：判断是否满足发动条件，即是否存在于手牌或场上的满足条件的怪兽
		return e:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsExistingMatchingCard(c20862918.costfilter1,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,tp)
	end
	e:SetLabel(0)
	-- 效果作用：提示玩家选择要除外的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 效果作用：选择满足条件的第一只怪兽
	local g1=Duel.SelectMatchingCard(tp,c20862918.costfilter1,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,tp)
	local race=g1:GetFirst():GetOriginalRace()
	local att=g1:GetFirst():GetOriginalAttribute()
	local code=g1:GetFirst():GetCode()
	-- 效果作用：提示玩家选择要除外的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 效果作用：选择满足条件的第二只怪兽
	local g2=Duel.SelectMatchingCard(tp,c20862918.costfilter2,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,g1:GetFirst(),race,att,code,tp)
	e:SetLabel(race,att,code,g2:GetFirst():GetCode())
	g1:Merge(g2)
	-- 效果作用：将选中的两只怪兽除外
	Duel.Remove(g1,POS_FACEUP,REASON_COST)
	-- 效果作用：设置后续操作信息，表示将从卡组检索一张怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果作用：选择满足条件的怪兽从卡组加入手牌
function c20862918.activate(e,tp,eg,ep,ev,re,r,rp)
	local race,att,code1,code2=e:GetLabel()
	-- 效果作用：提示玩家选择要加入手牌的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 效果作用：选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c20862918.thfilter,tp,LOCATION_DECK,0,1,1,nil,race,att,code1,code2)
	if g:GetCount()>0 then
		-- 效果作用：将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 效果作用：确认对方查看加入手牌的怪兽
		Duel.ConfirmCards(1-tp,g)
	end
end
