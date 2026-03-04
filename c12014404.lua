--ガガガガンマン
-- 效果：
-- 4星怪兽×2
-- ①：1回合1次，把这张卡1个超量素材取除才能发动。这张卡的表示形式的以下效果适用。
-- ●攻击表示：这个回合，这张卡向对方怪兽攻击的伤害步骤内，这张卡的攻击力上升1000，那只对方怪兽的攻击力下降500。
-- ●守备表示：给与对方800伤害。
function c12014404.initial_effect(c)
	-- 为卡片添加等级为4、需要2只怪兽进行XYZ召唤的手续
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
-- 设置效果的费用函数为c12014404.cost，消耗1个超量素材
function c12014404.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 设置效果的目标函数为c12014404.target，用于判断是否发动效果
function c12014404.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	if e:GetHandler():IsDefensePos() then
		-- 当此卡处于守备表示时，设置连锁操作信息为对对方造成800伤害
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,800)
	end
end
-- 设置效果的发动函数为c12014404.operation，处理效果的发动与执行
function c12014404.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if c:IsDefensePos() then
		-- 当此卡处于守备表示时，对对方玩家造成800伤害
		Duel.Damage(1-tp,800,REASON_EFFECT)
	elseif c:IsPosition(POS_FACEUP_ATTACK) then
		-- 当此卡处于攻击表示时，在伤害步骤开始时触发效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EVENT_BATTLE_START)
		e1:SetOperation(c12014404.atkop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 设置在伤害步骤开始时触发的效果函数为c12014404.atkop
function c12014404.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	-- 判断当前攻击的卡是否为本卡且存在战斗目标
	if c==Duel.GetAttacker() and bc then
		if c:GetFlagEffect(12014404)~=0 then return end
		-- ●攻击表示：这个回合，这张卡向对方怪兽攻击的伤害步骤内，这张卡的攻击力上升1000
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		c:RegisterEffect(e1)
		-- ●攻击表示：这个回合，这张卡向对方怪兽攻击的伤害步骤内，那只对方怪兽的攻击力下降500
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
