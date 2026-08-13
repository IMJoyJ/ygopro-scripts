--首領亀
-- 效果：
-- 这张卡召唤·反转召唤成功时，可以从自己的手卡特殊召唤任意数量的「首领龟」上场。
function c3493978.initial_effect(c)
	-- 这张卡召唤·反转召唤成功时，可以从自己的手卡特殊召唤任意数量的「首领龟」上场。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(3493978,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c3493978.target)
	e1:SetOperation(c3493978.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 定义筛选条件：手牌中的卡必须是「首领龟」（3493978），且能够被当前效果特殊召唤（检查召唤条件与苏生限制）。
function c3493978.filter(c,e,tp)
	return c:IsCode(3493978) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的合法性判定：确认自己主要怪兽区有空位，且手牌存在至少1张符合条件的「首领龟」时才允许发动。
function c3493978.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否有至少1个可用区域，作为效果发动的前提条件之一。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在至少1张满足filter条件的「首领龟」，作为效果发动的前提条件之一。
		and Duel.IsExistingMatchingCard(c3493978.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置当前连锁的操作信息：本效果处理时将从手牌进行特殊召唤（类别为CATEGORY_SPECIAL_SUMMON，数量1为预计值，实际数量在处理时决定）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理时：获取可用怪兽区数量，若无空位则终止；若「青眼精灵龙」效果适用则将上限限制为1；让玩家从手牌选择1至上限张「首领龟」并表侧表示特殊召唤到自己场上。
function c3493978.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上主要怪兽区当前可用的空格数量，作为本次可特殊召唤数量的上限。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 向操作玩家显示选择提示，提示内容为“请选择要特殊召唤的卡”（HINTMSG_SPSUMMON）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己的手牌中选择1~ft张满足filter条件的「首领龟」，ft为可特殊召唤的数量上限。
	local g=Duel.SelectMatchingCard(tp,c3493978.filter,tp,LOCATION_HAND,0,1,ft,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的「首领龟」全部以表侧表示特殊召唤到自己场上（正面表示，并检查召唤条件与苏生限制）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
