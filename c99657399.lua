--油断大敵
-- 效果：
-- 对方基本分回复时才能发动。选择对方场上存在的1只怪兽破坏。
function c99657399.initial_effect(c)
	-- 对方基本分回复时才能发动。选择对方场上存在的1只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_RECOVER)
	e1:SetCondition(c99657399.condition)
	e1:SetTarget(c99657399.target)
	e1:SetOperation(c99657399.activate)
	c:RegisterEffect(e1)
end
-- 发动条件：回复基本分的玩家不是效果发动者（即对方玩家回复基本分时才能发动）。
function c99657399.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 目标选择处理：检查合法对象，提示选择，从对方场上选择1只怪兽作为对象，并设置破坏的操作信息。
function c99657399.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 效果发动时检查对方场上是否存在1只可成为对象的怪兽，作为效果发动合法性条件。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 给玩家显示“请选择要破坏的卡”的选择提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从对方场上选择1只怪兽作为效果对象（取对象）。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置将选择的对象破坏的操作信息，用于后续效果处理及连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：取得对象怪兽，若该怪兽仍与效果关联则将其破坏。
function c99657399.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因破坏该对象怪兽。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
