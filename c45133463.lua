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
-- 筛选出之前在墓地、且之前控制者为自己、且原本为怪兽的卡
function c45133463.cfiltetr(c,tp)
	return c:IsPreviousLocation(LOCATION_GRAVE) and c:IsPreviousControler(tp) and c:GetOriginalType()&TYPE_MONSTER~=0
end
-- 检查是否有满足条件的卡从墓地被特殊召唤
function c45133463.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c45133463.cfiltetr,1,nil,tp)
end
-- 筛选出卡号为苏帕伊(78552773)或赤蚁(78275321)且可以特殊召唤的卡
function c45133463.filter(c,e,tp)
	return c:IsCode(78552773,78275321) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置选择目标时的过滤条件，确保选择的是自己墓地的苏帕伊或赤蚁
function c45133463.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c45133463.filter(chkc,e,tp) end
	-- 判断场上是否有空位可以特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认自己墓地是否存在符合条件的苏帕伊或赤蚁
		and Duel.IsExistingTarget(c45133463.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的1只苏帕伊或赤蚁作为特殊召唤目标
	local g=Duel.SelectTarget(tp,c45133463.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置本次效果的操作信息，表明将特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 处理效果发动时的特殊召唤操作
function c45133463.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡以正面表示的形式特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
