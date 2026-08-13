--破壊剣一閃
-- 效果：
-- ①：自己场上有需以「破坏之剑士」为融合素材的融合怪兽存在的场合才能发动。对方场上的怪兽全部除外。
-- ②：以自己场上的「破坏之剑士」怪兽为对象的魔法·陷阱·怪兽的效果发动时，把墓地的这张卡除外才能发动。那个效果无效并破坏。
function c15155568.initial_effect(c)
	-- ①：自己场上有需以「破坏之剑士」为融合素材的融合怪兽存在的场合才能发动。对方场上的怪兽全部除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c15155568.condition)
	e1:SetTarget(c15155568.target)
	e1:SetOperation(c15155568.activate)
	c:RegisterEffect(e1)
	-- ②：以自己场上的「破坏之剑士」怪兽为对象的魔法·陷阱·怪兽的效果发动时，把墓地的这张卡除外才能发动。那个效果无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c15155568.discon)
	-- 设置②效果发动时的代价：从墓地把这张卡除外（aux.bfgcost实现）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c15155568.distg)
	e2:SetOperation(c15155568.disop)
	c:RegisterEffect(e2)
end
-- 定义筛选函数cfilter：用于检测表侧表示的融合怪兽，且其融合素材中需包含「破坏之剑士」（卡号78193831）。
function c15155568.cfilter(c)
	-- 判断条件：该卡是表侧表示、融合怪兽，并且其融合素材包含「破坏之剑士」（卡号78193831）。
	return c:IsFaceup() and c:IsType(TYPE_FUSION) and aux.IsMaterialListCode(c,78193831)
end
-- 定义①效果的发动条件函数：检查自己场上是否存在至少1只满足cfilter的融合怪兽。
function c15155568.condition(e,tp,eg,ep,ev,re,r,rp)
	-- ①效果发动条件：从自己怪兽区检索是否存在1只以上符合cfilter的融合怪兽。
	return Duel.IsExistingMatchingCard(c15155568.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 定义①效果的发动时目标处理函数：确认对方场上有可除外的怪兽，并获取全部可除外怪兽，设置操作信息为除外。
function c15155568.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：确认对方场上有至少1只可以被除外的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有当前可以被除外的怪兽，作为效果处理时的候选对象。
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,nil)
	-- 设置操作信息：预告将全部候选怪兽除外，数量为候选数量，不取对象。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- 定义①效果的处理函数：效果处理时获取对方场上所有可除外的怪兽，并将其全部除外。
function c15155568.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新获取对方场上所有可以被除外的怪兽。
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,nil)
	-- 将获取到的怪兽全部表侧表示除外。
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
-- 定义tgfilter：检测一张卡是否为表侧表示、位于怪兽区、由自己控制，且属于「破坏之剑士」怪兽。
function c15155568.tgfilter(c,tp)
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and c:IsSetCard(0xd7)
end
-- 定义②效果的发动条件：当效果发动并取对象，且对象中包含自己场上的「破坏之剑士」怪兽时，若该效果可被无效，则可以发动。
function c15155568.discon(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁中该效果发动时选择的对象卡组（取对象效果的对象）。
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 确认对象中存在至少1张自己的「破坏之剑士」怪兽，并且该连锁效果可以被无效。
	return tg and tg:IsExists(c15155568.tgfilter,1,nil,tp) and Duel.IsChainDisablable(ev)
end
-- 定义②效果的目标处理：发动时无需指定额外对象；设置操作信息为无效并破坏该发动效果。
function c15155568.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本次效果包含无效效果，对象为当前被连锁的效果。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：本次效果包含破坏效果，对象为当前被连锁的效果的发动卡（eg）。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 定义②效果的处理函数：若无效成功，则破坏该效果发动卡。
function c15155568.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否成功无效了该效果，且该效果发动卡仍与效果关联（仍存在于场上）。
	if Duel.NegateEffect(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏该效果的发动卡。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
