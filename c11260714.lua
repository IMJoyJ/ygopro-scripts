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
-- 发动条件判定：确认此卡在特殊召唤成功之前所在位置为墓地，即符合“从墓地的特殊召唤成功时”。
function c11260714.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_GRAVE)
end
-- 对象筛选函数：选择自己墓地中种族为天使族、卡名不是「堕天使 苏泊比亚」且能被特殊召唤的怪兽。
function c11260714.filter(c,e,sp)
	return c:IsRace(RACE_FAIRY) and not c:IsCode(11260714) and c:IsCanBeSpecialSummoned(e,0,sp,false,false)
end
-- 发动时的目标选择整体处理：对已选对象进行合法性校验；在发动阶段确认是否满足发动条件，并选择对象。
function c11260714.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c11260714.filter(chkc,e,tp) end
	-- 检查自己场上主要怪兽区是否有可用的空格，用于后续特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1张满足filter条件且能成为效果对象的卡，作为发动前提；若满足，则效果可以发动。
		and Duel.IsExistingTarget(c11260714.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向操作者显示选择提示：请选择要特殊召唤的卡（HINTMSG_SPSUMMON）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让操作者从自己墓地的满足条件的卡中选择1只天使族怪兽，并将其设为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,c11260714.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 将当前连锁的操作信息设定为“特殊召唤”，对象为选中的卡，数量为1，供其他效果进行连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：从当前连锁中获取对象，若对象仍与效果关联且仍为天使族，则进行特殊召唤；否则不处理。
function c11260714.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中登记的效果对象（目标怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsRace(RACE_FAIRY) then
		-- 将对象怪兽以表侧表示特殊召唤到己方场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
