--ガガガガンマン
-- 效果：
-- 4星怪兽×2
-- ①：1回合1次，把这张卡1个超量素材取除才能发动。这张卡的表示形式的以下效果适用。
-- ●攻击表示：这个回合，这张卡向对方怪兽攻击的伤害步骤内，这张卡的攻击力上升1000，那只对方怪兽的攻击力下降500。
-- ●守备表示：给与对方800伤害。
function c12014404.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：用2只4星怪兽叠放来进行超量召唤。
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除才能发动。这张卡的表示形式的以下效果适用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DAMAGE)
	e1:SetDescription(aux.Stringid(12014404,0))  --"攻击变化"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c12014404.cost)
	e1:SetTarget(c12014404.target)
	e1:SetOperation(c12014404.operation)
	c:RegisterEffect(e1)
end
-- 发动代价处理：确认这张卡有1个超量素材可取除，然后实际取除1个作为发动COST。
function c12014404.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 发动条件判定：无额外发动条件；若这张卡为守备表示，则登记将给与对方800伤害的操作信息。
function c12014404.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	if e:GetHandler():IsDefensePos() then
		-- 登记这次效果处理将给对方造成800伤害的操作信息，供相关卡牌连锁时参考。
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,800)
	end
end
-- 效果处理：根据这张卡当前表示形式执行对应分支——守备表示直接给与对方800伤害；攻击表示则给这张卡注册一个在伤害步骤开始时触发的效果，用于之后提升自身攻击力并降低对方怪兽攻击力。
function c12014404.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if c:IsDefensePos() then
		-- 以效果原因给对方造成800点伤害。
		Duel.Damage(1-tp,800,REASON_EFFECT)
	elseif c:IsPosition(POS_FACEUP_ATTACK) then
		-- ●攻击表示：这个回合，这张卡向对方怪兽攻击的伤害步骤内，这张卡的攻击力上升1000，那只对方怪兽的攻击力下降500。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EVENT_BATTLE_START)
		e1:SetOperation(c12014404.atkop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 伤害步骤开始时的处理：当本卡作为攻击怪兽且存在战斗对象时，给自身附加攻击力+1000的永续效果，给战斗对象附加攻击力-500的永续效果，并用标志防止该回合重复发动。
function c12014404.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	-- 判断当前攻击怪兽是否就是这张卡，且存在战斗对象，确保只在它向对方怪兽攻击的伤害步骤内生效。
	if c==Duel.GetAttacker() and bc then
		if c:GetFlagEffect(12014404)~=0 then return end
		-- 让这张卡的攻击力上升1000。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		c:RegisterEffect(e1)
		-- 让那只对方怪兽的攻击力下降500。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(-500)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		bc:RegisterEffect(e2)
		c:RegisterFlagEffect(12014404,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE,0,1)
	end
end
