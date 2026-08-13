--青き眼の激臨
-- 效果：
-- 这张卡发动的回合，自己不是「青眼白龙」不能召唤·特殊召唤。
-- ①：包含这张卡的自己的手卡·场上·墓地的卡全部里侧表示除外，从卡组把最多3只「青眼白龙」特殊召唤。
function c29432790.initial_effect(c)
	-- 将该卡的效果文本中记载的「青眼白龙」(89631139) 登记到代码列表中，用于后续判断记载卡名。
	aux.AddCodeList(c,89631139)
	-- 这张卡发动的回合，自己不是「青眼白龙」不能召唤·特殊召唤。①：包含这张卡的自己的手卡·场上·墓地的卡全部里侧表示除外，从卡组把最多3只「青眼白龙」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCost(c29432790.cost)
	e1:SetTarget(c29432790.target)
	e1:SetOperation(c29432790.activate)
	c:RegisterEffect(e1)
	-- 添加一个自定义活动计数器（用于召唤），记录本回合玩家进行的“召唤”操作，若召唤的不是「青眼白龙」则计数增加，用于发动自肃判定。
	Duel.AddCustomActivityCounter(29432790,ACTIVITY_SUMMON,c29432790.counterfilter)
	-- 添加一个自定义活动计数器（用于特殊召唤），记录本回合玩家进行的“特殊召唤”操作，若特殊召唤的不是「青眼白龙」则计数增加，用于发动自肃判定。
	Duel.AddCustomActivityCounter(29432790,ACTIVITY_SPSUMMON,c29432790.counterfilter)
end
-- 计数器过滤函数：只有卡名是「青眼白龙」(89631139) 的怪兽不会被计入违规召唤，其他怪兽进行对应召唤/特殊召唤时都会使计数器增加。
function c29432790.counterfilter(c)
	return c:IsCode(89631139)
end
-- 发动代价函数：在发动前检查本回合是否已经进行过非「青眼白龙」的召唤/特殊召唤，若已有违规操作则不能发动；若可以发动则在后续设置自肃效果。
function c29432790.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本回合自己进行“召唤”操作的自定义计数是否为0，即是否没有进行过非「青眼白龙」的通常召唤/召唤。
	if chk==0 then return Duel.GetCustomActivityCount(29432790,tp,ACTIVITY_SUMMON)==0
		-- 检查本回合自己进行“特殊召唤”操作的自定义计数是否为0，即是否没有进行过非「青眼白龙」的特殊召唤。
		and Duel.GetCustomActivityCount(29432790,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这张卡发动的回合，自己不是「青眼白龙」不能召唤·特殊召唤。①：包含这张卡的自己的手卡·场上·墓地的卡全部里侧表示除外，从卡组把最多3只「青眼白龙」特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c29432790.splimit)
	-- 将 e1 注册到场上，e1 为影响己方玩家的效果，使本回合自己不能特殊召唤「青眼白龙」以外的怪兽。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	-- 将 e2 注册到场上，e2 为影响己方玩家的效果，使本回合自己不能召唤「青眼白龙」以外的怪兽（这里“召唤”指的是通常召唤，不含特殊召唤）。
	Duel.RegisterEffect(e2,tp)
end
-- 自肃限制的判定函数：若怪兽不是「青眼白龙」(89631139)，则该怪兽不能进行召唤/特殊召唤。
function c29432790.splimit(e,c)
	return not c:IsCode(89631139)
end
-- 特殊召唤候选过滤函数：从卡组中选出「青眼白龙」，且确认它能够被效果特殊召唤（不检查苏生限制，因为从卡组特殊召唤不涉及苏生限制）。
function c29432790.spfilter(c,e,tp)
	return c:IsCode(89631139) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标函数：收集己方手牌/场上/墓地中能够里侧表示除外的所有卡，并确认卡组中有可特殊召唤的「青眼白龙」且除外后仍有可用怪兽区，满足条件才可发动。
function c29432790.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取己方手牌、场上、墓地中所有“能被除外”的卡（不取对象，且以里侧表示除外）。
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,nil,tp,POS_FACEDOWN)
	-- 检查卡组中是否存在满足特殊召唤条件的「青眼白龙」，作为发动的前提条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c29432790.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
		-- 同时确认能除外的卡数量大于0，且除去这些卡后己方场上仍有可用的怪兽区，避免除外后没有格子特殊召唤。
		and g:GetCount()>0 and Duel.GetMZoneCount(tp,g)>0 end
	-- 设置当前连锁的除外操作信息：说明要里侧表示除外的是己方手牌/场上/墓地的那批卡，数量为 g 的当前数量。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE)
	-- 设置当前连锁的特殊召唤操作信息：说明可能从卡组特殊召唤的是「青眼白龙」，数量暂时记为1（实际处理时根据可用的怪兽区数量最多3只）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数：结算时将己方手牌、场上、墓地的卡全部里侧表示除外，若除外成功则从卡组选择至多3只「青眼白龙」特殊召唤。
function c29432790.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	-- 处理时再次获取己方手牌、场上、墓地中所有可里侧表示除外的卡（因为发动时与处理时可能发生变化，需按处理时的状态执行）。
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,nil,tp,POS_FACEDOWN)
	-- 将 g 全部以里侧表示除外，若实际除外数量大于0则继续处理特殊召唤。
	if Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)>0 then
		-- 计算己方当前可用的主要怪兽区数量，作为特殊召唤数量的上限（后续还会受其他效果限制）。
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if ft<=0 then return end
		if ft>3 then ft=3 end
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
		-- 给玩家显示“请选择要特殊召唤的卡”的提示信息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从卡组中选择1到 ft 张满足条件（青眼白龙且可特殊召唤）的卡，ft 是可用怪兽区数量且不超过3。
		local sg=Duel.SelectMatchingCard(tp,c29432790.spfilter,tp,LOCATION_DECK,0,1,ft,nil,e,tp)
		if sg:GetCount()>0 then
			-- 将选择的「青眼白龙」全部以表侧表示特殊召唤到己方场上。
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
