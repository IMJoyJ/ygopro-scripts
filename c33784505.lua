--壺盗み
-- 效果：
-- 「强欲之壶」发动时才能发动。使「强欲之壶」的效果无效，从自己卡组抽1张卡。
function c33784505.initial_effect(c)
	-- 「强欲之壶」发动时才能发动。使「强欲之壶」的效果无效，从自己卡组抽1张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c33784505.condition)
	e1:SetTarget(c33784505.target)
	e1:SetOperation(c33784505.activate)
	c:RegisterEffect(e1)
end
-- 定义本卡的发动条件：仅在「强欲之壶」作为魔法卡发动、且该连锁效果可被无效时才能发动。
function c33784505.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定具体条件：正在连锁的效果是魔法/陷阱卡的发动，且其效果持有者为卡号55144522（强欲之壶），同时该连锁可以被无效。
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsCode(55144522) and Duel.IsChainNegatable(ev)
end
-- 发动时处理：确认自己可以抽1张卡，然后登记操作信息：将无效对象设为连锁中的「强欲之壶」，并登记自己抽1张卡。
function c33784505.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查：如果自己不能抽1张卡，则本效果不能发动。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置操作信息：本次连锁将使「强欲之壶」的效果无效，对象为当前连锁中的那张卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	-- 设置操作信息：本次连锁的效果处理中将让自己抽1张卡（不取对象）。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理：先尝试使「强欲之壶」的效果无效，若成功则自己从卡组抽1张卡。
function c33784505.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 调用Duel.NegateEffect使当前连锁的效果无效，并判断是否无效成功。
	if Duel.NegateEffect(ev) then
		-- 以效果原因让自己抽1张卡。
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
