--ラピッド・ウォリアー
-- 效果：
-- 主要阶段1才能发动。这个回合这张卡可以直接攻击对方玩家。这个效果发动的回合，这张卡以外的怪兽不能攻击。
function c255998.initial_effect(c)
	-- 主要阶段1才能发动。这个回合这张卡可以直接攻击对方玩家。这个效果发动的回合，这张卡以外的怪兽不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(255998,0))  --"直接攻击"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c255998.condition)
	e1:SetCost(c255998.cost)
	e1:SetOperation(c255998.operation)
	c:RegisterEffect(e1)
end
-- 发动条件：仅在当前回合玩家可以进入战斗阶段且这张卡尚未获得直接攻击效果时才能发动。
function c255998.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否满足发动条件：回合玩家可以进入战斗阶段，且此卡没有适用中的直接攻击效果。
	return Duel.IsAbleToEnterBP() and not e:GetHandler():IsHasEffect(EFFECT_DIRECT_ATTACK)
end
-- 作为不能攻击效果的过滤器：只让FieldID与效果Label记录值不同的卡受到‘不能攻击’影响，即放行发动效果的这张卡自身。
function c255998.ftarget(e,c)
	return e:GetLabel()~=c:GetFieldID()
end
-- 发动时处理：无实际代价（chk==0返回true），但会立即将‘这张卡以外的我方怪兽不能攻击’的誓约效果注册到场上，持续到结束阶段。
function c255998.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 这个效果发动的回合，这张卡以外的怪兽不能攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c255998.ftarget)
	e1:SetLabel(e:GetHandler():GetFieldID())
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将上述不能攻击的誓约效果注册到场上，使其对发动玩家tp场上的怪兽生效，持续到结束阶段。
	Duel.RegisterEffect(e1,tp)
end
-- 效果处理：若此卡仍表侧表示且与发动效果仍有关联，则给它附加可直接攻击效果，持续到这个回合结束。
function c255998.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这个回合这张卡可以直接攻击对方玩家。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DIRECT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
