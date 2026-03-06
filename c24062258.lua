--暗躍のドルイド・ドリュース
-- 效果：
-- 这张卡召唤成功时，可以从自己墓地选择「暗跃的德鲁伊·橡木」以外的1只攻击力或者守备力是0的暗属性·4星怪兽表侧守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。「暗跃的德鲁伊·橡木」的效果1回合只能使用1次。
function c24062258.initial_effect(c)
	-- 诱发选发效果，通常召唤成功时发动，效果描述为“特殊召唤”，分类为特殊召唤，触发条件为召唤成功，具有取对象效果，每回合只能发动一次
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(24062258,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,24062258)
	e1:SetTarget(c24062258.sptg)
	e1:SetOperation(c24062258.spop)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选满足条件的怪兽：不是「暗跃的德鲁伊·橡木」、等级为4、属性为暗、攻击力或守备力为0，并且可以特殊召唤
function c24062258.filter(c,e,tp)
	return not c:IsCode(24062258) and c:IsLevel(4) and c:IsAttribute(ATTRIBUTE_DARK) and (c:IsAttack(0) or c:IsDefense(0))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果的处理目标函数，判断是否满足选择目标的条件，包括墓地中的符合条件的怪兽和场上是否有空位
function c24062258.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c24062258.filter(chkc,e,tp) end
	-- 判断是否满足选择目标的条件，检查墓地是否存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c24062258.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 判断是否满足选择目标的条件，检查场上是否有足够的空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 向玩家发送提示信息，提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从玩家墓地中选择符合条件的1只怪兽作为效果的目标
	local g=Duel.SelectTarget(tp,c24062258.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果的处理信息，确定要特殊召唤的怪兽数量为1
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果的处理函数，执行特殊召唤操作并使召唤的怪兽效果无效
function c24062258.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否仍然在场上，并尝试特殊召唤该怪兽到守备表示
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
		-- 使特殊召唤的怪兽效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 使特殊召唤的怪兽效果无效（针对效果无效）
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
	-- 完成特殊召唤流程，确保所有特殊召唤步骤都已处理完毕
	Duel.SpecialSummonComplete()
end
