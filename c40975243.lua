--鉄獣の抗戦
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己的墓地·除外状态的兽族·兽战士族·鸟兽族怪兽任意数量效果无效特殊召唤，只用那些怪兽为素材进行1只「铁兽」连接怪兽的连接召唤。
function c40975243.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己的墓地·除外状态的兽族·兽战士族·鸟兽族怪兽任意数量效果无效特殊召唤，只用那些怪兽为素材进行1只「铁兽」连接怪兽的连接召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,40975243+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c40975243.target)
	e1:SetOperation(c40975243.activate)
	c:RegisterEffect(e1)
end
-- 定义本效果可特殊召唤的素材怪兽的过滤条件：必须是兽族·兽战士族·鸟兽族，且能够被特殊召唤；位置必须在墓地，或是表侧表示的除外状态。
function c40975243.spfilter(c,e,tp)
	return c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end
-- 作为素材组的选择过滤条件，确认选中的怪兽组能够作为素材，从额外卡组连接召唤至少1只「铁兽」连接怪兽。
function c40975243.fselect(g,tp)
	-- 检查额外卡组是否有至少1只「铁兽」连接怪兽可以只用当前选中的怪兽组g作为素材进行连接召唤。
	return Duel.IsExistingMatchingCard(c40975243.lkfilter,tp,LOCATION_EXTRA,0,1,nil,g)
end
-- 定义额外卡组中「铁兽」连接怪兽的过滤条件：属于「铁兽」字段，且恰好能用给定的素材组g中的全部怪兽作为素材进行连接召唤。
function c40975243.lkfilter(c,g)
	return c:IsSetCard(0x14d) and c:IsLinkSummonable(g,nil,g:GetCount(),g:GetCount())
end
-- 定义用于检查额外卡组是否存在可登场「铁兽」连接怪兽的过滤条件：怪兽本身是连接怪兽、属于「铁兽」字段，且从额外卡组出场时有足够的怪兽区空格。
function c40975243.chkfilter(c,tp)
	-- 检查该连接怪兽是否属于「铁兽」字段，且自己场上有足够的空格能从额外卡组特殊召唤它。
	return c:IsType(TYPE_LINK) and c:IsSetCard(0x14d) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 发动时的效果合法性判定：确认本回合还可进行至少2次特殊召唤、场上有怪兽区空格、额外卡组存在可连接召唤的「铁兽」连接怪兽，并且墓地·除外区中存在满足条件的素材组合；满足上述条件后登记特殊召唤的操作信息。
function c40975243.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查玩家本回合还能否进行至少2次特殊召唤（素材特殊召唤和后续连接召唤各需要1次），不能则发动不合法。
		if not Duel.IsPlayerCanSpecialSummonCount(tp,2) then return false end
		-- 获取自己场上目前可用的主要怪兽区空格数，用于确定本次最多能特殊召唤的素材数量。
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if ft<=0 then return false end
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
		-- 从额外卡组获取所有当前可作为连接召唤对象的「铁兽」连接怪兽。
		local cg=Duel.GetMatchingGroup(c40975243.chkfilter,tp,LOCATION_EXTRA,0,nil,tp)
		if #cg==0 then return false end
		local _,maxlink=cg:GetMaxGroup(Card.GetLink)
		if maxlink>ft then maxlink=ft end
		-- 从自己墓地和除外区获取所有满足素材条件的兽族·兽战士族·鸟兽族怪兽，作为可特殊召唤的候选组。
		local g=Duel.GetMatchingGroup(c40975243.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e,tp)
		return g:CheckSubGroup(c40975243.fselect,1,maxlink,tp)
	end
	-- 登记本次效果将进行的特殊召唤操作信息（对象来自墓地·除外区，数量暂记为1），供系统检测相关时点。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
-- 效果处理阶段：若满足特殊召唤次数和空格条件，则从墓地·除外区选择素材怪兽效果无效特殊召唤，再用这些怪兽为素材从额外卡组连接召唤1只「铁兽」连接怪兽。
function c40975243.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认玩家本回合还能进行至少2次特殊召唤，否则不处理本次效果。
	if not Duel.IsPlayerCanSpecialSummonCount(tp,2) then return end
	-- 效果处理时获取当前场上可用怪兽区空格数，用于限制素材数量上限。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ft>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 获取墓地·除外区中可特殊召唤的素材怪兽组，并通过王家长眠之谷过滤器排除受其影响不能从墓地特殊召唤的卡。
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c40975243.spfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e,tp)
	-- 获取当前额外卡组中所有可进行连接召唤的「铁兽」连接怪兽。
	local cg=Duel.GetMatchingGroup(c40975243.chkfilter,tp,LOCATION_EXTRA,0,nil,tp)
	local _,maxlink=cg:GetMaxGroup(Card.GetLink)
	if ft>0 and maxlink then
		if maxlink>ft then maxlink=ft end
		-- 向玩家发出“请选择要特殊召唤的卡”的提示，用于选择要特殊召唤的素材怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:SelectSubGroup(tp,c40975243.fselect,false,1,maxlink,tp)
		if not sg then return end
		local tc=sg:GetFirst()
		while tc do
			-- 将选中的素材怪兽以表侧表示逐步特殊召唤（不检查召唤条件和苏生限制），以便后续统一完成特殊召唤处理。
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
			-- 中的“效果无效”：给特殊召唤的怪兽赋予效果无效状态（EFFECT_DISABLE与EFFECT_DISABLE_EFFECT），使其效果在场上无效。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			tc:RegisterEffect(e2)
			tc=sg:GetNext()
		end
		-- 完成所有逐步特殊召唤步骤，正式结算这些怪兽的特殊召唤。
		Duel.SpecialSummonComplete()
		-- 获取本次特殊召唤实际操作成功的怪兽组，供后续连接召唤素材使用。
		local og=Duel.GetOperatedGroup()
		-- 刷新场地信息，确保后续查询使用的是最新的场上状态。
		Duel.AdjustAll()
		if og:FilterCount(Card.IsLocation,nil,LOCATION_MZONE)<sg:GetCount() then return end
		-- 从额外卡组中找出能够仅用实际特殊召唤成功的怪兽组og作为素材进行连接召唤的「铁兽」连接怪兽。
		local tg=Duel.GetMatchingGroup(c40975243.lkfilter,tp,LOCATION_EXTRA,0,nil,og)
		if og:GetCount()==sg:GetCount() and tg:GetCount()>0 then
			-- 向玩家发出“请选择要特殊召唤的卡”的提示，用于选择要连接召唤的「铁兽」连接怪兽。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local rg=tg:Select(tp,1,1,nil)
			-- 使用实际特殊召唤成功的所有怪兽作为素材，从额外卡组把选中的「铁兽」连接怪兽进行连接召唤。
			Duel.LinkSummon(tp,rg:GetFirst(),og,nil,#og,#og)
		end
	end
end
