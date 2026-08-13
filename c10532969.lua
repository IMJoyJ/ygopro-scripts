--エンシェント・シャーク ハイパー・メガロドン
-- 效果：
-- 这张卡给与对方基本分战斗伤害时，可以选择对方场上1只怪兽破坏。
function c10532969.initial_effect(c)
	-- 这张卡给与对方基本分战斗伤害时，可以选择对方场上1只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10532969,0))  --"怪兽破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(c10532969.condition)
	e1:SetTarget(c10532969.target)
	e1:SetOperation(c10532969.operation)
	c:RegisterEffect(e1)
end
-- 作为诱发效果的发动条件，仅当这张卡的战斗伤害是给与对方基本分（即受到伤害的玩家ep不是本卡控制者tp）时，该效果才满足发动条件。
function c10532969.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 目标选择函数：进行取对象发动时的合法性检查，并在满足条件时从对方场上选择1只怪兽作为效果对象，同时设置破坏相关的操作信息。
function c10532969.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) end
	-- 在发动时（chk==0）检查对方场上是否存在至少1只可选怪兽，只有存在可选对象时才允许发动效果。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 向操作玩家tp显示选择提示，提示内容为“请选择要破坏的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从对方场上（tp的对方区域）选择1只怪兽作为效果对象，并通过Duel.SelectTarget将所选卡与当前连锁关联。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 将本次连锁的处理信息设置为“破坏1张卡”，供后续效果检测和连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理函数：在效果结算时获取之前选择的对象怪兽，若该怪兽仍与效果相关联，则将其破坏。
function c10532969.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时所选择的1只对象怪兽（即之前用Duel.SelectTarget选中的对方场上的怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果（REASON_EFFECT）为原因破坏该对象怪兽，完成“选择对方场上1只怪兽破坏”的规则处理。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
