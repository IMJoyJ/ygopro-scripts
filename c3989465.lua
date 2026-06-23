--ラヴァルバル・イグニス
-- 效果：
-- 3星怪兽×2
-- 这张卡进行战斗的伤害步骤时只有1次，把这张卡1个超量素材取除才能发动。这张卡的攻击力直到结束阶段时上升500。
function c3989465.initial_effect(c)
	-- 添加XYZ召唤手续，使用等级为3的怪兽叠放2只以上
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
-- 判断是否处于伤害步骤且该卡为攻击怪或被攻击怪且尚未计算战斗伤害
function c3989465.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前阶段
	local ph=Duel.GetCurrentPhase()
	local c=e:GetHandler()
	-- 判断当前阶段为伤害步骤且该卡为攻击怪或被攻击怪
	return ph==PHASE_DAMAGE and (c==Duel.GetAttacker() or c==Duel.GetAttackTarget())
		-- 判断尚未计算战斗伤害
		and not Duel.IsDamageCalculated()
end
-- 支付效果代价，移除1个超量素材并标记已使用过此效果
function c3989465.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(3989465)==0 and e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
	e:GetHandler():RegisterFlagEffect(3989465,RESET_PHASE+PHASE_DAMAGE,0,1)
end
-- 将该卡攻击力上升500点直到结束阶段
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
