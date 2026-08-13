--切り込み隊長
-- 效果：
-- ①：这张卡召唤成功时才能发动。从手卡把1只4星以下的怪兽特殊召唤。
-- ②：只要这张卡在怪兽区域存在，对方不能选择其他的战士族怪兽作为攻击对象。
function c2460565.initial_effect(c)
	-- ②：只要这张卡在怪兽区域存在，对方不能选择其他的战士族怪兽作为攻击对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetValue(c2460565.atlimit)
	c:RegisterEffect(e1)
	-- ①：这张卡召唤成功时才能发动。从手卡把1只4星以下的怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(2460565,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(c2460565.sumtg)
	e2:SetOperation(c2460565.sumop)
	c:RegisterEffect(e2)
end
-- ②效果的攻击限制判定：若c不是此卡本身、是表侧表示且为战士族怪兽，则对方不能选择c作为攻击对象。
function c2460565.atlimit(e,c)
	return c~=e:GetHandler() and c:IsFaceup() and c:IsRace(RACE_WARRIOR)
end
-- 筛选可作为①效果特殊召唤的手卡怪兽：等级4以下且能被当前效果特殊召唤。
function c2460565.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动条件检查：自己怪兽区有空位，且手卡存在至少1只满足条件（4星以下且可特殊召唤）的怪兽。
function c2460565.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否有空位，作为效果能否发动的条件之一。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在至少1只满足特殊召唤条件的怪兽（4星以下且可特殊召唤），作为效果能否发动的条件之一。
		and Duel.IsExistingMatchingCard(c2460565.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置本次效果的操作信息：效果处理时将从手卡特殊召唤1只怪兽（分类为特殊召唤）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ①效果的实际处理：确认怪兽区仍有空位后，提示玩家选择手卡中1只满足条件的怪兽，并表侧特殊召唤到自己的怪兽区。
function c2460565.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己怪兽区是否有空位，若无空位则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给予玩家选择提示，显示“请选择要特殊召唤的卡”，引导玩家选择手卡中的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡中选择1只满足条件（4星以下且可特殊召唤）的怪兽作为特殊召唤的对象。
	local g=Duel.SelectMatchingCard(tp,c2460565.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己的怪兽区。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
