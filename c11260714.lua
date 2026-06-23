--堕天使スペルビア
-- 效果：
-- ①：这张卡从墓地的特殊召唤成功时，以「堕天使 苏泊比亚」以外的自己墓地1只天使族怪兽为对象才能发动。那只天使族怪兽特殊召唤。
function c11260714.initial_effect(c)
	-- ①：这张卡从墓地的特殊召唤成功时，以「堕天使 苏泊比亚」以外的自己墓地1只天使族怪兽为对象才能发动。那只天使族怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(11260714,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c11260714.spcon)
	e1:SetTarget(c11260714.sptg)
	e1:SetOperation(c11260714.spop)
	c:RegisterEffect(e1)
end
-- 判断此卡是否由墓地特殊召唤成功
function c11260714.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_GRAVE)
end
-- 筛选满足条件的天使族怪兽（非苏泊比亚且可特殊召唤）
function c11260714.filter(c,e,sp)
	return c:IsRace(RACE_FAIRY) and not c:IsCode(11260714) and c:IsCanBeSpecialSummoned(e,0,sp,false,false)
end
-- 设置效果的发动目标选择逻辑
function c11260714.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c11260714.filter(chkc,e,tp) end
	-- 判断是否满足发动条件（场上是否有空位且墓地存在符合条件的怪兽）
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否存在符合条件的墓地目标怪兽
		and Duel.IsExistingTarget(c11260714.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家提示选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 选择符合条件的墓地目标怪兽
	local g=Duel.SelectTarget(tp,c11260714.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息，确定将要特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理函数，执行特殊召唤操作
function c11260714.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsRace(RACE_FAIRY) then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
