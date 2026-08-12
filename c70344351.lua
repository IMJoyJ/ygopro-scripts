--フォースフィールド
-- 效果：
-- 以场上的1只怪兽为对象的魔法的发动无效并破坏。
function c70344351.initial_effect(c)
	-- 以场上的1只怪兽为对象的魔法的发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(70344351,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c70344351.condition)
	e1:SetTarget(c70344351.target)
	e1:SetOperation(c70344351.activate)
	c:RegisterEffect(e1)
end
-- 检查触发连锁的效果是否为以场上仅1只怪兽为对象的魔法卡的发动，且该发动可以被无效
function c70344351.condition(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁的对象卡片组
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return tg and tg:GetCount()==1 and tg:GetFirst():IsLocation(LOCATION_MZONE)
		-- 并且该效果是魔法卡的发动，且该连锁的发动可以被无效
		and re:IsActiveType(TYPE_SPELL) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
-- 设置使发动无效与破坏的操作信息
function c70344351.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置将该发动无效的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 若该卡可被破坏且仍存在，设置将其破坏的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 执行使该魔法卡的发动无效并破坏的效果处理
function c70344351.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若成功使该发动无效，且该卡仍与效果关联
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏该无效了发动的卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
