--サイバー・レヴシステム
-- 效果：
-- ①：从自己的手卡·墓地选1只「电子龙」特殊召唤。这个效果特殊召唤的怪兽不会被效果破坏。
function c33041277.initial_effect(c)
	-- ①：从自己的手卡·墓地选1只「电子龙」特殊召唤。这个效果特殊召唤的怪兽不会被效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c33041277.target)
	e1:SetOperation(c33041277.activate)
	c:RegisterEffect(e1)
end
-- 定义「电子龙」的选择条件：卡名必须是「电子龙」（卡号70095154），且该卡能够被当前效果特殊召唤。
function c33041277.filter(c,e,tp)
	return c:IsCode(70095154) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的合法性判定：仅当自己主要怪兽区有空位，并且手牌·墓地存在至少1只符合条件的「电子龙」时，效果才能发动。
function c33041277.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动确认阶段检查自己的主要怪兽区是否还有可用的格子，保证特殊召唤有位置。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 继续检查手牌·墓地中是否存在至少1张满足 c33041277.filter 条件的「电子龙」。
		and Duel.IsExistingMatchingCard(c33041277.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向系统登记本次操作信息：将从手牌·墓地特殊召唤1只怪兽，属于特殊召唤类别，用于连锁时点的正确判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果处理阶段：若场地空位正常，则提示玩家选择要特殊召唤的「电子龙」，从手牌·墓地选1张进行特殊召唤；若特殊召唤成功，则给那只怪兽赋予不会被效果破坏的免疫效果。
function c33041277.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认场上是否有空位；若没有空位则本次效果直接终止，不进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出选择提示：“请选择要特殊召唤的卡”，将选择消息缓存供玩家选牌。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己的手牌·墓地选择1张符合条件的「电子龙」（自动排除受王家长眠之谷影响的卡）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c33041277.filter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 若成功选牌并成功将那只怪兽以表侧表示特殊召唤到自己的主要怪兽区，则继续后续抗性赋予处理。
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 这个效果特殊召唤的怪兽不会被效果破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		g:GetFirst():RegisterEffect(e1)
	end
end
