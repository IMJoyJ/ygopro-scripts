--VV－真羅万象
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：作为这张卡的发动时的效果处理，从卡组把「群豪世界-真罗万象」以外的1张「群豪」场地魔法卡在对方的场地区域表侧表示放置。
-- ②：场地区域有2张卡的场合，回合玩家以自身的魔法与陷阱区域1张怪兽卡为对象才能发动。那张卡在那个正对面的自身的主要怪兽区域特殊召唤。
function c49568943.initial_effect(c)
	-- ①：作为这张卡的发动时的效果处理，从卡组把「群豪世界-真罗万象」以外的1张「群豪」场地魔法卡在对方的场地区域表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c49568943.target)
	e1:SetOperation(c49568943.activate)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：场地区域有2张卡的场合，回合玩家以自身的魔法与陷阱区域1张怪兽卡为对象才能发动。那张卡在那个正对面的自身的主要怪兽区域特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_BOTH_SIDE+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,49568943)
	e2:SetCondition(c49568943.spcon)
	e2:SetTarget(c49568943.sptg)
	e2:SetOperation(c49568943.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数：从卡组筛选满足「群豪」字段、不是「群豪世界-真罗万象」、是场地魔法卡、未被禁止、且在对方场上不存在同名卡唯一性冲突的卡。
function c49568943.setfilter(c,tp)
	return c:IsSetCard(0x17d) and not c:IsCode(49568943) and c:IsType(TYPE_FIELD) and not c:IsForbidden() and c:CheckUniqueOnField(1-tp)
end
-- 发动时的判定函数：若卡组中存在符合条件的「群豪」场地魔法卡，则允许发动①效果。
function c49568943.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：卡组中存在至少1张符合条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c49568943.setfilter,tp,LOCATION_DECK,0,1,nil,tp) end
end
-- ①效果处理：从卡组选择1张符合条件的「群豪」场地魔法卡；若对方场地区已有卡则将其规则送墓，再表侧放置到对方场地区域。
function c49568943.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示：请选择要放置到场上的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从卡组挑选1张符合条件的卡，若成功则取回该卡。
	local tc=Duel.SelectMatchingCard(tp,c49568943.setfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if tc then
		-- 获取对方场地区域（序号5）正停留的场地魔法卡。
		local fc=Duel.GetFieldCard(1-tp,LOCATION_SZONE,5)
		if fc then
			-- 将对方原有的场地魔法卡以规则原因送去墓地（场地魔法被替换）。
			Duel.SendtoGrave(fc,REASON_RULE)
			-- 中断当前效果处理，使后续的放置动作作为新的效果处理，避免造成错时点。
			Duel.BreakEffect()
		end
		-- 将选中的「群豪」场地魔法卡表侧表示放置到对方的场地区域。
		Duel.MoveToField(tc,tp,1-tp,LOCATION_FZONE,POS_FACEUP,true)
	end
end
-- ②效果的发动条件判定：双方场地区域合计存在2张卡。
function c49568943.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查双方场地区域（LOCATION_FZONE）合计卡数是否为2。
	return Duel.GetFieldGroupCount(tp,LOCATION_FZONE,LOCATION_FZONE)==2
end
-- 可选对象过滤：自己魔法与陷阱区域的表侧表示且原本种类为怪兽的卡，且能特殊召唤到该卡正对面对应序号的自身主要怪兽区域。
function c49568943.spfilter(c,e,tp)
	local zone=1<<c:GetSequence()
	return c:IsFaceup() and c:GetSequence()<=4 and c:GetOriginalType()&TYPE_MONSTER~=0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
-- ②效果的发动与处理定义：选择自身魔法与陷阱区域1张怪兽卡为对象，设置特殊召唤的操作信息。
function c49568943.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(tp) and c49568943.spfilter(chkc,e,tp) end
	-- 发动条件检查：存在至少1张满足条件的自己魔法与陷阱区域的怪兽卡可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c49568943.spfilter,tp,LOCATION_SZONE,0,1,nil,e,tp) end
	-- 显示选择提示：请选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己魔法与陷阱区域1张符合条件的怪兽卡作为效果对象。
	local g=Duel.SelectTarget(tp,c49568943.spfilter,tp,LOCATION_SZONE,0,1,1,nil,e,tp)
	-- 将操作信息设定为特殊召唤，对象为选中的那张卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果处理：若所选对象仍与效果关联，则将其特殊召唤到该卡正对面的自身主要怪兽区域。
function c49568943.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁处理中的效果对象卡。
	local tc=Duel.GetFirstTarget()
	local zone=1<<tc:GetSequence()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以表侧表示特殊召唤到其正对面的自身主要怪兽区域（由原魔陷区序号计算出的主怪兽区）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP,zone)
	end
end
