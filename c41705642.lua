--サルベージ・ウォリアー
-- 效果：
-- 这张卡上级召唤成功时，可以从手卡或者自己墓地把1只调整特殊召唤。
function c41705642.initial_effect(c)
	-- 这张卡上级召唤成功时，可以从手卡或者自己墓地把1只调整特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41705642,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c41705642.spcon)
	e1:SetTarget(c41705642.sptg)
	e1:SetOperation(c41705642.spop)
	c:RegisterEffect(e1)
end
-- 效果发动条件：判定这张卡是否通过上级召唤（解放怪兽的通常召唤）成功，只有上级召唤成功时该效果才满足发动条件。
function c41705642.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 过滤函数：用于筛选可特殊召唤的卡，要求候选卡是调整怪兽，并且能够被当前效果特殊召唤（包括正常检查召唤条件和苏生限制）。
function c41705642.filter(c,e,tp)
	return c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动目标检测：效果发动时需确认我方主要怪兽区有空位，并且手卡或墓地存在至少1只满足filter条件的调整怪兽；同时用于处理时确定可选的卡牌范围。
function c41705642.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时点（chk==0）首先检查我方主要怪兽区是否有可用的空格，若没有空格则不能发动效果。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 继续检查手卡和我方墓地中是否存在至少1张满足filter条件的调整怪兽，若不存在则不能发动效果。
		and Duel.IsExistingMatchingCard(c41705642.filter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp) end
	-- 登记操作信息：声明本效果将进行特殊召唤，类别为CATEGORY_SPECIAL_SUMMON，处理时从手卡/墓地中选择1只怪兽，操作玩家为tp，来源位置为手卡/墓地。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
-- 效果处理函数：若场上仍有空位，则提示玩家从手卡或墓地选择1只符合条件的调整怪兽，并将其表侧表示特殊召唤到自己场上。
function c41705642.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认我方主要怪兽区是否有空格，若无空位则终止本次特殊召唤处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示选择提示，提示内容为“请选择要特殊召唤的卡”，用于引导玩家进行后续选择操作。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡和我方墓地中选择1张满足filter并且不受“王家长眠之谷”影响的调整怪兽；若墓地怪兽的效果被王谷无效则不能选择。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c41705642.filter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上，sumtype为0（无特殊召唤类型限制），并正常进行召唤条件和苏生限制的检查。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
