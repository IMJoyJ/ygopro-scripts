--暗躍のドルイド・ドリュース
-- 效果：
-- 这张卡召唤成功时，可以从自己墓地选择「暗跃的德鲁伊·橡木」以外的1只攻击力或者守备力是0的暗属性·4星怪兽表侧守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。「暗跃的德鲁伊·橡木」的效果1回合只能使用1次。
function c24062258.initial_effect(c)
	-- 这张卡召唤成功时，可以从自己墓地选择「暗跃的德鲁伊·橡木」以外的1只攻击力或者守备力是0的暗属性·4星怪兽表侧守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。「暗跃的德鲁伊·橡木」的效果1回合只能使用1次。
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
-- 筛选「暗跃的德鲁伊·橡木」以外的4星暗属性怪兽，且攻击力或守备力为0，并可被表侧守备表示特殊召唤的卡。
function c24062258.filter(c,e,tp)
	return not c:IsCode(24062258) and c:IsLevel(4) and c:IsAttribute(ATTRIBUTE_DARK) and (c:IsAttack(0) or c:IsDefense(0))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 发动前检查：选择自己墓地符合条件的对象，并确认自己主要怪兽区有空位。
function c24062258.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c24062258.filter(chkc,e,tp) end
	-- 检查自己墓地是否存在至少1只满足条件的怪兽。
	if chk==0 then return Duel.IsExistingTarget(c24062258.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 并且自己场上主要怪兽区有可用空格。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只符合条件的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c24062258.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息，声明本连锁将进行特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：将对象怪兽表侧守备表示特殊召唤，并使其效果无效化。
function c24062258.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 若对象仍与该效果关联且可以特殊召唤，则将其表侧守备表示特殊召唤（分步特殊召唤）。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
	-- 完成特殊召唤处理。
	Duel.SpecialSummonComplete()
end
