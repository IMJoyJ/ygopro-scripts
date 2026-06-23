--ガガガボルト
-- 效果：
-- 自己场上有名字带有「我我我」的怪兽存在的场合才能发动。选择场上1张卡破坏。
function c17494901.initial_effect(c)
	-- 自己场上有名字带有「我我我」的怪兽存在的场合才能发动。选择场上1张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c17494901.condition)
	e1:SetTarget(c17494901.target)
	e1:SetOperation(c17494901.activate)
	c:RegisterEffect(e1)
end
-- 检查场上是否存在表侧表示的「我我我」怪兽
function c17494901.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x54)
end
-- 判断是否满足发动条件，即自己场上存在名字带有「我我我」的怪兽
function c17494901.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张名字带有「我我我」的怪兽
	return Duel.IsExistingMatchingCard(c17494901.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 设置效果的目标选择逻辑，允许选择场上1张卡作为破坏对象
function c17494901.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc~=e:GetHandler() end
	-- 判断是否满足发动条件，即自己场上存在至少1张可以成为破坏对象的卡
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 向玩家提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张卡作为破坏对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 设置连锁操作信息，确定要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行破坏效果，将目标卡破坏
function c17494901.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡以效果原因破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
