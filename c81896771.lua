--エレキジ
-- 效果：
-- 这张卡可以直接攻击对方玩家。这张卡直接攻击给与对方基本分战斗伤害时，选择场上表侧表示存在的1只怪兽，直到这个回合的结束阶段时从游戏中除外。
function c81896771.initial_effect(c)
	-- 这张卡可以直接攻击对方玩家。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e1)
	-- 这张卡直接攻击给与对方基本分战斗伤害时，选择场上表侧表示存在的1只怪兽，直到这个回合的结束阶段时从游戏中除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(81896771,0))  --"暂时除外"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetCondition(c81896771.condition)
	e2:SetTarget(c81896771.target)
	e2:SetOperation(c81896771.operation)
	c:RegisterEffect(e2)
end
-- 判定效果发动的条件：给与对方玩家战斗伤害，且是直接攻击。
function c81896771.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定受到伤害的是对方玩家，且攻击对象为空（即直接攻击）。
	return ep~=tp and Duel.GetAttackTarget()==nil
end
-- 过滤场上表侧表示且可以被除外的怪兽。
function c81896771.filter(c)
	return c:IsFaceup() and c:IsAbleToRemove()
end
-- 效果发动时的对象选择与操作信息设置。
function c81896771.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c81896771.filter(chkc) end
	-- 判定场上是否存在至少1只表侧表示且可以被除外的怪兽。
	if chk==0 then return Duel.IsExistingTarget(c81896771.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择场上1只表侧表示的怪兽作为效果的对象。
	local g=Duel.SelectTarget(tp,c81896771.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息为“除外选中的怪兽”。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果处理：将选择的怪兽暂时除外，并注册在回合结束阶段将其返回场上的效果。
function c81896771.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时选中的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 判定对象怪兽是否仍适用效果且表侧表示，并将其以效果原因暂时除外。
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		-- 直到这个回合的结束阶段时从游戏中除外。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(tc)
		e1:SetCountLimit(1)
		e1:SetOperation(c81896771.retop)
		-- 注册在回合结束阶段将除外怪兽返回场上的全局延迟效果。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 暂时除外怪兽返回场上的效果处理函数。
function c81896771.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将被暂时除外的怪兽返回到场上。
	Duel.ReturnToField(e:GetLabelObject())
end
