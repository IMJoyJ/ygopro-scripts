--ワルキューレ・ヴリュンヒルデ
-- 效果：
-- ①：这张卡的攻击力上升对方场上的怪兽数量×500。
-- ②：这张卡不受对方的魔法卡的效果影响。
-- ③：对方怪兽的攻击宣言时才能发动。这张卡的守备力下降1000，这个回合，自己的「女武神」怪兽不会被战斗破坏。
function c2204038.initial_effect(c)
	-- 效果原文：②：这张卡不受对方的魔法卡的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c2204038.efilter)
	c:RegisterEffect(e1)
	-- 效果原文：①：这张卡的攻击力上升对方场上的怪兽数量×500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(c2204038.atkval)
	c:RegisterEffect(e2)
	-- 效果原文：③：对方怪兽的攻击宣言时才能发动。这张卡的守备力下降1000，这个回合，自己的「女武神」怪兽不会被战斗破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(2204038,0))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c2204038.ptcon)
	e3:SetTarget(c2204038.pttg)
	e3:SetOperation(c2204038.ptop)
	c:RegisterEffect(e3)
end
-- 规则层面：使魔法卡的效果无法影响此卡。
function c2204038.efilter(e,te)
	return te:IsActiveType(TYPE_SPELL) and te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
-- 规则层面：计算对方场上怪兽数量并乘以500作为攻击力加成。
function c2204038.atkval(e,c)
	-- 规则层面：获取对方场上怪兽数量。
	return Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_MZONE)*500
end
-- 规则层面：判断攻击方是否为对方且参与战斗。
function c2204038.ptcon(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：获取当前攻击的卡。
	local at=Duel.GetAttacker()
	return at and at:IsControler(1-tp) and at:IsRelateToBattle()
end
-- 规则层面：检查此卡守备力是否大于等于1000。
function c2204038.pttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetDefense()>=1000 end
end
-- 规则层面：将此卡守备力减少1000，并使己方女武神怪兽在本回合内不会被战斗破坏。
function c2204038.ptop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() and c:GetDefense()>=1000 then
		-- 效果作用：使此卡守备力减少1000。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		e1:SetCode(EFFECT_UPDATE_DEFENSE)
		e1:SetValue(-1000)
		c:RegisterEffect(e1)
		-- 效果作用：使己方女武神怪兽在本回合内不会被战斗破坏。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e2:SetTargetRange(LOCATION_MZONE,0)
		e2:SetReset(RESET_PHASE+PHASE_END)
		e2:SetTarget(c2204038.ptfilter)
		e2:SetValue(1)
		-- 规则层面：将效果e2注册给玩家tp。
		Duel.RegisterEffect(e2,tp)
	end
end
-- 规则层面：判断目标怪兽是否为女武神族。
function c2204038.ptfilter(e,c)
	return c:IsSetCard(0x122)
end
