--ビッグ・ホエール
-- 效果：
-- 这张卡上级召唤成功时，把这张卡解放才能发动。从卡组把3只3星的水属性怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
function c18322364.initial_effect(c)
	-- 这张卡上级召唤成功时，把这张卡解放才能发动。从卡组把3只3星的水属性怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(18322364,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c18322364.condition)
	e1:SetCost(c18322364.cost)
	e1:SetTarget(c18322364.target)
	e1:SetOperation(c18322364.operation)
	c:RegisterEffect(e1)
end
-- 判断触发条件：这张卡是以等级召唤（上级召唤）方式成功召唤时才满足条件。
function c18322364.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 代价判定与支付：先检查这张卡是否可解放，可作为代价；若可则执行解放。
function c18322364.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 实际执行解放：以“解放”作为发动代价（REASON_COST），将发动效果的这张卡从场上解放。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 定义特殊召唤候选卡的过滤条件：必须是等级为3的水属性怪兽，且能够被当前效果从卡组特殊召唤。
function c18322364.spfilter(c,e,tp)
	return c:IsLevel(3) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的合法性检测：确认没有处于“不能同时特殊召唤2只以上怪兽”的效果影响下、自己怪兽区剩余可用格数大于1、且卡组中存在至少3只符合条件的怪兽，满足才能发动。
function c18322364.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己怪兽区域的可用空格数大于1，确保这张卡自身解放后仍能腾出足够区域来特殊召唤3只怪兽。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检查卡组中是否存在至少3只满足过滤条件（3星水属性且可特殊召唤）的怪兽。
		and Duel.IsExistingMatchingCard(c18322364.spfilter,tp,LOCATION_DECK,0,3,nil,e,tp) end
	-- 向系统登记本次效果的操作信息：将从卡组特殊召唤3只怪兽，类别为特殊召唤，供连锁判定等使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,3,tp,LOCATION_DECK)
end
-- 效果处理：再次检查限制与区域空位，从卡组选取符合条件的怪兽，由玩家选择3只，逐只以表侧表示特殊召唤，并给每只怪兽附加效果无效化的状态，最后完成整个特殊召唤。
function c18322364.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 处理时检查自己怪兽区空位是否至少有3个，不足则本效果无法处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<3 then return end
	-- 从卡组中筛选出所有满足特殊召唤条件（3星、水属性、可被特殊召唤）的怪兽，作为候选集合。
	local g=Duel.GetMatchingGroup(c18322364.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	if g:GetCount()<3 then return end
	-- 显示选择提示消息，提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=g:Select(tp,3,3,nil)
	local tc=sg:GetFirst()
	while tc do
		-- 以正面表示将当前选中的怪兽加入特殊召唤步骤（尚未真正完成，需要后续SpecialSummonComplete统一完成）。
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
		tc=sg:GetNext()
	end
	-- 结束分批特殊召唤流程，正式完成所有怪兽的特殊召唤，并触发特殊召唤成功相关时点。
	Duel.SpecialSummonComplete()
end
