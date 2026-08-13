--ツーマンセルバトル
-- 效果：
-- 双方在各自的回合的结束阶段只有1次，可以从手卡特殊召唤1只4星的通常怪兽上场。
function c25578802.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 双方在各自的回合的结束阶段只有1次，可以从手卡特殊召唤1只4星的通常怪兽上场。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(25578802,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_BOTH_SIDE)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetCondition(c25578802.condition)
	e2:SetTarget(c25578802.target)
	e2:SetOperation(c25578802.operation)
	c:RegisterEffect(e2)
end
-- 该触发效果的发动条件：仅当当前回合玩家是效果控制者本人时才满足，从而保证双方各自回合的结束阶段才能发动。
function c25578802.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否等于效果发动方，即只有自己的回合结束阶段才可发动。
	return Duel.GetTurnPlayer()==tp
end
-- 检索/选择过滤器：筛选手卡中满足等级4且为通常怪兽，并且能被当前效果特殊召唤的卡片。
function c25578802.spfilter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsLevel(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动时（chk==0）的合法性检查：需要自己主要怪兽区有空位，且手卡中存在符合条件的通常怪兽。
function c25578802.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区域是否存在可用空格，没有空位则不能发动。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在至少1张满足特殊召唤条件的4星通常怪兽。
		and Duel.IsExistingMatchingCard(c25578802.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置本次连锁处理的操作信息：效果类别为特殊召唤，预定从手卡特殊召唤1张卡（具体目标在处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：先确认主要怪兽区仍有空位，然后由玩家选择手卡中符合条件的怪兽并表侧表示特殊召唤。
function c25578802.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 若发动后处理时主要怪兽区已没有空位，则特殊召唤不进行。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己的手卡中选出1张满足 spfilter 的怪兽（4星通常怪兽且可特殊召唤）。
	local g=Duel.SelectMatchingCard(tp,c25578802.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己的场上（默认主要怪兽区）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
