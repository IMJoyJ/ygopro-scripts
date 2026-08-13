--ジャスティス・ブリンガー
-- 效果：
-- 对方场上存在的特殊召唤的怪兽的效果发动时才能发动。那次发动无效。这个效果1回合只能使用1次。
function c26842483.initial_effect(c)
	-- 对方场上存在的特殊召唤的怪兽的效果发动时才能发动。那次发动无效。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(26842483,0))  --"效果无效"
	e1:SetCategory(CATEGORY_NEGATE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c26842483.condition)
	e1:SetTarget(c26842483.target)
	e1:SetOperation(c26842483.operation)
	c:RegisterEffect(e1)
end
-- 发动条件判定：仅当对方在场上发动特殊召唤怪兽的效果，且该效果发动可以被无效时，本效果才能发动。
function c26842483.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁（即将要被无效的那次效果发动）发生的位置，用于后续判断是否在场上发动。
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	-- 确认发动该效果的玩家是对方（ep~=tp），且效果从怪兽区发动，并且是怪兽效果，且该连锁可以被无效。
	return ep~=tp and loc==LOCATION_MZONE and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
		and re:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 效果发动时的合法性判定：满足条件即可发动，并在发动时将“使那次发动无效”的信息登记到连锁处理中。
function c26842483.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记操作信息：将本次效果处理分类设为CATEGORY_NEGATE（无效发动），对象为当前发动的卡（eg），数量为1。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 效果处理阶段的实际处理：执行对那次连锁发动的无效操作。
function c26842483.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 使连锁编号为ev的那次效果发动无效，从而将其发动本身无效化。
	Duel.NegateActivation(ev)
end
