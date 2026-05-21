--ブラック・ボンバー
-- 效果：
-- 这张卡召唤成功时，可以把自己墓地存在的1只机械族·暗属性的4星怪兽表侧守备表示特殊召唤。这个效果特殊召唤的效果怪兽的效果无效化。
function c88671720.initial_effect(c)
	-- 这张卡召唤成功时，可以把自己墓地存在的1只机械族·暗属性的4星怪兽表侧守备表示特殊召唤。这个效果特殊召唤的效果怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(88671720,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c88671720.sumtg)
	e1:SetOperation(c88671720.sumop)
	c:RegisterEffect(e1)
end
-- 过滤出自己墓地中等级为4、机械族、暗属性且能以表侧守备表示特殊召唤的怪兽
function c88671720.filter(c,e,tp)
	return c:IsLevel(4) and c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_DARK)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果发动的目标选择与合法性检测（检查墓地中是否存在符合条件的怪兽，以及自己场上是否有空余的怪兽区域）
function c88671720.sumtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c88671720.filter(chkc,e,tp) end
	-- 检查自己墓地是否存在至少1只符合条件的怪兽作为效果对象
	if chk==0 then return Duel.IsExistingTarget(c88671720.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 检查自己场上是否有空余的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地中1只符合条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c88671720.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁信息，表明该效果包含将选定怪兽特殊召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理的执行逻辑（将选定的怪兽表侧守备表示特殊召唤，并使其效果无效化）
function c88671720.sumop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取在发动阶段选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍与效果相关，并尝试将其以表侧守备表示特殊召唤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
		-- 这个效果特殊召唤的效果怪兽的效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 这个效果特殊召唤的效果怪兽的效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
	-- 完成特殊召唤的最终处理
	Duel.SpecialSummonComplete()
end
