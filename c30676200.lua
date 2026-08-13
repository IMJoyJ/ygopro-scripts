--灰滅せし都の英雄
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：场地区域有「灰灭之都 奥布西地暮」存在的场合，这张卡可以从手卡特殊召唤。
-- ②：自己·对方的主要阶段，以场上1只炎族怪兽为对象才能发动。那只怪兽破坏。这个效果把「灭亡龙 威多释」破坏的场合，可以再从卡组把1张「灰灭之都 奥布西地暮」在自己的场地区域表侧表示放置。
local s,id,o=GetID()
-- 注册入口：为「灰灭都的英雄」登记关联卡名，并注册两个效果——e1为①的规则特殊召唤效果，e3为②的破坏并可能放置场地的效果。
function s.initial_effect(c)
	-- 将卡号3055018（灰灭之都 奥布西地暮）登记到这张卡的关联卡名列表中，用于规则上识别“记载的卡名”。
	aux.AddCodeList(c,3055018)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：场地区域有「灰灭之都 奥布西地暮」存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.sprcon)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：自己·对方的主要阶段，以场上1只炎族怪兽为对象才能发动。那只怪兽破坏。这个效果把「灭亡龙 威多释」破坏的场合，可以再从卡组把1张「灰灭之都 奥布西地暮」在自己的场地区域表侧表示放置。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCondition(s.descon)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
-- 过滤函数：判断卡片是否为表侧表示且卡号为3055018（灰灭之都 奥布西地暮），用于检查场地区是否存在该场地。
function s.sprfilter(c)
	return c:IsFaceup() and c:IsCode(3055018)
end
-- ①特殊召唤规则效果的条件：若c为nil则返回true；否则需要召唤玩家有可用主要怪兽区，且自己场地区存在表侧表示的灰灭之都 奥布西地暮。
function s.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查召唤玩家是否有可用的主要怪兽区空格，以及自己场地区是否存在1张表侧表示且卡号为3055018的场地卡。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.sprfilter,tp,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
-- ②效果的发动条件：仅在主要阶段允许发动，用于限制只能在主要阶段使用。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是主要阶段1还是主要阶段2，满足任一即可发动。
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 对象过滤函数：选择场上表侧表示的炎族怪兽。
function s.desfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_PYRO)
end
-- ②效果发动时的目标选择处理：合法时从双方场上选择1只表侧表示的炎族怪兽作为对象，并设置破坏的操作信息。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.desfilter(chkc) end
	-- 检查场上是否存在1只以上表侧表示的炎族怪兽可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向操作玩家显示“请选择要破坏的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从双方场上选择1只表侧表示的炎族怪兽作为效果对象，该卡会与当前效果建立关联。
	local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁将执行破坏操作的信息，目标为所选对象，数量1，用于其他卡片的连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 过滤函数：检查卡组中的卡是否为灰灭之都 奥布西地暮（3055018）且不是禁止卡，用于后续从卡组放置场地。
function s.setfilter(c)
	return c:IsCode(3055018) and not c:IsForbidden()
end
-- ②效果处理：取对象怪兽，若仍与效果关联且是怪兽则将其破坏；若破坏的是灭亡龙 威多释（78783557），且卡组存在灰灭之都，询问玩家是否放置；若选择放置，则腾出场地区后把该场地卡表侧表示放置到自己场地区。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认对象仍与效果关联（未离场或失效）且是怪兽后，用效果将其破坏，并判断破坏是否成功。
	if tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) and Duel.Destroy(tc,REASON_EFFECT)>0
		and tc:GetPreviousCodeOnField()==78783557
		-- 检查自己卡组是否存在1张符合条件的「灰灭之都 奥布西地暮」（不是禁止卡）。
		and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil)
		-- 询问玩家是否要发动追加处理，从卡组放置场地魔法卡。
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否放置场地？"
		-- 中断当前效果处理，使后续的场地放置作为独立效果处理，避免错过时点。
		Duel.BreakEffect()
		-- 从卡组选择1张符合条件的「灰灭之都 奥布西地暮」，并取得第一张。
		local sc=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
		-- 获取自己场地区域（第6个区域，即场地魔法区域）当前存在的卡。
		local fc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
		if fc then
			-- 若场地区已有卡，将其以规则原因送去墓地，以腾出场地卡区域。
			Duel.SendtoGrave(fc,REASON_RULE)
			-- 再次中断效果处理，确保旧场地被送墓后连锁处理正确。
			Duel.BreakEffect()
		end
		-- 把选出的「灰灭之都 奥布西地暮」以表侧表示放置到自己的场地区域。
		Duel.MoveToField(sc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
	end
end
