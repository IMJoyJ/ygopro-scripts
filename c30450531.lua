--降霊の儀式
-- 效果：
-- 指定自己墓地里1张名称中含有「守墓」的怪兽卡特殊召唤。这张卡的发动不受「王家长眠之谷」的限制。
function c30450531.initial_effect(c)
	-- 指定自己墓地里1张名称中含有「守墓」的怪兽卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c30450531.target)
	e1:SetOperation(c30450531.activate)
	c:RegisterEffect(e1)
	-- 这张卡的发动不受「王家长眠之谷」的限制。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_NECRO_VALLEY_IM)
	c:RegisterEffect(e2)
end
-- 筛选条件：卡片必须是名称中含有「守墓」的怪兽，且能够被当前效果特殊召唤（不无视召唤条件与苏生限制）。
function c30450531.filter(c,e,tp)
	return c:IsSetCard(0x2e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动时的对象检查和合法性判定：若为取对象确认，则返回该对象是否在自己墓地且满足筛选条件；若为发动合法性检查，则返回场上是否有空位且墓地存在满足条件的对象。
function c30450531.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c30450531.filter(chkc,e,tp) end
	-- 检查自己主要怪兽区是否有可以使用的空格，确保特殊召唤有可用区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1张满足特殊召唤条件的「守墓」怪兽，可作为效果对象。
		and Duel.IsExistingTarget(c30450531.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家弹出选择提示，提示内容为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地的符合条件怪兽中选择1张作为特殊召唤对象，并设置为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c30450531.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 将本次连锁的操作信息登记为特殊召唤，对象为已选择的1张卡，供后续相关效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理阶段：取出对象卡，若仍与效果关联，则将其以表侧表示特殊召唤到自己场上。
function c30450531.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本连锁中最初选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧攻击表示特殊召唤到其持有者（自己）的场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
