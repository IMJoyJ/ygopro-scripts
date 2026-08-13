--弦魔人ムズムズリズム
-- 效果：
-- 3星怪兽×2
-- 自己场上的名字带有「魔人」的超量怪兽向对方怪兽攻击的伤害步骤时，把这张卡1个超量素材取除才能发动。那只攻击怪兽的攻击力直到结束阶段时变成2倍。「弦魔人 跃跃节奏」的效果1回合只能使用1次。
function c26563200.initial_effect(c)
	-- 为这张卡添加超量召唤手续：可用2只等级3的怪兽进行叠放来超量召唤。
	aux.AddXyzProcedure(c,nil,3,2)
	c:EnableReviveLimit()
	-- 自己场上的名字带有「魔人」的超量怪兽向对方怪兽攻击的伤害步骤时，把这张卡1个超量素材取除才能发动。那只攻击怪兽的攻击力直到结束阶段时变成2倍。「弦魔人 跃跃节奏」的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(26563200,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,26563200)
	e1:SetCondition(c26563200.atkcon)
	e1:SetCost(c26563200.atkcost)
	e1:SetOperation(c26563200.atkop)
	c:RegisterEffect(e1)
end
-- 效果发动条件判定：仅当处于伤害步骤且尚未进行伤害计算时，我方场上的名字带有「魔人」的超量怪兽正在向对方怪兽攻击，且该攻击怪兽仍与本次战斗关联，才允许发动。
function c26563200.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前阶段，用于判断是否处于伤害步骤。
	local ph=Duel.GetCurrentPhase()
	-- 若不是伤害步骤，或已经计算过伤害，则不满足发动条件，直接返回false。
	if ph~=PHASE_DAMAGE or Duel.IsDamageCalculated() then return false end
	-- 获取当前发动攻击的怪兽（即为那只攻击怪兽）。
	local tc=Duel.GetAttacker()
	-- 检查攻击怪兽是否为我方控制、与本次战斗关联、名字带有「魔人」的超量怪兽，并且存在对方的攻击对象（正在攻击对方怪兽）。
	return tc:IsControler(tp) and tc:IsRelateToBattle() and tc:IsSetCard(0x6d) and tc:IsType(TYPE_XYZ) and Duel.GetAttackTarget()~=nil
end
-- 代价处理：以取除这张卡自身的1个超量素材为发动代价；check阶段先检查是否有素材可取，实际执行时取除1张。
function c26563200.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果处理：将那只攻击怪兽的攻击力变为原来的2倍，直到结束阶段时适用。
function c26563200.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取攻击怪兽，用于在效果处理时对其攻击力进行翻倍。
	local tc=Duel.GetAttacker()
	if tc:IsRelateToBattle() and tc:IsFaceup() then
		-- 那只攻击怪兽的攻击力直到结束阶段时变成2倍。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(tc:GetAttack()*2)
		tc:RegisterEffect(e1)
	end
end
