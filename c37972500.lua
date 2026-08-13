--グランドレミコード・ミューゼシア
-- 效果：
-- 灵摆怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。从手卡把1只灵摆怪兽表侧表示加入额外卡组，把持有若那个灵摆刻度是奇数则为偶数的、是偶数则为奇数的灵摆刻度的1只表侧表示的灵摆怪兽从自己的额外卡组加入手卡。
-- ②：自己对「七音服」怪兽的灵摆召唤成功时，以那之内的1只为对象才能发动。和那只怪兽的灵摆刻度数值相同等级的1只「七音服」灵摆怪兽从卡组加入手卡。
function c37972500.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加连接召唤手续：以2只灵摆怪兽为连接素材。
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
-- 筛选函数：判断卡片c的当前灵摆刻度奇偶性是否等于odevity（0为偶数，1为奇数）。
function c37972500.chkfilter(c,odevity)
	return c:GetCurrentScale()%2==odevity
end
-- 筛选额外卡组中表侧表示的灵摆怪兽，要求刻度奇偶性与odevity相反（若手牌刻度为奇数则要偶数，若为偶数则要奇数），并且可以被加入手卡。
function c37972500.thfilter(c,odevity)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:GetCurrentScale()%2==1-odevity
		and c:IsAbleToHand()
end
-- 检查发动条件：手牌中是否存在1只刻度奇偶性为odevity的灵摆怪兽，且额外卡组存在1只刻度奇偶性相反的符合条件的表侧灵摆怪兽。
function c37972500.chkcon(g,tp,odevity)
	return g:IsExists(c37972500.chkfilter,1,nil,odevity)
		-- 检查额外卡组中是否存在至少1张满足thfilter（表侧灵摆、刻度奇偶性相反、可加入手卡）的卡。
		and Duel.IsExistingMatchingCard(c37972500.thfilter,tp,LOCATION_EXTRA,0,1,nil,odevity)
end
-- ①效果的发动条件判定函数：在手牌灵摆怪兽中确认是否存在可行方案（奇数或偶数刻度），并设置效果的操作信息。
function c37972500.tetg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己手牌中所有灵摆怪兽作为候选组。
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_HAND,0,nil,TYPE_PENDULUM)
	if chk==0 then return c37972500.chkcon(g,tp,0) or c37972500.chkcon(g,tp,1) end
	-- 登记效果含将1张手牌灵摆怪兽加入额外卡组的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,nil,1,tp,LOCATION_HAND)
	-- 登记效果含从额外卡组将1张灵摆怪兽加入手牌的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
end
-- ①效果处理：从手牌选择1只灵摆怪兽表侧加入额外卡组，再根据其刻度奇偶性从额外卡组选择1只相反奇偶性的灵摆怪兽加入手牌并展示。
function c37972500.teop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次获取手牌中的灵摆怪兽组，用于选择要送额外卡组的卡。
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_HAND,0,nil,TYPE_PENDULUM)
	local b1=c37972500.chkcon(g,tp,0)
	local b2=c37972500.chkcon(g,tp,1)
	local sg=Group.CreateGroup()
	if b1 and not b2 then
		-- 提示玩家选择要加入额外卡组的灵摆怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(37972500,2))  --"请选择要加入额外卡组的卡"
		sg=g:FilterSelect(tp,c37972500.chkfilter,1,1,nil,0)
	end
	if not b1 and b2 then
		-- 提示玩家选择要加入额外卡组的灵摆怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(37972500,2))  --"请选择要加入额外卡组的卡"
		sg=g:FilterSelect(tp,c37972500.chkfilter,1,1,nil,1)
	end
	if b1 and b2 then
		-- 提示玩家选择要加入额外卡组的灵摆怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(37972500,2))  --"请选择要加入额外卡组的卡"
		sg=g:Select(tp,1,1,nil)
	end
	local tc=sg:GetFirst()
	-- 将选择的灵摆怪兽表侧加入额外卡组；若成功且该卡仍在额外卡组，则继续检索。
	if tc and Duel.SendtoExtraP(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_EXTRA) then
		local odevity=tc:GetCurrentScale()%2
		-- 提示玩家选择要加入手牌的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从自己的额外卡组选择1张刻度奇偶性与已送额外怪兽相反的灵摆怪兽。
		local g2=Duel.SelectMatchingCard(tp,c37972500.thfilter,tp,LOCATION_EXTRA,0,1,1,nil,odevity)
		if g2:GetCount()>0 then
			-- 将选择的灵摆怪兽加入手牌。
			Duel.SendtoHand(g2,nil,REASON_EFFECT)
			-- 将加入手牌的卡给对方玩家确认。
			Duel.ConfirmCards(1-tp,g2)
		end
	end
end
-- 筛选由玩家tp灵摆召唤成功的表侧表示「七音服」灵摆怪兽。
function c37972500.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x162) and c:IsSummonPlayer(tp) and c:IsSummonType(SUMMON_TYPE_PENDULUM) and c:IsType(TYPE_PENDULUM)
end
-- 判断对象候选：c必须是这次灵摆召唤成功的怪兽之一，且卡组中存在等级等于c当前灵摆刻度的「七音服」灵摆怪兽。
function c37972500.tgfilter(c,tp,g)
	-- 返回c在灵摆召唤成功组内，且卡组中存在符合adfilter的卡（等级与c当前灵摆刻度相同）。
	return g:IsContains(c) and Duel.IsExistingMatchingCard(c37972500.adfilter,tp,LOCATION_DECK,0,1,nil,c:GetCurrentScale())
end
-- 筛选卡组中「七音服」字段、灵摆怪兽、等级等于scale、且可加入手卡的卡。
function c37972500.adfilter(c,scale)
	return c:IsSetCard(0x162) and c:IsType(TYPE_PENDULUM) and c:IsLevel(scale) and c:IsAbleToHand()
end
-- ②效果的发动条件：本次特殊召唤成功的怪兽中存在由玩家tp灵摆召唤的「七音服」灵摆怪兽。
function c37972500.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c37972500.cfilter,1,nil,tp)
end
-- ②效果的目标选择函数：从灵摆召唤成功的「七音服」怪兽中选1只作为对象，并登记从卡组加入手牌的操作信息。
function c37972500.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=eg:Filter(c37972500.cfilter,nil,tp)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c37972500.tgfilter(chkc,tp,g) end
	-- 发动合法性检查：场上是否存在至少1只可作为对象的「七音服」灵摆怪兽（属于本次灵摆召唤成功且卡组有对应可检索怪兽）。
	if chk==0 then return Duel.IsExistingTarget(c37972500.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp,g) end
	if g:GetCount()==1 then
		-- 当符合条件的对象只有1只时，直接将其设为效果对象。
		Duel.SetTargetCard(g)
	else
		-- 提示玩家选择表侧表示的对象怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		-- 让玩家从场上选择1只满足条件的「七音服」灵摆怪兽作为效果对象。
		Duel.SelectTarget(tp,c37972500.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp,g)
	end
	-- 登记效果含从卡组将1张卡加入手牌的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：从卡组选择1只等级等于对象怪兽当前灵摆刻度数值的「七音服」灵摆怪兽加入手牌，并向对方展示。
function c37972500.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取②效果的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local scale=tc:GetCurrentScale()
		-- 提示玩家选择要加入手牌的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组选择1张等级等于对象灵摆刻度数值的「七音服」灵摆怪兽。
		local g=Duel.SelectMatchingCard(tp,c37972500.adfilter,tp,LOCATION_DECK,0,1,1,nil,scale)
		if g:GetCount()>0 then
			-- 将选择的卡加入手牌。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 将加入手牌的卡给对方玩家确认。
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
