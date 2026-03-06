--青き眼の激臨
-- 效果：
-- 这张卡发动的回合，自己不是「青眼白龙」不能召唤·特殊召唤。
-- ①：包含这张卡的自己的手卡·场上·墓地的卡全部里侧表示除外，从卡组把最多3只「青眼白龙」特殊召唤。
function c29432790.initial_effect(c)
	-- 记录该卡具有「青眼白龙」的卡片密码，用于后续效果判断
	aux.AddCodeList(c,89631139)
	-- 这张卡发动的回合，自己不是「青眼白龙」不能召唤·特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCost(c29432790.cost)
	e1:SetTarget(c29432790.target)
	e1:SetOperation(c29432790.activate)
	c:RegisterEffect(e1)
	-- 设置召唤次数计数器，用于限制发动者在该回合内不能进行召唤
	Duel.AddCustomActivityCounter(29432790,ACTIVITY_SUMMON,c29432790.counterfilter)
	-- 设置特殊召唤次数计数器，用于限制发动者在该回合内不能进行特殊召唤
	Duel.AddCustomActivityCounter(29432790,ACTIVITY_SPSUMMON,c29432790.counterfilter)
end
-- 计数器过滤函数，判断卡片是否为「青眼白龙」
function c29432790.counterfilter(c)
	return c:IsCode(89631139)
end
-- 费用支付阶段检查：确认发动者在该回合内未进行过召唤或特殊召唤
function c29432790.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查发动者在该回合内是否未进行过召唤
	if chk==0 then return Duel.GetCustomActivityCount(29432790,tp,ACTIVITY_SUMMON)==0
		-- 检查发动者在该回合内是否未进行过特殊召唤
		and Duel.GetCustomActivityCount(29432790,tp,ACTIVITY_SPSUMMON)==0 end
	-- 创建并注册不能特殊召唤效果，使发动者不能特殊召唤非「青眼白龙」的怪兽
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c29432790.splimit)
	-- 将不能特殊召唤效果注册给发动者
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	-- 将不能通常召唤效果注册给发动者
	Duel.RegisterEffect(e2,tp)
end
-- 限制召唤目标为非「青眼白龙」的怪兽
function c29432790.splimit(e,c)
	return not c:IsCode(89631139)
end
-- 特殊召唤过滤函数，筛选「青眼白龙」且可特殊召唤的卡
function c29432790.spfilter(c,e,tp)
	return c:IsCode(89631139) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的处理目标函数，检查是否有满足条件的「青眼白龙」可特殊召唤
function c29432790.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取发动者手牌、场上、墓地所有可除外的卡组
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,nil,tp,POS_FACEDOWN)
	-- 检查卡组中是否存在「青眼白龙」
	if chk==0 then return Duel.IsExistingMatchingCard(c29432790.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
		-- 检查是否有足够的怪兽区域进行特殊召唤
		and g:GetCount()>0 and Duel.GetMZoneCount(tp,g)>0 end
	-- 设置操作信息：将除外的卡组设置为操作对象
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE)
	-- 设置操作信息：将特殊召唤的「青眼白龙」设置为操作对象
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果发动时的处理函数，执行除外和特殊召唤操作
function c29432790.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	-- 获取发动者手牌、场上、墓地所有可除外的卡组
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,nil,tp,POS_FACEDOWN)
	-- 执行除外操作，将符合条件的卡除外
	if Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)>0 then
		-- 获取发动者场上可用的怪兽区域数量
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if ft<=0 then return end
		if ft>3 then ft=3 end
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
		-- 提示发动者选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的「青眼白龙」进行特殊召唤
		local sg=Duel.SelectMatchingCard(tp,c29432790.spfilter,tp,LOCATION_DECK,0,1,ft,nil,e,tp)
		if sg:GetCount()>0 then
			-- 将选中的「青眼白龙」特殊召唤到场上
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
