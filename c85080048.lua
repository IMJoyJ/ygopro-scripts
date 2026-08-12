--雷の裁き
-- 效果：
-- ①：自己场上有雷族怪兽召唤·反转召唤·特殊召唤时，以对方场上1张卡为对象才能发动。那张对方的卡破坏。
function c85080048.initial_effect(c)
	-- ①：自己场上有雷族怪兽召唤·反转召唤·特殊召唤时，以对方场上1张卡为对象才能发动。那张对方的卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c85080048.condition)
	e1:SetTarget(c85080048.target)
	e1:SetOperation(c85080048.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 过滤条件：自己场上表侧表示的雷族怪兽
function c85080048.cfilter(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_THUNDER) and c:IsControler(tp)
end
-- 发动条件：检查当前召唤、反转召唤或特殊召唤的怪兽中，是否存在自己场上的表侧表示雷族怪兽
function c85080048.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c85080048.cfilter,1,nil,tp)
end
-- 效果发动：进行对象选择并设置破坏操作信息
function c85080048.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 在发动阶段，检查对方场上是否存在至少1张可以作为对象的目标卡
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张卡作为效果的对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：该效果将破坏所选择的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：将作为对象的卡破坏
function c85080048.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果破坏该对象卡
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
