--破壊剣一閃
-- 效果：
-- ①：自己场上有需以「破坏之剑士」为融合素材的融合怪兽存在的场合才能发动。对方场上的怪兽全部除外。
-- ②：以自己场上的「破坏之剑士」怪兽为对象的魔法·陷阱·怪兽的效果发动时，把墓地的这张卡除外才能发动。那个效果无效并破坏。
function c15155568.initial_effect(c)
	-- 效果原文内容：①：自己场上有需以「破坏之剑士」为融合素材的融合怪兽存在的场合才能发动。对方场上的怪兽全部除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c15155568.condition)
	e1:SetTarget(c15155568.target)
	e1:SetOperation(c15155568.activate)
	c:RegisterEffect(e1)
	-- 效果原文内容：②：以自己场上的「破坏之剑士」怪兽为对象的魔法·陷阱·怪兽的效果发动时，把墓地的这张卡除外才能发动。那个效果无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c15155568.discon)
	-- 效果作用：将此卡除外作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c15155568.distg)
	e2:SetOperation(c15155568.disop)
	c:RegisterEffect(e2)
end
-- 效果作用：过滤满足条件的融合怪兽（需以「破坏之剑士」为融合素材）
function c15155568.cfilter(c)
	-- 效果原文内容：需以「破坏之剑士」为融合素材的融合怪兽
	return c:IsFaceup() and c:IsType(TYPE_FUSION) and aux.IsMaterialListCode(c,78193831)
end
-- 效果作用：检查自己场上是否存在满足条件的融合怪兽
function c15155568.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 效果原文内容：自己场上有需以「破坏之剑士」为融合素材的融合怪兽存在的场合
	return Duel.IsExistingMatchingCard(c15155568.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果作用：设置发动时的处理目标为对方场上的所有怪兽
function c15155568.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果原文内容：对方场上的怪兽全部除外
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,nil) end
	-- 效果作用：获取对方场上的所有可除外怪兽
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,nil)
	-- 效果作用：设置连锁操作信息为除外对方场上的怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- 效果作用：执行将对方场上的所有怪兽除外
function c15155568.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取对方场上的所有可除外怪兽
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,nil)
	-- 效果作用：以效果原因将对方场上的所有怪兽除外
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
-- 效果作用：过滤自己场上的「破坏之剑士」怪兽
function c15155568.tgfilter(c,tp)
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and c:IsSetCard(0xd7)
end
-- 效果作用：判断是否为可无效的连锁且目标包含自己场上的「破坏之剑士」怪兽
function c15155568.discon(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 效果作用：获取当前连锁的目标卡片组
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 效果原文内容：以自己场上的「破坏之剑士」怪兽为对象的魔法·陷阱·怪兽的效果发动时
	return tg and tg:IsExists(c15155568.tgfilter,1,nil,tp) and Duel.IsChainDisablable(ev)
end
-- 效果作用：设置连锁操作信息为使效果无效并破坏
function c15155568.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 效果作用：设置连锁操作信息为使效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 效果作用：设置连锁操作信息为破坏目标怪兽
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果作用：使当前连锁效果无效并破坏目标怪兽
function c15155568.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：判断是否成功使效果无效且目标怪兽存在并关联到该效果
	if Duel.NegateEffect(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 效果作用：以效果原因破坏目标怪兽
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
