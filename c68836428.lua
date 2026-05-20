--トライエッジ・リヴァイア
-- 效果：
-- 3星怪兽×3
-- 这张卡战斗破坏的怪兽不去墓地从游戏中除外。此外，1回合1次，把这张卡1个超量素材取除，选择场上表侧表示存在的1只怪兽才能发动。直到回合结束时，选择的怪兽的攻击力下降800，效果无效化。这个效果在对方回合也能发动。
function c68836428.initial_effect(c)
	-- 添加XYZ召唤手续：需要3星怪兽3只
	aux.AddXyzProcedure(c,nil,3,3)
	c:EnableReviveLimit()
	-- 这张卡战斗破坏的怪兽不去墓地从游戏中除外。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_BATTLE_DESTROY_REDIRECT)
	e1:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e1)
	-- 1回合1次，把这张卡1个超量素材取除，选择场上表侧表示存在的1只怪兽才能发动。直到回合结束时，选择的怪兽的攻击力下降800，效果无效化。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(68836428,1))  --"效果无效"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(TIMING_DAMAGE_STEP)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	-- 设置发动条件：在伤害步骤中，只能在伤害计算前发动
	e2:SetCondition(aux.dscon)
	e2:SetCost(c68836428.cost)
	e2:SetTarget(c68836428.target)
	e2:SetOperation(c68836428.operation)
	c:RegisterEffect(e2)
end
-- 定义发动代价：取除此卡1个超量素材
function c68836428.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤条件：场上表侧表示，且为效果怪兽或攻击力大于0的怪兽
function c68836428.filter(c)
	return c:IsFaceup() and (c:IsType(TYPE_EFFECT) or c:GetAttack()>0)
end
-- 定义效果的目标：选择场上1只表侧表示的怪兽
function c68836428.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c68836428.filter(chkc) end
	-- 检查场上是否存在至少1只满足过滤条件的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c68836428.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择1只表侧表示的怪兽作为效果对象
	Duel.SelectTarget(tp,c68836428.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 定义效果的处理：使选择的怪兽攻击力下降800，且效果无效化
function c68836428.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 使与目标怪兽相关的连锁中已发动的效果无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		-- 选择的怪兽的攻击力下降800
		local e3=Effect.CreateEffect(c)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_UPDATE_ATTACK)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e3:SetValue(-800)
		tc:RegisterEffect(e3)
	end
end
