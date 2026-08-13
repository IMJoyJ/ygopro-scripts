--トラップ・リアクター・RR
-- 效果：
-- 对方把陷阱卡发动时才能发动。把那张陷阱卡破坏，给与对方基本分800分伤害。这个效果1回合只能使用1次。
function c52286175.initial_effect(c)
	-- 对方把陷阱卡发动时才能发动。把那张陷阱卡破坏，给与对方基本分800分伤害。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(52286175,0))  --"破坏并伤害"
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c52286175.condition)
	e1:SetTarget(c52286175.target)
	e1:SetOperation(c52286175.operation)
	c:RegisterEffect(e1)
end
-- 效果发动条件：本效果仅在对方发动陷阱卡时才能发动，即连锁来源玩家不是本卡控制者，且被连锁的效果是陷阱卡的发动。
function c52286175.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_TRAP)
end
-- 发动时的目标判定与操作信息登记：检查连锁的那张陷阱卡是否可以被破坏，并分别登记破坏与伤害的操作信息。
function c52286175.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return re:GetHandler():IsDestructable() end
	-- 登记破坏的操作信息：将当前发动的陷阱卡（eg）作为可能被破坏的对象，数量为1张。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	-- 登记伤害的操作信息：效果处理时向对方玩家（1-tp）造成800点伤害，因为伤害对象是玩家而非卡片，所以目标卡为nil。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,800)
end
-- 效果处理阶段：确认连锁的那张陷阱卡仍与本效果关联后，将其破坏；若破坏成功，则再给予对方800点伤害。
function c52286175.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 判定并执行破坏：确认要破坏的陷阱卡没有因其他处理而离场（仍与效果关联），然后将其破坏。
	if re:GetHandler():IsRelateToEffect(re) and Duel.Destroy(eg,REASON_EFFECT)~=0 then
		-- 给予对方玩家（1-tp）800点效果伤害。
		Duel.Damage(1-tp,800,REASON_EFFECT)
	end
end
