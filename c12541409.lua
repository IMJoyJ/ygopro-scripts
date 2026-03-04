--インフェルニティ・サプレッション
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。自己手卡是0张的场合，这张卡在盖放的回合也能发动。
-- ①：自己场上有「永火」怪兽存在，对方把怪兽的效果发动时才能发动。那个效果无效。那之后，可以给与对方那只怪兽的等级×100伤害。
function c12541409.initial_effect(c)
	-- 效果原文内容：①：自己场上有「永火」怪兽存在，对方把怪兽的效果发动时才能发动。那个效果无效。那之后，可以给与对方那只怪兽的等级×100伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12541409,0))
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,12541409+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c12541409.condition)
	e1:SetTarget(c12541409.target)
	e1:SetOperation(c12541409.activate)
	c:RegisterEffect(e1)
	-- 效果原文内容：这个卡名的卡在1回合只能发动1张。自己手卡是0张的场合，这张卡在盖放的回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(12541409,2))  --"适用「永火压制」的效果来发动"
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetCondition(c12541409.actcon)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于检测场上是否存在「永火」怪兽（包括里侧表示的怪兽）
function c12541409.confilter(c)
	return c:IsFaceup() and c:IsSetCard(0xb)
end
-- 条件函数，用于判断是否满足发动「永火压制」的条件
function c12541409.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只「永火」怪兽
	if not Duel.IsExistingMatchingCard(c12541409.confilter,tp,LOCATION_MZONE,0,1,nil) then return end
	-- 判断对方怪兽效果发动，且该连锁可以被无效
	return ep==1-tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainDisablable(ev)
end
-- 目标函数，用于设置发动效果时的操作信息
function c12541409.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，将对方怪兽效果无效作为处理目标
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 发动函数，用于执行「永火压制」的主要效果
function c12541409.activate(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	-- 使对方怪兽效果无效，并询问是否给予对方怪兽等级×100的伤害
	if Duel.NegateEffect(ev) and rc:IsLevelAbove(1) and Duel.SelectYesNo(tp,aux.Stringid(12541409,1)) then  --"是否给与伤害？"
		-- 中断当前效果处理，防止连锁错时
		Duel.BreakEffect()
		local lv=rc:GetLevel()
		if not rc:IsRelateToEffect(re) then lv=rc:GetOriginalLevel() end
		-- 对对方造成对方怪兽等级×100的伤害
		Duel.Damage(1-tp,lv*100,REASON_EFFECT)
	end
end
-- 盖放时发动条件函数，用于判断是否可以在盖放回合发动
function c12541409.actcon(e)
	-- 判断自己手牌数量是否为0
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_HAND,0)==0
end
