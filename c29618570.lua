--グレイ・ウイング
-- 效果：
-- 在主要阶段一丢弃1张手卡。这张卡在那个回合的战斗阶段中可以2次攻击。
function c29618570.initial_effect(c)
	-- 在主要阶段一丢弃1张手卡。这张卡在那个回合的战斗阶段中可以2次攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(29618570,0))  --"两次攻击"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c29618570.atkcon)
	e1:SetCost(c29618570.atkcost)
	e1:SetTarget(c29618570.atktg)
	e1:SetOperation(c29618570.atkop)
	c:RegisterEffect(e1)
end
-- 该函数作为效果的发动条件，检查当前回合玩家是否能够进入战斗阶段（即处于主要阶段一且满足进入战斗阶段的限制），只有满足时才能发动效果。
function c29618570.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 调用API判断回合玩家能否进入战斗阶段，返回真表示效果可以发动。
	return Duel.IsAbleToEnterBP()
end
-- 该函数处理效果的发动代价：先判定手牌中有无可丢弃的卡，若有则丢弃1张手牌作为代价。
function c29618570.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动前（chk==0时）检查手牌是否存在至少1张可丢弃的卡，以确认代价是否可支付。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家从手牌选择并丢弃1张卡，丢弃原因设置为代价（REASON_COST）并附加丢弃标记（REASON_DISCARD）。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 该函数为效果的目标/发动可行性判定：检查此卡当前是否没有被赋予额外攻击次数效果（EFFECT_EXTRA_ATTACK），避免重复获得额外攻击。
function c29618570.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetEffectCount(EFFECT_EXTRA_ATTACK)==0 end
end
-- 效果处理时：确认此卡仍与效果关联且为表侧表示后，创建一个额外攻击效果，使此卡本回合的战斗阶段可多攻击1次（合计2次攻击），该效果不会因其他效果被无效，并在回合结束时重置。
function c29618570.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡在那个回合的战斗阶段中可以2次攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
