--H－C クサナギ
-- 效果：
-- 战士族4星怪兽×3
-- 1回合1次，把这张卡1个超量素材取除才能发动。陷阱卡的发动无效并破坏。那之后，这张卡的攻击力上升500。
function c74593218.initial_effect(c)
	-- 设置XYZ召唤手续：需要3只4星的战士族怪兽
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_WARRIOR),4,3)
	c:EnableReviveLimit()
	-- 1回合1次，把这张卡1个超量素材取除才能发动。陷阱卡的发动无效并破坏。那之后，这张卡的攻击力上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(74593218,0))  --"陷阱无效并破坏"
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_ATKCHANGE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c74593218.negcon)
	e1:SetCost(c74593218.negcost)
	e1:SetTarget(c74593218.negtg)
	e1:SetOperation(c74593218.negop)
	c:RegisterEffect(e1)
end
-- 定义效果发动条件函数：自身未确定被战斗破坏，且连锁中的效果为可无效的陷阱卡发动
function c74593218.negcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		-- 判断被连锁的效果是否为陷阱卡的发动，且该发动是否可以被无效
		and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_TRAP) and Duel.IsChainNegatable(ev)
end
-- 定义效果发动代价函数：取除这张卡的1个超量素材
function c74593218.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 定义效果目标函数：设置“无效”与“破坏”的操作信息
function c74593218.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向系统宣告此效果包含“使发动无效”的操作
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 若目标卡片可被破坏，则向系统宣告此效果包含“破坏”的操作
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 定义效果处理函数：使陷阱卡的发动无效并破坏，之后使自身攻击力上升500
function c74593218.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 使该陷阱卡的发动无效，若成功则将其破坏
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) and Duel.Destroy(eg,REASON_EFFECT)>0 then
		-- 中断当前效果处理，使后续的攻击力上升处理与前面的破坏处理不视为同时进行
		Duel.BreakEffect()
		if c:IsRelateToEffect(e) and c:IsFaceup() then
			-- 那之后，这张卡的攻击力上升500。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(500)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			c:RegisterEffect(e1)
		end
	end
end
