--マグネット・リバース
-- 效果：
-- ①：从自己墓地的怪兽以及除外的自己怪兽之中以1只机械族·岩石族的不能通常召唤的怪兽为对象才能发动。那只怪兽特殊召唤。
function c80352158.initial_effect(c)
	-- ①：从自己墓地的怪兽以及除外的自己怪兽之中以1只机械族·岩石族的不能通常召唤的怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c80352158.target)
	e1:SetOperation(c80352158.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：表侧表示（除外区）、属于机械族或岩石族、不能通常召唤且可以特殊召唤的怪兽
function c80352158.filter(c,e,tp)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE+RACE_ROCK) and not c:IsSummonableCard()
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的目标选择与合法性检测
function c80352158.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and c80352158.filter(chkc,e,tp) end
	-- 检查发动时自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地或除外区是否存在至少1只满足条件的、可作为效果对象的怪兽
		and Duel.IsExistingTarget(c80352158.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 向玩家发送提示信息：请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地或除外区选择1只满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c80352158.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置效果处理信息：特殊召唤该对象怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：特殊召唤作为对象的怪兽
function c80352158.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
