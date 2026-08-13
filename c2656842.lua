--騎甲虫スカウト・バギー
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从自己的手卡·卡组·墓地选1只「骑甲虫 侦察虫车兵」特殊召唤。
-- ②：只要这张卡在怪兽区域存在，自己不是昆虫族怪兽不能特殊召唤。
function c2656842.initial_effect(c)
	-- ②：只要这张卡在怪兽区域存在，自己不是昆虫族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c2656842.splimit)
	c:RegisterEffect(e1)
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡召唤·特殊召唤成功的场合才能发动。从自己的手卡·卡组·墓地选1只「骑甲虫 侦察虫车兵」特殊召唤。
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
-- ②的自肃判定：当要被特殊召唤的怪兽不是昆虫族时返回 true，使该特殊召唤被禁止，实现自己不是昆虫族怪兽不能特殊召唤。
function c2656842.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_INSECT)
end
-- 特召对象过滤：判定卡是否卡名为「骑甲虫 侦察虫车兵」且可被当前效果特殊召唤（检查召唤条件和苏生限制）。
function c2656842.spfilter(c,e,tp)
	return c:IsCode(2656842) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动条件判定：确认自己场上有空余的怪兽区域，并且自己的手卡·卡组·墓地存在至少1只符合筛选条件的「骑甲虫 侦察虫车兵」，满足才可发动。
function c2656842.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的怪兽区域是否有可用空位，作为①效果能否发动的条件之一。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的手卡·卡组·墓地是否存在至少1只满足 spfilter 条件的「骑甲虫 侦察虫车兵」，作为①效果能否发动的条件之一。
		and Duel.IsExistingMatchingCard(c2656842.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 登记本次连锁将进行的操作信息：效果类别为特殊召唤，预定从手卡·卡组·墓地特殊召唤1只怪兽，供其他卡的效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- ①效果处理：若自己场上仍有可用的怪兽区域，则让玩家从手卡·卡组·墓地选择1只符合条件的「骑甲虫 侦察虫车兵」（墓地区的卡还需不受王家长眠之谷影响），并表侧表示特殊召唤到自己的怪兽区域。
function c2656842.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己的怪兽区域是否还有空位，若无空位则直接终止本次特殊召唤处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 向当前玩家显示选择提示，提示内容为「请选择要特殊召唤的卡」，用于后续的选卡界面。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己的手卡·卡组·墓地中选择1张满足 spfilter 且不受王家长眠之谷影响的「骑甲虫 侦察虫车兵」，结果存入 g。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c2656842.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的「骑甲虫 侦察虫车兵」以表侧表示特殊召唤到自己的怪兽区域（仍会检查召唤条件与苏生限制，因 spfilter 已提前确认）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
