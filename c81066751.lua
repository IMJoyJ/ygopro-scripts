--神罰
-- 效果：
-- ①：场上有「天空的圣域」存在，怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
function c81066751.initial_effect(c)
	-- 注册「天空的圣域」的卡名，用于卡片关联检索等系统判定
	aux.AddCodeList(c,56433456)
	-- ①：场上有「天空的圣域」存在，怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_ACTIVATE)
	e4:SetCode(EVENT_CHAINING)
	e4:SetCondition(c81066751.condition)
	e4:SetTarget(c81066751.target)
	e4:SetOperation(c81066751.activate)
	c:RegisterEffect(e4)
end
-- 定义发动条件：场上有「天空的圣域」存在，且被连锁的效果可被无效，并且该效果是怪兽效果或魔陷的发动
function c81066751.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在「天空的圣域」，且当前连锁的发动是否可以被无效
	return Duel.IsEnvironment(56433456) and Duel.IsChainNegatable(ev)
		and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE))
end
-- 定义效果发动时的目标处理：设置无效发动与破坏卡片的操作信息
function c81066751.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表明此效果包含“使发动无效”的操作，对象为触发连锁的卡片
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 若触发连锁的卡片可被破坏且与该效果有关联，则设置操作信息，表明此效果包含“破坏”的操作
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 定义效果处理：尝试无效该发动，若成功则将其破坏
function c81066751.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若成功使该连锁的发动无效，且该卡片在效果处理时仍与该效果存在关联
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将该发动被无效的卡片破坏
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
