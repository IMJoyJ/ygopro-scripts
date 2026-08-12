--SRダブルヨーヨー
-- 效果：
-- ①：这张卡召唤成功时，以自己墓地1只3星以下的「疾行机人」怪兽为对象才能发动。那只怪兽特殊召唤。
function c53054833.initial_effect(c)
	-- ①：这张卡召唤成功时，以自己墓地1只3星以下的「疾行机人」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(53054833,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c53054833.target)
	e1:SetOperation(c53054833.operation)
	c:RegisterEffect(e1)
end
-- 检查目标怪兽是否满足等级3以下、属于疾行机人系列且可以被特殊召唤的条件
function c53054833.filter(c,e,tp)
	return c:IsLevelBelow(3) and c:IsSetCard(0x2016) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设定效果的目标选择逻辑，确保只能选择自己墓地中的符合条件的怪兽
function c53054833.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c53054833.filter(chkc,e,tp) end
	-- 判断场上是否有足够的空间进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认自己墓地中是否存在至少一只符合条件的怪兽
		and Duel.IsExistingTarget(c53054833.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家提示选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择一只满足条件的墓地怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c53054833.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁的操作信息，表明将要特殊召唤一只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 处理效果的发动部分，获取目标怪兽并尝试将其特殊召唤
function c53054833.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果选定的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以正面表示的形式特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
