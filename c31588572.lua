--破械童子サラマ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以「破械童子 娑罗摩」以外的自己墓地1张「破械」卡为对象才能发动。那张卡在自己场上盖放。那之后，选自己场上1张卡破坏。
-- ②：场上的这张卡被战斗或者「破械童子 娑罗摩」以外的卡的效果破坏的场合才能发动。从手卡·卡组把「破械童子 娑罗摩」以外的1只「破械」怪兽特殊召唤。
function c31588572.initial_effect(c)
	-- ①：以「破械童子 娑罗摩」以外的自己墓地1张「破械」卡为对象才能发动。那张卡在自己场上盖放。那之后，自己场上1张卡破坏。
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
-- 过滤函数：检查对象是否为「破械」卡且不是娑罗摩自身；若为怪兽则要求主要怪兽区有空位且可以里侧守备表示特殊召唤，若为魔法·陷阱卡则要求可以盖放。
function c31588572.setfilter(c,e,tp)
	if not c:IsSetCard(0x130) or c:IsCode(31588572) then return false end
	if c:IsType(TYPE_MONSTER) then
		-- 检查我方主要怪兽区是否有空位，用于判断能否将对象怪兽里侧守备特殊召唤。
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
	else return c:IsSSetable() end
end
-- 效果①的发动时点处理：从自己墓地的「破械」卡中选择1张（娑罗摩自身除外）作为对象；若选择的是怪兽，则将效果分类设为特殊召唤+破坏+怪兽盖放，并登记特殊召唤信息；若是魔陷，则分类设为破坏+魔陷盖放，并登记离墓信息；同时检索我方场上所有卡作为可能被破坏的对象并登记破坏信息。
function c31588572.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c31588572.setfilter(chkc,e,tp) end
	-- 发动合法性检查：确认自己墓地存在满足条件的「破械」卡可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c31588572.setfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家发送选择提示，要求选择一张要盖放的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家从自己墓地的满足条件的「破械」卡中选择1张作为效果对象。
	local g=Duel.SelectTarget(tp,c31588572.setfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetFirst():IsType(TYPE_MONSTER) then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY+CATEGORY_MSET)
		-- 登记操作信息：将特殊召唤的分类与对象g登记，用于连锁判定和效果处理。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	else
		e:SetCategory(CATEGORY_DESTROY+CATEGORY_SSET)
		-- 登记操作信息：将涉及墓地卡的分类（LEAVE_GRAVE）与对象g登记，用于连锁判定（如王家长眠之谷）。
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	end
	-- 获取我方场上所有卡（不取对象），作为之后要破坏的候选集合。
	local dg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,0,nil)
	-- 登记操作信息：将破坏分类与候选集合dg登记，表示效果处理时会破坏我方场上1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,1,0,0)
end
-- 效果①的解决处理：先取对象卡；若对象为怪兽则将其里侧守备特殊召唤并向对方确认，若是魔陷则直接盖放；若成功放置，则选自己场上1张卡破坏。
function c31588572.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local res=0
	if tc:IsType(TYPE_MONSTER) then
		-- 将对象怪兽以里侧守备表示特殊召唤到己方场上，并返回是否成功。
		res=Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 若特殊召唤成功，则向对方玩家确认该怪兽，公开信息。
		if res~=0 then Duel.ConfirmCards(1-tp,tc) end
	else
		-- 将对象魔法·陷阱卡盖放到己方魔陷区，并返回是否成功。
		res=Duel.SSet(tp,tc)
	end
	if res~=0 then
		-- 统计我方场上的卡数量，用于判断是否存在可破坏的卡。
		local ct=Duel.GetMatchingGroupCount(aux.TRUE,tp,LOCATION_ONFIELD,0,nil)
		if ct>0 then
			-- 中断当前效果，使后续破坏处理视作不同时处理，避免错过时点。
			Duel.BreakEffect()
			-- 向玩家发送选择提示，要求选择要破坏的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			-- 让玩家从我方场上选择1张卡破坏（不取对象，处理时选择）。
			local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,0,1,1,nil)
			-- 手动显示被选择的卡的选中动画，并记录被选为对象（用于连锁）。
			Duel.HintSelection(g)
			-- 将选择的卡以效果破坏送入墓地。
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
-- ②效果的发动条件：这张卡从场上被战斗破坏，或被「破械童子 娑罗摩」以外的卡的效果破坏。
function c31588572.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD)
		and (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and not re:GetHandler():IsCode(31588572)))
end
-- 过滤函数：筛选手卡·卡组中满足条件的「破械」怪兽：卡名含「破械」、不是娑罗摩自身，且可以被特殊召唤。
function c31588572.spfilter(c,e,tp)
	return c:IsSetCard(0x130) and not c:IsCode(31588572) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动时点处理：确认我方主要怪兽区有空位，且手卡·卡组中存在可以特殊召唤的「破械」怪兽；登记特殊召唤操作信息。
function c31588572.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：确认我方主要怪兽区有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动合法性检查：确认手卡·卡组存在符合特殊召唤条件的「破械」怪兽。
		and Duel.IsExistingMatchingCard(c31588572.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 登记操作信息：特殊召唤分类，数量1，来自手卡·卡组，不指定具体对象。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- ②效果的解决处理：若主要怪兽区有空位，则从手卡·卡组选择1只符合条件的「破械」怪兽表侧表示特殊召唤。
function c31588572.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认主要怪兽区有空位，否则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送选择提示，要求选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·卡组选择1只符合条件的「破械」怪兽。
	local g=Duel.SelectMatchingCard(tp,c31588572.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到己方场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
