--グランドレミコード・ミューゼシア
-- 效果：
-- 灵摆怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。从手卡把1只灵摆怪兽表侧表示加入额外卡组，把持有若那个灵摆刻度是奇数则为偶数的、是偶数则为奇数的灵摆刻度的1只表侧表示的灵摆怪兽从自己的额外卡组加入手卡。
-- ②：自己对「七音服」怪兽的灵摆召唤成功时，以那之内的1只为对象才能发动。和那只怪兽的灵摆刻度数值相同等级的1只「七音服」灵摆怪兽从卡组加入手卡。
function c37972500.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加连接召唤手续，需要2只灵摆类型的怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_PENDULUM),2,2)
	-- ①：自己主要阶段才能发动。从手卡把1只灵摆怪兽表侧表示加入额外卡组，把持有若那个灵摆刻度是奇数则为偶数的、是偶数则为奇数的灵摆刻度的1只表侧表示的灵摆怪兽从自己的额外卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37972500,0))
	e1:SetCategory(CATEGORY_TOEXTRA+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,37972500)
	e1:SetTarget(c37972500.tetg)
	e1:SetOperation(c37972500.teop)
	c:RegisterEffect(e1)
	-- ②：自己对「七音服」怪兽的灵摆召唤成功时，以那之内的1只为对象才能发动。和那只怪兽的灵摆刻度数值相同等级的1只「七音服」灵摆怪兽从卡组加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(37972500,1))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,37972501)
	e2:SetCondition(c37972500.thcon)
	e2:SetTarget(c37972500.thtg)
	e2:SetOperation(c37972500.thop)
	c:RegisterEffect(e2)
end
-- 判断灵摆怪兽的刻度是否为指定奇偶性
function c37972500.chkfilter(c,odevity)
	return c:GetCurrentScale()%2==odevity
end
-- 筛选满足条件的灵摆怪兽，其刻度与指定奇偶性相反且可加入手牌
function c37972500.thfilter(c,odevity)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:GetCurrentScale()%2==1-odevity
		and c:IsAbleToHand()
end
-- 检查是否存在满足条件的灵摆怪兽并确认额外卡组是否有符合条件的灵摆怪兽
function c37972500.chkcon(g,tp,odevity)
	return g:IsExists(c37972500.chkfilter,1,nil,odevity)
		-- 检查额外卡组是否存在满足条件的灵摆怪兽
		and Duel.IsExistingMatchingCard(c37972500.thfilter,tp,LOCATION_EXTRA,0,1,nil,odevity)
end
-- 设置效果处理时的操作信息，包括将灵摆怪兽送入额外卡组和从额外卡组加入手牌
function c37972500.tetg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家手牌中所有灵摆怪兽
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_HAND,0,nil,TYPE_PENDULUM)
	if chk==0 then return c37972500.chkcon(g,tp,0) or c37972500.chkcon(g,tp,1) end
	-- 设置操作信息，表示将灵摆怪兽从手牌送入额外卡组
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,nil,1,tp,LOCATION_HAND)
	-- 设置操作信息，表示将灵摆怪兽从额外卡组加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
end
-- 执行效果处理，选择并送入额外卡组的灵摆怪兽，并从额外卡组检索符合条件的灵摆怪兽加入手牌
function c37972500.teop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家手牌中所有灵摆怪兽
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_HAND,0,nil,TYPE_PENDULUM)
	local b1=c37972500.chkcon(g,tp,0)
	local b2=c37972500.chkcon(g,tp,1)
	local sg=Group.CreateGroup()
	if b1 and not b2 then
		-- 提示玩家选择要送入额外卡组的灵摆怪兽
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(37972500,2))  --"请选择要加入额外卡组的卡"
		sg=g:FilterSelect(tp,c37972500.chkfilter,1,1,nil,0)
	end
	if not b1 and b2 then
		-- 提示玩家选择要送入额外卡组的灵摆怪兽
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(37972500,2))  --"请选择要加入额外卡组的卡"
		sg=g:FilterSelect(tp,c37972500.chkfilter,1,1,nil,1)
	end
	if b1 and b2 then
		-- 提示玩家选择要送入额外卡组的灵摆怪兽
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(37972500,2))  --"请选择要加入额外卡组的卡"
		sg=g:Select(tp,1,1,nil)
	end
	local tc=sg:GetFirst()
	-- 将选中的灵摆怪兽送入额外卡组并检查是否成功
	if tc and Duel.SendtoExtraP(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_EXTRA) then
		local odevity=tc:GetCurrentScale()%2
		-- 提示玩家选择要加入手牌的灵摆怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从额外卡组中选择满足条件的灵摆怪兽
		local g2=Duel.SelectMatchingCard(tp,c37972500.thfilter,tp,LOCATION_EXTRA,0,1,1,nil,odevity)
		if g2:GetCount()>0 then
			-- 将符合条件的灵摆怪兽加入手牌
			Duel.SendtoHand(g2,nil,REASON_EFFECT)
			-- 向对方确认加入手牌的灵摆怪兽
			Duel.ConfirmCards(1-tp,g2)
		end
	end
end
-- 判断是否为「七音服」灵摆怪兽且为灵摆召唤成功
function c37972500.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x162) and c:IsSummonPlayer(tp) and c:IsSummonType(SUMMON_TYPE_PENDULUM) and c:IsType(TYPE_PENDULUM)
end
-- 判断目标是否为符合条件的「七音服」灵摆怪兽
function c37972500.tgfilter(c,tp,g)
	-- 判断目标是否为符合条件的「七音服」灵摆怪兽并确认卡组中存在相同等级的灵摆怪兽
	return g:IsContains(c) and Duel.IsExistingMatchingCard(c37972500.adfilter,tp,LOCATION_DECK,0,1,nil,c:GetCurrentScale())
end
-- 筛选满足条件的「七音服」灵摆怪兽，其等级与指定等级相同且可加入手牌
function c37972500.adfilter(c,scale)
	return c:IsSetCard(0x162) and c:IsType(TYPE_PENDULUM) and c:IsLevel(scale) and c:IsAbleToHand()
end
-- 判断是否有符合条件的「七音服」灵摆怪兽被成功灵摆召唤
function c37972500.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c37972500.cfilter,1,nil,tp)
end
-- 设置效果处理时的操作信息，包括选择目标和从卡组加入手牌
function c37972500.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=eg:Filter(c37972500.cfilter,nil,tp)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c37972500.tgfilter(chkc,tp,g) end
	-- 检查是否存在符合条件的「七音服」灵摆怪兽作为目标
	if chk==0 then return Duel.IsExistingTarget(c37972500.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp,g) end
	if g:GetCount()==1 then
		-- 设置当前处理的连锁对象为符合条件的「七音服」灵摆怪兽
		Duel.SetTargetCard(g)
	else
		-- 提示玩家选择表侧表示的「七音服」灵摆怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		-- 选择符合条件的「七音服」灵摆怪兽作为目标
		Duel.SelectTarget(tp,c37972500.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp,g)
	end
	-- 设置操作信息，表示从卡组加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行效果处理，选择符合条件的「七音服」灵摆怪兽并加入手牌
function c37972500.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前处理的连锁对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local scale=tc:GetCurrentScale()
		-- 提示玩家选择要加入手牌的灵摆怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组中选择满足条件的灵摆怪兽
		local g=Duel.SelectMatchingCard(tp,c37972500.adfilter,tp,LOCATION_DECK,0,1,1,nil,scale)
		if g:GetCount()>0 then
			-- 将符合条件的灵摆怪兽加入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方确认加入手牌的灵摆怪兽
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
