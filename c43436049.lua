--ジャンク・ブレイカー
-- 效果：
-- ①：这张卡召唤成功的回合的自己主要阶段，把这张卡解放才能发动。场上的全部表侧表示怪兽的效果直到回合结束时无效。
function c43436049.initial_effect(c)
	-- ①：这张卡召唤成功的回合的自己主要阶段，把这张卡解放才能发动。场上的全部表侧表示怪兽的效果直到回合结束时无效。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetOperation(c43436049.sumsuc)
	c:RegisterEffect(e1)
	-- ①：这张卡召唤成功的回合的自己主要阶段，把这张卡解放才能发动。场上的全部表侧表示怪兽的效果直到回合结束时无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(43436049,0))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c43436049.condition)
	e2:SetCost(c43436049.cost)
	e2:SetTarget(c43436049.target)
	e2:SetOperation(c43436049.operation)
	c:RegisterEffect(e2)
end
-- 在怪兽召唤成功时，为该怪兽注册一个标记，用于后续判断是否处于可以发动效果的条件中。
function c43436049.sumsuc(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(43436049,RESET_EVENT+0x1ec0000+RESET_PHASE+PHASE_END,0,1)
end
-- 判断当前怪兽是否拥有召唤成功时设置的标记，以确定是否可以发动效果。
function c43436049.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(43436049)>0
end
-- 检查是否可以支付将自身解放作为效果的代价。
function c43436049.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将自身从游戏中解放，作为发动效果的代价。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 设置效果的目标为场上所有符合条件的表侧表示怪兽，并准备将它们的效果无效化。
function c43436049.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在至少一张符合条件的表侧表示怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NegateMonsterFilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
	-- 获取场上所有符合条件的表侧表示怪兽组成的组。
	local g=Duel.GetMatchingGroup(aux.NegateMonsterFilter,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
	-- 设置连锁操作信息，表明此效果将使怪兽效果无效。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,g:GetCount(),0,0)
end
-- 对场上所有符合条件的表侧表示怪兽分别施加效果无效和效果无效化的永久效果。
function c43436049.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有符合条件的表侧表示怪兽组成的组。
	local g=Duel.GetMatchingGroup(aux.NegateMonsterFilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		-- 为指定怪兽施加一个使其效果无效的效果，该效果在回合结束时自动解除。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 为指定怪兽施加一个使其效果无效化的永久效果，该效果在回合结束时自动解除。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
end
