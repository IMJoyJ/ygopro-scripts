--古のルール
-- 效果：
-- 从手卡把1只5星以上的通常怪兽特殊召唤。
function c10667321.initial_effect(c)
	-- 从手卡把1只5星以上的通常怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c10667321.target)
	e1:SetOperation(c10667321.activate)
	c:RegisterEffect(e1)
end
-- 定义怪兽筛选条件：卡片必须是5星以上的通常怪兽，并且能够被当前效果特殊召唤（满足召唤条件与苏生限制）。
function c10667321.filter(c,e,tp)
	return c:IsLevelAbove(5) and c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的合法性检查：仅当我方主要怪兽区有空位，且手牌中存在至少1只满足条件的5星以上通常怪兽时，效果才可以发动。
function c10667321.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时（chk==0）检查我方主要怪兽区是否有空余位置，若没有空位则效果不能发动。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时检查手牌中是否存在至少1只满足条件（5星以上、通常怪兽、可特殊召唤）的怪兽，与空位条件共同作为可否发动的依据。
		and Duel.IsExistingMatchingCard(c10667321.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 登记本次连锁的操作信息：声明将从手牌把1只怪兽特殊召唤，使相关效果能够正确检测到这次特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理时，在怪兽区仍有空位的情况下，从手牌选择1只符合条件的5星以上通常怪兽，并以表侧表示特殊召唤到自己的主要怪兽区。
function c10667321.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认我方主要怪兽区是否有空位，若没有空位则直接结束，不进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示选择提示，提示内容为“请选择要特殊召唤的卡”，引导玩家选择即将特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌中筛选并选择1只满足条件的怪兽（5星以上、通常怪兽、可特殊召唤），作为本次特殊召唤的对象。
	local g=Duel.SelectMatchingCard(tp,c10667321.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己的主要怪兽区，并且按规则检查其召唤条件与苏生限制。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
