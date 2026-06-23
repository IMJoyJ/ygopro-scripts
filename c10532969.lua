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
-- 效果发动条件：造成战斗伤害的玩家不是效果持有者
function c10532969.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 效果目标选择函数
function c10532969.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) end
	-- 判断是否满足选择目标的条件：对方场上存在至少1只怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家提示选择要破坏的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	-- 选择对方场上1只怪兽作为破坏对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息为破坏效果
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理函数
function c10532969.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的破坏对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
