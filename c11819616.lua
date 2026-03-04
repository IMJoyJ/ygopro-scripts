--椿姫ティタニアル
-- 效果：
-- ①：场上的卡为对象的魔法·陷阱·怪兽的效果发动时，把自己场上1只表侧表示的植物族怪兽解放才能发动。那个发动无效并破坏。
function c11819616.initial_effect(c)
	-- 效果原文内容：①：场上的卡为对象的魔法·陷阱·怪兽的效果发动时，把自己场上1只表侧表示的植物族怪兽解放才能发动。那个发动无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(11819616,0))  --"发动无效并破坏"
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c11819616.discon)
	e2:SetCost(c11819616.discost)
	e2:SetTarget(c11819616.distg)
	e2:SetOperation(c11819616.disop)
	c:RegisterEffect(e2)
end
-- 判断效果发动时的条件是否满足
function c11819616.discon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁的效果对象卡片组
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 判断对象卡片是否存在于场上且该连锁可被无效
	return tg and tg:IsExists(Card.IsOnField,1,nil) and Duel.IsChainNegatable(ev)
end
-- 定义解放怪兽的过滤条件
function c11819616.costfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_PLANT) and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 设置效果的解放费用处理函数
function c11819616.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足解放条件
	if chk==0 then return Duel.CheckReleaseGroup(tp,c11819616.costfilter,1,nil) end
	-- 选择满足条件的1只怪兽进行解放
	local sg=Duel.SelectReleaseGroup(tp,c11819616.costfilter,1,1,nil)
	-- 执行怪兽解放操作
	Duel.Release(sg,REASON_COST)
end
-- 设置效果的发动时处理函数
function c11819616.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁无效的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置连锁破坏的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 设置效果的发动处理函数
function c11819616.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使连锁发动无效并判断对象卡是否有效
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏连锁对象卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
