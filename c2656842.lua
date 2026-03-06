--騎甲虫スカウト・バギー
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从自己的手卡·卡组·墓地选1只「骑甲虫 侦察虫车兵」特殊召唤。
-- ②：只要这张卡在怪兽区域存在，自己不是昆虫族怪兽不能特殊召唤。
function c2656842.initial_effect(c)
	-- 效果原文内容：②：只要这张卡在怪兽区域存在，自己不是昆虫族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c2656842.splimit)
	c:RegisterEffect(e1)
	-- 效果原文内容：①：这张卡召唤·特殊召唤成功的场合才能发动。从自己的手卡·卡组·墓地选1只「骑甲虫 侦察虫车兵」特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(2656842,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,2656842)
	e2:SetTarget(c2656842.sptg)
	e2:SetOperation(c2656842.spop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 规则层面操作：禁止非昆虫族怪兽特殊召唤。
function c2656842.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_INSECT)
end
-- 规则层面操作：过滤满足条件的「骑甲虫 侦察虫车兵」卡片。
function c2656842.spfilter(c,e,tp)
	return c:IsCode(2656842) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 规则层面操作：判断是否满足发动条件，包括场上存在空位和手卡/卡组/墓地存在目标怪兽。
function c2656842.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面操作：判断场上是否存在空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 规则层面操作：判断手卡/卡组/墓地是否存在满足条件的怪兽。
		and Duel.IsExistingMatchingCard(c2656842.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 规则层面操作：设置连锁处理信息，表明将要特殊召唤怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- 规则层面操作：处理特殊召唤效果，包括判断空位、选择目标、执行特殊召唤。
function c2656842.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：判断场上是否存在空位。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 规则层面操作：提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 规则层面操作：选择满足条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c2656842.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 规则层面操作：将选中的怪兽特殊召唤到场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
