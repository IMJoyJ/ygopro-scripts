--エレキンモグラ
-- 效果：
-- 这张卡在同1次的战斗阶段中可以作2次攻击。这张卡向里侧守备表示怪兽攻击的场合，可以不进行伤害计算以里侧守备表示的状态把那只怪兽破坏。
function c32548609.initial_effect(c)
	-- 这张卡在同1次的战斗阶段中可以作2次攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 这张卡向里侧守备表示怪兽攻击的场合，可以不进行伤害计算以里侧守备表示的状态把那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(32548609,0))  --"里侧守备的攻击对象怪兽破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetCondition(c32548609.descon)
	e2:SetTarget(c32548609.destg)
	e2:SetOperation(c32548609.desop)
	c:RegisterEffect(e2)
end
-- 判伤诱发效果的发动条件：攻击者为这张卡，且攻击对象是里侧守备表示怪兽。
function c32548609.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前战斗阶段中这张卡攻击的对象。
	local d=Duel.GetAttackTarget()
	-- 确认攻击者是本卡，且攻击对象存在、为里侧守备表示，满足效果发动条件。
	return e:GetHandler()==Duel.GetAttacker() and d and d:IsFacedown() and d:IsDefensePos()
end
-- 发动时确认攻击对象仍与战斗关联并登记破坏信息，同时进行可破坏对象的合法检查。
function c32548609.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动合法性检查时，要求攻击对象仍与本次战斗关联（未离场或状态未被重置）。
	if chk==0 then return Duel.GetAttackTarget():IsRelateToBattle() end
	-- 登记本次连锁将破坏攻击对象这1张卡的信息，供后续效果处理及对应检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,Duel.GetAttackTarget(),1,0,0)
end
-- 效果处理时，若攻击对象仍与本次战斗关联，则将其破坏且不进行伤害计算。
function c32548609.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时获取当前攻击对象。
	local d=Duel.GetAttackTarget()
	if d:IsRelateToBattle() then
		-- 以效果将攻击对象破坏。
		Duel.Destroy(d,REASON_EFFECT)
	end
end
