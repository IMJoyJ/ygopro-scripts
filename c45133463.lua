--死神の呼び声
-- 效果：
-- 从自己墓地有怪兽特殊召唤时才能发动。选择自己墓地存在的1只「苏帕伊」或者「赤蚁」特殊召唤。
function c45133463.initial_effect(c)
	-- 从自己墓地有怪兽特殊召唤时才能发动。选择自己墓地存在的1只「苏帕伊」或者「赤蚁」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c45133463.condition)
	e1:SetTarget(c45133463.target)
	e1:SetOperation(c45133463.activate)
	c:RegisterEffect(e1)
end
-- 筛选出之前在墓地、且控制者为自己的怪兽卡
function c45133463.cfiltetr(c,tp)
	return c:IsPreviousLocation(LOCATION_GRAVE) and c:IsPreviousControler(tp) and c:GetOriginalType()&TYPE_MONSTER~=0
end
-- 检查是否有满足条件的怪兽从墓地被特殊召唤
function c45133463.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c45133463.cfiltetr,1,nil,tp)
end
-- 筛选出卡号为「苏帕伊」或「赤蚁」且可以特殊召唤的卡片
function c45133463.filter(c,e,tp)
	return c:IsCode(78552773,78275321) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果的目标选择函数，用于选择墓地中的符合条件的卡片
function c45133463.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c45133463.filter(chkc,e,tp) end
	-- 判断是否满足发动条件：场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否满足发动条件：墓地中是否存在符合条件的卡片
		and Duel.IsExistingTarget(c45133463.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家提示“请选择要特殊召唤的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标卡片并设置为效果对象
	local g=Duel.SelectTarget(tp,c45133463.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息，确定将要特殊召唤的卡片数量和类型
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果发动时执行的操作：将选中的卡片特殊召唤
function c45133463.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果所选择的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片以正面表示的方式特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
