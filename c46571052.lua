--ブラッド・オーキス
-- 效果：
-- 这张卡召唤成功时，可以从手卡特殊召唤1只「死亡石斛」。
function c46571052.initial_effect(c)
	-- 这张卡召唤成功时，可以从手卡特殊召唤1只「死亡石斛」。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(46571052,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c46571052.sptg)
	e1:SetOperation(c46571052.spop)
	c:RegisterEffect(e1)
end
-- 定义特殊召唤的过滤条件：筛选手卡中卡名为「死亡石斛」且能够被当前效果特殊召唤的卡。
function c46571052.filter(c,e,tp)
	return c:IsCode(12965761) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标判定：确认自己主要怪兽区有空位，并且手卡中存在符合条件的「死亡石斛」。
function c46571052.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：自己主要怪兽区是否有可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件检查：手卡中是否存在至少1张满足filter条件的「死亡石斛」。
		and Duel.IsExistingMatchingCard(c46571052.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置本次效果的操作信息，预告将从手卡特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理函数：在满足条件时从手卡选择1只「死亡石斛」进行特殊召唤。
function c46571052.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次检查主要怪兽区是否有空位，没有空位则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡中选择1张符合条件的「死亡石斛」。
	local g=Duel.SelectMatchingCard(tp,c46571052.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的「死亡石斛」以表侧攻击表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
