--夜薔薇の騎士
-- 效果：
-- ①：这张卡召唤成功时才能发动。从手卡把1只4星以下的植物族怪兽特殊召唤。
-- ②：只要这张卡在怪兽区域存在，对方不能选择植物族怪兽作为攻击对象。
function c2986553.initial_effect(c)
	-- ②：只要这张卡在怪兽区域存在，对方不能选择植物族怪兽作为攻击对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetValue(c2986553.atlimit)
	c:RegisterEffect(e1)
	-- ①：这张卡召唤成功时才能发动。从手卡把1只4星以下的植物族怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(2986553,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(c2986553.sumtg)
	e2:SetOperation(c2986553.sumop)
	c:RegisterEffect(e2)
end
-- 判断候选攻击对象是否为表侧表示的植物族怪兽，若是则对手不能选择其为攻击对象。
function c2986553.atlimit(e,c)
	return c:IsFaceup() and c:IsRace(RACE_PLANT)
end
-- 判断手卡中的怪兽是否满足特殊召唤条件：等级4以下、植物族，且能够被特殊召唤。
function c2986553.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_PLANT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动条件判定：自己主要怪兽区有空位，且手卡中存在1只满足条件的植物族怪兽。
function c2986553.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的主要怪兽区域是否有可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在满足特殊召唤条件的4星以下植物族怪兽。
		and Duel.IsExistingMatchingCard(c2986553.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息，声明本效果处理时将从手卡特殊召唤1只怪兽，供连锁判定等使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果①处理时：确认主要怪兽区有空位后，提示玩家从手卡选择1只4星以下的植物族怪兽，将其表侧表示特殊召唤到自己场上。
function c2986553.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时若自己主要怪兽区没有空位，则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出选择提示，让玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡中选择1张满足条件的植物族怪兽（等级4以下且可特殊召唤）。
	local g=Duel.SelectMatchingCard(tp,c2986553.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
