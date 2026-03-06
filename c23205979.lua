--魂を削る死霊
-- 效果：
-- ①：这张卡不会被战斗破坏。
-- ②：这张卡直接攻击给与对方战斗伤害的场合发动。对方手卡随机选1张丢弃。
-- ③：场上的表侧表示的这张卡成为效果的对象的场合破坏。
function c23205979.initial_effect(c)
	-- 效果原文：①：这张卡不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 效果原文：②：这张卡直接攻击给与对方战斗伤害的场合发动。对方手卡随机选1张丢弃。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(23205979,0))  --"丢弃手牌"
	e2:SetCategory(CATEGORY_HANDES)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetCondition(c23205979.condition)
	e2:SetTarget(c23205979.target)
	e2:SetOperation(c23205979.operation)
	c:RegisterEffect(e2)
	-- 效果原文：③：场上的表侧表示的这张卡成为效果的对象的场合破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_SELF_DESTROY)
	e3:SetCondition(c23205979.sdcon)
	c:RegisterEffect(e3)
	-- 效果作用：当此卡成为对方效果的对象时，若满足条件则破坏此卡。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EVENT_BECOME_TARGET)
	e4:SetOperation(c23205979.desop1)
	c:RegisterEffect(e4)
	-- 效果作用：连锁处理结束时，若满足条件则破坏此卡。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EVENT_CHAIN_SOLVED)
	e5:SetOperation(c23205979.desop2)
	e5:SetLabelObject(e4)
	c:RegisterEffect(e5)
	-- 效果作用：战斗阶段结束时，若满足条件则破坏此卡。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCode(EVENT_BATTLED)
	e6:SetOperation(c23205979.desop3)
	e6:SetLabelObject(e4)
	c:RegisterEffect(e6)
end
-- 规则层面：判断是否为直接攻击且对方受到战斗伤害
function c23205979.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：攻击玩家不等于伤害接受玩家且未被攻击的怪兽攻击
	return ep~=tp and Duel.GetAttackTarget()==nil
end
-- 规则层面：设置丢弃手牌的效果信息
function c23205979.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 规则层面：设置丢弃对方1张手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_HANDES,0,0,1-tp,1)
end
-- 规则层面：随机选择对方1张手牌丢弃
function c23205979.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：获取对方手牌组
	local g=Duel.GetFieldGroup(ep,LOCATION_HAND,0)
	if g:GetCount()==0 then return end
	local sg=g:RandomSelect(1-tp,1)
	-- 规则层面：将选中的手牌送去墓地（丢弃）
	Duel.SendtoGrave(sg,REASON_DISCARD+REASON_EFFECT)
end
-- 规则层面：判断此卡是否被对方效果影响
function c23205979.sdcon(e)
	return e:GetHandler():GetOwnerTargetCount()>0
end
-- 规则层面：记录此卡被影响时的连锁效果
function c23205979.desop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsLocation(LOCATION_MZONE) and c:IsFaceup() then
		e:SetLabelObject(re)
		e:SetLabel(0)
	end
end
-- 规则层面：连锁处理结束时判断是否需要破坏此卡
function c23205979.desop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if re==e:GetLabelObject():GetLabelObject() and c:IsRelateToEffect(re) then
		-- 规则层面：若当前处于伤害步骤且尚未计算伤害，则标记此卡需破坏
		if Duel.GetCurrentPhase()==PHASE_DAMAGE and not Duel.IsDamageCalculated() then
			e:GetLabelObject():SetLabel(1)
		else
			if c:IsHasEffect(EFFECT_DISABLE) then return end
			-- 规则层面：若此卡未被无效且未被禁用，则将其破坏
			if not c:IsDisabled() then Duel.Destroy(c,REASON_EFFECT) end
		end
	end
end
-- 规则层面：战斗阶段结束时判断是否需要破坏此卡
function c23205979.desop3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local des=e:GetLabelObject():GetLabel()
	e:GetLabelObject():SetLabel(0)
	if c:IsHasEffect(EFFECT_DISABLE) then return end
	if des==1 and not c:IsDisabled() then
		-- 规则层面：将此卡破坏
		Duel.Destroy(c,REASON_EFFECT)
	end
end
