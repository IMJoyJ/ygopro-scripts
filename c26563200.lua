--弦魔人ムズムズリズム
-- 效果：
-- 3星怪兽×2
-- 自己场上的名字带有「魔人」的超量怪兽向对方怪兽攻击的伤害步骤时，把这张卡1个超量素材取除才能发动。那只攻击怪兽的攻击力直到结束阶段时变成2倍。「弦魔人 跃跃节奏」的效果1回合只能使用1次。
function c26563200.initial_effect(c)
	-- 添加XYZ召唤手续，使用等级为3的怪兽2只作为素材进行超量召唤
	aux.AddXyzProcedure(c,nil,3,2)
	c:EnableReviveLimit()
	-- 自己场上的名字带有「魔人」的超量怪兽向对方怪兽攻击的伤害步骤时，把这张卡1个超量素材取除才能发动。
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
-- 判断是否处于伤害步骤且尚未计算战斗伤害，且攻击怪兽为我方控制、参与战斗、属于「魔人」系列、为超量怪兽且存在攻击目标
function c26563200.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段
	local ph=Duel.GetCurrentPhase()
	-- 若当前阶段不是伤害步骤或战斗伤害已计算，则效果不发动
	if ph~=PHASE_DAMAGE or Duel.IsDamageCalculated() then return false end
	-- 获取此次战斗的攻击怪兽
	local tc=Duel.GetAttacker()
	-- 返回攻击怪兽为我方控制、参与战斗、属于「魔人」系列、为超量怪兽且存在攻击目标
	return tc:IsControler(tp) and tc:IsRelateToBattle() and tc:IsSetCard(0x6d) and tc:IsType(TYPE_XYZ) and Duel.GetAttackTarget()~=nil
end
-- 检查并扣除1个超量素材作为发动代价
function c26563200.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 将攻击怪兽的攻击力在结束阶段时变为2倍
function c26563200.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取此次战斗的攻击怪兽
	local tc=Duel.GetAttacker()
	if tc:IsRelateToBattle() and tc:IsFaceup() then
		-- 将攻击怪兽的攻击力临时变为原本的2倍
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(tc:GetAttack()*2)
		tc:RegisterEffect(e1)
	end
end
