--亜種羅王
-- 效果：
-- 3星怪兽×3只以上
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：持有超量素材的这张卡在同1次的战斗阶段中可以作出最多有那个数量的攻击。
-- ②：这张卡进行战斗的伤害步骤开始时发动。这张卡的攻击力上升200。
-- ③：这张卡以外的怪兽的效果发动时，把这张卡1个超量素材取除才能发动。那个发动无效并破坏。
function c80993256.initial_effect(c)
	-- 设置XYZ召唤手续：3星怪兽3只以上（最多99只）
	aux.AddXyzProcedure(c,nil,3,3,nil,nil,99)
	c:EnableReviveLimit()
	-- ①：持有超量素材的这张卡在同1次的战斗阶段中可以作出最多有那个数量的攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetCondition(c80993256.atkcon)
	e1:SetValue(c80993256.atkval)
	c:RegisterEffect(e1)
	-- ②：这张卡进行战斗的伤害步骤开始时发动。这张卡的攻击力上升200。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(80993256,0))  --"攻击力上升"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetCondition(c80993256.condition)
	e2:SetOperation(c80993256.operation)
	c:RegisterEffect(e2)
	-- ③：这张卡以外的怪兽的效果发动时，把这张卡1个超量素材取除才能发动。那个发动无效并破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(80993256,1))  --"发动无效并破坏"
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,80993256)
	e3:SetCondition(c80993256.discon)
	e3:SetCost(c80993256.discost)
	e3:SetTarget(c80993256.distg)
	e3:SetOperation(c80993256.disop)
	c:RegisterEffect(e3)
end
-- 攻击次数效果的启用条件：自身持有超量素材
function c80993256.atkcon(e)
	return e:GetHandler():GetOverlayCount()>0
end
-- 攻击次数效果的数值：超量素材数量减1（追加攻击次数，使总攻击次数等于素材数）
function c80993256.atkval(e,c)
	return e:GetHandler():GetOverlayCount()-1
end
-- 攻击力上升效果的发动条件：这张卡进行战斗
function c80993256.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsRelateToBattle()
end
-- 攻击力上升效果的处理：使这张卡的攻击力上升200
function c80993256.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力上升200。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(200)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- 发动无效效果的发动条件：这张卡以外的怪兽的效果发动时，且自身未被战斗破坏，且该连锁可被无效
function c80993256.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	-- 检查发动的效果是否为怪兽效果、发动效果的卡是否不是自身、自身是否未被战斗破坏、该连锁是否可以被无效
	return re:IsActiveType(TYPE_MONSTER) and rc~=c and not c:IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
-- 发动无效效果的代价：取除这张卡1个超量素材
function c80993256.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 发动无效效果的靶向处理：设置无效与破坏的操作信息
function c80993256.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：使该连锁的发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：破坏该发动效果的卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 发动无效效果的具体效果处理：使发动无效并破坏
function c80993256.disop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	-- 如果成功使该连锁的发动无效，且该卡仍与效果关联
	if Duel.NegateActivation(ev) and rc:IsRelateToEffect(re) then
		-- 因效果破坏该发动效果的卡
		Duel.Destroy(rc,REASON_EFFECT)
	end
end
