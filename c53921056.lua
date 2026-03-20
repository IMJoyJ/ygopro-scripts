--氷結界の虎将 ガンターラ
-- 效果：
-- ①：自己结束阶段，以「冰结界的虎将 健陀罗」以外的自己墓地1只「冰结界」怪兽为对象才能发动。那只怪兽特殊召唤。
function c53921056.initial_effect(c)
	-- ①：自己结束阶段，以「冰结界的虎将 健陀罗」以外的自己墓地1只「冰结界」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(53921056,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetCondition(c53921056.spcon)
	e1:SetTarget(c53921056.sptg)
	e1:SetOperation(c53921056.spop)
	c:RegisterEffect(e1)
end
-- 检索满足条件的墓地「冰结界」怪兽（非健陀罗且可特殊召唤）
function c53921056.filter(c,e,tp)
	return c:IsSetCard(0x2f) and not c:IsCode(53921056) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否为自己的结束阶段
function c53921056.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为自己的回合
	return Duel.GetTurnPlayer()==tp
end
-- 设置选择目标的条件和检查点
function c53921056.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c53921056.filter(chkc,e,tp) end
	-- 判断场上是否有足够的特殊召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断墓地是否存在满足条件的怪兽
		and Duel.IsExistingTarget(c53921056.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的墓地怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c53921056.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息，确定特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行特殊召唤操作
function c53921056.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽正面表示特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
