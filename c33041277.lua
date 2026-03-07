--サイバー・レヴシステム
-- 效果：
-- ①：从自己的手卡·墓地选1只「电子龙」特殊召唤。这个效果特殊召唤的怪兽不会被效果破坏。
function c33041277.initial_effect(c)
	-- 效果发动时点为自由时点，可以随时发动，效果分类为特殊召唤，目标为手卡或墓地的电子龙，发动时处理效果
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c33041277.target)
	e1:SetOperation(c33041277.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选卡号为70095154（电子龙）且可以被特殊召唤的卡
function c33041277.filter(c,e,tp)
	return c:IsCode(70095154) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果的发动检查，判断是否满足特殊召唤条件
function c33041277.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家手卡或墓地是否存在满足条件的电子龙
		and Duel.IsExistingMatchingCard(c33041277.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置效果处理时将要特殊召唤的卡的类型和数量信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果处理函数，执行特殊召唤操作
function c33041277.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有空位，若无则不执行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的电子龙卡片
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c33041277.filter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 若成功选择并特殊召唤了卡，则为该卡添加不会被效果破坏的效果
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 为特殊召唤的电子龙添加不会被效果破坏的效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		g:GetFirst():RegisterEffect(e1)
	end
end
