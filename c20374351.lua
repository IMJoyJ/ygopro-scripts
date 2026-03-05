--ラヴァル・ステライド
-- 效果：
-- 调整＋调整以外的炎属性怪兽1只以上
-- 这张卡同调召唤成功时，自己把1张手卡送去墓地。这张卡成为卡的效果的对象时，可以把自己墓地存在的1只名字带有「熔岩」的怪兽从游戏中除外，那个发动无效并破坏。
function c20374351.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和1只以上调整以外的炎属性怪兽
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsAttribute,ATTRIBUTE_FIRE),1)
	c:EnableReviveLimit()
	-- 这张卡同调召唤成功时，自己把1张手卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20374351,0))  --"把1张手卡送去墓地"
	e1:SetCategory(CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c20374351.condition)
	e1:SetTarget(c20374351.target)
	e1:SetOperation(c20374351.operation)
	c:RegisterEffect(e1)
	-- 这张卡成为卡的效果的对象时，可以把自己墓地存在的1只名字带有「熔岩」的怪兽从游戏中除外，那个发动无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(20374351,1))  --"效果发动无效并破坏"
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c20374351.discon)
	e2:SetCost(c20374351.discost)
	e2:SetTarget(c20374351.distg)
	e2:SetOperation(c20374351.disop)
	c:RegisterEffect(e2)
end
-- 判断此卡是否为同调召唤成功
function c20374351.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 设置效果处理时将1张手卡送去墓地的操作信息
function c20374351.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为将目标卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
end
-- 选择并把1张手卡送去墓地
function c20374351.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的手卡
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的卡送去墓地
	Duel.SendtoGrave(g,REASON_EFFECT)
end
-- 判断是否可以发动此效果，包括是否为目标卡、是否可无效连锁
function c20374351.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取连锁的目标卡组信息
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 判断目标卡组是否包含此卡且连锁可被无效
	return tg and tg:IsContains(c) and Duel.IsChainNegatable(ev)
end
-- 过滤墓地中的熔岩卡作为除外的代价
function c20374351.cfilter(c)
	return c:IsSetCard(0x39) and c:IsAbleToRemoveAsCost()
end
-- 支付除外熔岩卡的费用
function c20374351.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的熔岩卡可除外
	if chk==0 then return Duel.IsExistingMatchingCard(c20374351.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的墓地卡
	local g=Duel.SelectMatchingCard(tp,c20374351.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的卡从游戏中除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 设置效果处理时的操作信息，包括使发动无效和破坏
function c20374351.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为使发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息为破坏目标卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 执行效果处理，使发动无效并破坏目标卡
function c20374351.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否成功使发动无效且目标卡存在
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏目标卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
