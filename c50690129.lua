--キャシー・イヴL2
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡在手卡存在的场合，以自己场上1只3星以上的怪兽为对象才能发动。那只怪兽的等级下降2星，这张卡特殊召唤。
function c50690129.initial_effect(c)
	-- ①：这张卡在手卡存在的场合，以自己场上1只3星以上的怪兽为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(50690129,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,50690129)
	e1:SetTarget(c50690129.target)
	e1:SetOperation(c50690129.operation)
	c:RegisterEffect(e1)
end
-- 筛选场上表侧表示且等级大于等于3的怪兽
function c50690129.filter(c)
	return c:IsFaceup() and c:IsLevelAbove(3)
end
-- 效果处理时检查是否满足发动条件
function c50690129.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c50690129.filter(chkc) end
	local c=e:GetHandler()
	-- 检查场上是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c50690129.filter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查是否有足够的召唤区域并确认自身可以特殊召唤
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 提示玩家选择目标怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择符合条件的目标怪兽
	Duel.SelectTarget(tp,c50690129.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果处理信息，准备特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 处理效果的发动
function c50690129.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsImmuneToEffect(e) or tc:GetLevel()<3 then return end
	local c=e:GetHandler()
	-- 使目标怪兽的等级下降2星
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(-2)
	tc:RegisterEffect(e1)
	if not tc:IsImmuneToEffect(e1) and c:IsRelateToEffect(e) then
		-- 将自身特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
