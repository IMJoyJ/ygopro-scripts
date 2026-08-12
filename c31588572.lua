--破械童子サラマ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以「破械童子 娑罗摩」以外的自己墓地1张「破械」卡为对象才能发动。那张卡在自己场上盖放。那之后，选自己场上1张卡破坏。
-- ②：场上的这张卡被战斗或者「破械童子 娑罗摩」以外的卡的效果破坏的场合才能发动。从手卡·卡组把「破械童子 娑罗摩」以外的1只「破械」怪兽特殊召唤。
function c31588572.initial_effect(c)
	-- ①：以「破械童子 娑罗摩」以外的自己墓地1张「破械」卡为对象才能发动。那张卡在自己场上盖放。那之后，选自己场上1张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31588572,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY+CATEGORY_SSET+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,31588572)
	e1:SetTarget(c31588572.settg)
	e1:SetOperation(c31588572.setop)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡被战斗或者「破械童子 娑罗摩」以外的卡的效果破坏的场合才能发动。从手卡·卡组把「破械童子 娑罗摩」以外的1只「破械」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(31588572,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,31588573)
	e2:SetCondition(c31588572.spcon)
	e2:SetTarget(c31588572.sptg)
	e2:SetOperation(c31588572.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断墓地中的卡是否可以被选择作为效果对象，包括是否为「破械」卡且不是自身，以及是否可以特殊召唤或盖放。
function c31588572.setfilter(c,e,tp)
	if not c:IsSetCard(0x130) or c:IsCode(31588572) then return false end
	if c:IsType(TYPE_MONSTER) then
		-- 检查目标玩家在主要怪兽区是否有空位，用于判断是否可以特殊召唤怪兽。
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
	else return c:IsSSetable() end
end
-- 设置效果的处理目标，用于选择墓地中的「破械」卡作为对象。
function c31588572.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c31588572.setfilter(chkc,e,tp) end
	-- 检查是否存在满足条件的墓地卡片，用于判断效果是否可以发动。
	if chk==0 then return Duel.IsExistingTarget(c31588572.setfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要盖放的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 选择满足条件的墓地卡片作为效果对象。
	local g=Duel.SelectTarget(tp,c31588572.setfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetFirst():IsType(TYPE_MONSTER) then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY+CATEGORY_MSET)
		-- 设置操作信息，表示将特殊召唤一张怪兽。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	else
		e:SetCategory(CATEGORY_DESTROY+CATEGORY_SSET)
		-- 设置操作信息，表示将一张卡盖放。
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	end
	-- 获取场上所有玩家的卡组。
	local dg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,0,nil)
	-- 设置操作信息，表示将场上一张卡破坏。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,1,0,0)
end
-- 处理效果的执行函数，根据选择的卡类型进行特殊召唤或盖放，并在成功后破坏场上一张卡。
function c31588572.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标卡。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local res=0
	if tc:IsType(TYPE_MONSTER) then
		-- 将目标怪兽以里侧守备形式特殊召唤到场上。
		res=Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 确认对方能看到被特殊召唤的怪兽。
		if res~=0 then Duel.ConfirmCards(1-tp,tc) end
	else
		-- 将目标魔法/陷阱卡盖放到场上。
		res=Duel.SSet(tp,tc)
	end
	if res~=0 then
		-- 获取场上所有玩家的卡组数量。
		local ct=Duel.GetMatchingGroupCount(aux.TRUE,tp,LOCATION_ONFIELD,0,nil)
		if ct>0 then
			-- 中断当前效果，使后续处理视为错时点。
			Duel.BreakEffect()
			-- 提示玩家选择要破坏的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			-- 选择场上一张卡作为破坏对象。
			local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,0,1,1,nil)
			-- 显示被选为对象的卡的动画效果。
			Duel.HintSelection(g)
			-- 以效果原因破坏选中的卡。
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
-- 判断该卡是否因战斗或非自身效果被破坏。
function c31588572.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD)
		and (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and not re:GetHandler():IsCode(31588572)))
end
-- 过滤函数，用于判断手卡或卡组中的「破械」怪兽是否可以被特殊召唤。
function c31588572.spfilter(c,e,tp)
	return c:IsSetCard(0x130) and not c:IsCode(31588572) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果的目标，用于选择手卡或卡组中的「破械」怪兽。
function c31588572.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查目标玩家在主要怪兽区是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否存在满足条件的「破械」怪兽。
		and Duel.IsExistingMatchingCard(c31588572.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息，表示将从手卡或卡组特殊召唤一只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 处理效果的执行函数，从手卡或卡组中选择一只「破械」怪兽特殊召唤。
function c31588572.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查目标玩家在主要怪兽区是否有空位。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的「破械」怪兽作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c31588572.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧攻击形式特殊召唤到场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
