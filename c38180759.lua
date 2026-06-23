--虚構王アンフォームド・ボイド
-- 效果：
-- 4星怪兽×3
-- 对方的主要阶段时1次，把这张卡1个超量素材取除才能发动。这张卡的攻击力·守备力上升对方场上的超量怪兽的攻击力合计数值。
function c38180759.initial_effect(c)
	-- 为卡片添加等级为4、需要3只怪兽进行XYZ召唤的手续
	aux.AddXyzProcedure(c,nil,4,3)
	c:EnableReviveLimit()
	-- 对方的主要阶段时1次，把这张卡1个超量素材取除才能发动。这张卡的攻击力·守备力上升对方场上的超量怪兽的攻击力合计数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(38180759,0))  --"攻守上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCountLimit(1)
	e1:SetCondition(c38180759.atkcon)
	e1:SetCost(c38180759.atkcost)
	e1:SetTarget(c38180759.atktg)
	e1:SetOperation(c38180759.atkop)
	c:RegisterEffect(e1)
end
-- 判断是否为对方的主要阶段
function c38180759.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合玩家不是自己且当前阶段为主要阶段1或主要阶段2
	return Duel.GetTurnPlayer()~=tp and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
-- 支付效果的代价，移除自身1个超量素材
function c38180759.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤函数，用于筛选场上正面表示的超量怪兽
function c38180759.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- 设置效果的发动条件，检查对方场上是否存在超量怪兽
function c38180759.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在满足条件的超量怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c38180759.filter,tp,0,LOCATION_MZONE,1,nil) end
end
-- 效果发动时执行的操作，计算对方场上超量怪兽的攻击力总和并提升自身攻守
function c38180759.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 获取对方场上所有正面表示的超量怪兽
		local g=Duel.GetMatchingGroup(c38180759.filter,tp,0,LOCATION_MZONE,nil)
		local atk=g:GetSum(Card.GetAttack)
		if atk>0 then
			-- 提升自身攻击力
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(atk)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			c:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_UPDATE_DEFENSE)
			c:RegisterEffect(e2)
		end
	end
end
