--CNo.73 激瀧瀑神アビス・スープラ
-- 效果：
-- 6星怪兽×3
-- ①：自己怪兽和对方怪兽进行战斗的伤害计算时1次，把这张卡1个超量素材取除才能发动。那只自己怪兽的攻击力只在那次伤害计算时上升那只对方怪兽的攻击力数值。
-- ②：这张卡有「No.73 激泷神 渊涛」在作为超量素材的场合，得到以下效果。
-- ●这张卡不会被效果破坏。
function c96864105.initial_effect(c)
	-- 添加XYZ召唤手续：6星怪兽×3
	aux.AddXyzProcedure(c,nil,6,3)
	c:EnableReviveLimit()
	-- ①：自己怪兽和对方怪兽进行战斗的伤害计算时1次，把这张卡1个超量素材取除才能发动。那只自己怪兽的攻击力只在那次伤害计算时上升那只对方怪兽的攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(96864105,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c96864105.atkcon)
	e1:SetCost(c96864105.atkcost)
	e1:SetOperation(c96864105.atkop)
	c:RegisterEffect(e1)
	-- ②：这张卡有「No.73 激泷神 渊涛」在作为超量素材的场合，得到以下效果。●这张卡不会被效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetCondition(c96864105.indcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
-- 设定这张卡的「No.」数值为73
aux.xyz_number[96864105]=73
-- 效果①的发动条件：自己怪兽和对方怪兽进行战斗
function c96864105.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取被攻击怪兽
	local d=Duel.GetAttackTarget()
	return d and a:GetControler()~=d:GetControler()
end
-- 效果①的代价：把这张卡1个超量素材取除，并添加该伤害计算时只能发动1次的限制
function c96864105.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) and c:GetFlagEffect(96864105)==0 end
	c:RemoveOverlayCard(tp,1,1,REASON_COST)
	c:RegisterFlagEffect(96864105,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL,0,1)
end
-- 效果①的效果处理：使进行战斗的自己怪兽的攻击力在伤害计算时上升对方怪兽的攻击力数值
function c96864105.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取被攻击怪兽
	local d=Duel.GetAttackTarget()
	if not a:IsRelateToBattle() or a:IsFacedown() or not d:IsRelateToBattle() or d:IsFacedown() then return end
	if a:IsControler(1-tp) then a,d=d,a end
	-- 那只自己怪兽的攻击力只在那次伤害计算时上升那只对方怪兽的攻击力数值。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetOwnerPlayer(tp)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
	e1:SetValue(d:GetAttack())
	a:RegisterEffect(e1)
end
-- 效果②的适用条件：超量素材中存在「No.73 激泷神 渊涛」
function c96864105.indcon(e)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,36076683)
end
