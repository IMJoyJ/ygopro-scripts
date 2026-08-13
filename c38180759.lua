--虚構王アンフォームド・ボイド
-- 效果：
-- 4星怪兽×3
-- 对方的主要阶段时1次，把这张卡1个超量素材取除才能发动。这张卡的攻击力·守备力上升对方场上的超量怪兽的攻击力合计数值。
function c38180759.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：等级4的怪兽3只叠放，即“4星怪兽×3”。
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
-- 效果发动条件的判定函数：检查是否满足“对方的主要阶段”（当前不是自己的回合且处于主要阶段1或主要阶段2）。
function c38180759.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前是否为对方的主要阶段：回合玩家不是己方，且当前阶段为主要阶段1或主要阶段2。
	return Duel.GetTurnPlayer()~=tp and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
-- 代价函数：发动前检查并取除这张卡的1个超量素材作为代价；chk==0时只检查能否取除，实际取除发生在chk非0时。
function c38180759.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤条件：选择对方场上表侧表示的超量怪兽。
function c38180759.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- 目标（发动）函数：确认对方场上存在符合条件的表侧超量怪兽，满足条件才能发动。
function c38180759.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方怪兽区域是否存在至少1只表侧表示的超量怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c38180759.filter,tp,0,LOCATION_MZONE,1,nil) end
end
-- 效果处理函数：若此卡仍表侧且在场上，则获取对方场上全部表侧超量怪兽的攻击力合计值，赋予此卡攻击力与守备力上升该数值的效果。
function c38180759.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 获取对方场上的所有表侧表示的超量怪兽，用于计算攻击力合计。
		local g=Duel.GetMatchingGroup(c38180759.filter,tp,0,LOCATION_MZONE,nil)
		local atk=g:GetSum(Card.GetAttack)
		if atk>0 then
			-- 这张卡的攻击力上升对方场上的超量怪兽的攻击力合计数值。
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
