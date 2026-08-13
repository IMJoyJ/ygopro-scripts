--緊急アポート
-- 效果：
-- ①：以自己的墓地·除外状态的1只5星以下的念动力族怪兽为对象才能发动。那只怪兽特殊召唤。
local s,id,o=GetID()
-- 定义卡片的初始效果注册函数，为“紧急物体显形”创建并注册其①效果：发动时选择自己墓地或除外区的1只5星以下的念动力族怪兽为对象，将其特殊召唤。
function s.initial_effect(c)
	-- ①：以自己的墓地·除外状态的1只5星以下的念动力族怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 筛选条件的过滤函数：候选怪兽需为念动力族、5星以下、表侧表示（或可按表侧处理的怪兽），且能够被当前效果特殊召唤（同时检查召唤条件与苏生限制）。
function s.filter(c,e,tp)
	return c:IsFaceupEx() and c:IsRace(RACE_PSYCHO) and c:IsLevelBelow(5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标判定部分：若已指定候选对象，则确认其位于我方墓地或除外区且满足筛选条件；若在发动时点进行无对象检查，则还需确认有可用怪兽区和满足条件的目标。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.filter(chkc,e,tp) end
	-- 检查我方主要怪兽区是否有空位，以保证特殊召唤能够进行。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查我方墓地或除外区是否存在至少1只满足s.filter条件的怪兽，可作为此效果的对象。
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 向操作玩家显示卡片选择提示，提示内容为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地或除外区选择1只满足s.filter条件的怪兽作为效果对象，并将其与当前发动的效果关联。
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 登记本次连锁的处理信息：效果处理时将把所选的1只怪兽特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理函数：在效果结算时取出先前选择的对象，若该对象仍与效果有关联，则将其特殊召唤。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择作为效果对象的那只怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到我自己场上，并按通常规则检查其召唤条件与苏生限制。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
