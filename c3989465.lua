--ラヴァルバル・イグニス
-- 效果：
-- 3星怪兽×2
-- 这张卡进行战斗的伤害步骤时只有1次，把这张卡1个超量素材取除才能发动。这张卡的攻击力直到结束阶段时上升500。
function c3989465.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：使用任意2只3星怪兽叠放来XYZ召唤这张卡。
	aux.AddXyzProcedure(c,nil,3,2)
	c:EnableReviveLimit()
	-- 这张卡进行战斗的伤害步骤时只有1次，把这张卡1个超量素材取除才能发动。这张卡的攻击力直到结束阶段时上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetDescription(aux.Stringid(3989465,0))  --"攻击上升"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c3989465.condition)
	e1:SetCost(c3989465.cost)
	e1:SetOperation(c3989465.operation)
	c:RegisterEffect(e1)
end
-- 发动条件的判定：当前必须处于伤害步骤，且这张卡是进行战斗的攻击怪兽或攻击对象，并且尚未进行伤害计算。
function c3989465.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段并存入局部变量ph。
	local ph=Duel.GetCurrentPhase()
	local c=e:GetHandler()
	-- 检查当前阶段是否为伤害步骤，且这张卡是否为攻击怪兽或攻击对象。
	return ph==PHASE_DAMAGE and (c==Duel.GetAttacker() or c==Duel.GetAttackTarget())
		-- 同时检查本次战斗尚未进行伤害计算，确保只能在伤害计算前发动。
		and not Duel.IsDamageCalculated()
end
-- 发动代价的判定与支付：先确认本伤害步骤内该效果尚未使用过，并且可以去除1个超量素材；满足后实际去除1个超量素材，并注册一个伤害步骤结束时重置的标志，限制“只有1次”。
function c3989465.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(3989465)==0 and e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
	e:GetHandler():RegisterFlagEffect(3989465,RESET_PHASE+PHASE_DAMAGE,0,1)
end
-- 效果处理：若这张卡仍表侧表示且与发动时的效果关联，则给它附加一个攻击力上升500的效果，该效果持续到结束阶段时重置。
function c3989465.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力直到结束阶段时上升500。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
