--六尺瓊勾玉
-- 效果：
-- ①：自己场上有「六武众」怪兽存在，要让卡破坏的怪兽的效果·魔法·陷阱卡由对方发动时才能发动。那个发动无效并破坏。
function c41458579.initial_effect(c)
	-- 效果原文内容：①：自己场上有「六武众」怪兽存在，要让卡破坏的怪兽的效果·魔法·陷阱卡由对方发动时才能发动。那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCondition(c41458579.condition)
	e1:SetTarget(c41458579.target)
	e1:SetOperation(c41458579.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于检查场上是否存在表侧表示的「六武众」怪兽
function c41458579.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x103d)
end
-- 条件函数，判断是否满足发动此卡的条件
function c41458579.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只「六武众」怪兽
	if not Duel.IsExistingMatchingCard(c41458579.filter,tp,LOCATION_MZONE,0,1,nil) then return false end
	-- 检查发动者是否为自己或该连锁是否可无效
	if tp==ep or not Duel.IsChainNegatable(ev) then return false end
	if not re:IsActiveType(TYPE_MONSTER) and not re:IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
	-- 获取该连锁的破坏效果信息，判断是否包含破坏效果
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	return ex and tg~=nil and tc>0
end
-- 目标函数，设置连锁处理时需要无效和破坏的卡
function c41458579.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理时需要无效的卡
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置连锁处理时需要破坏的卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理函数，执行无效和破坏操作
function c41458579.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否成功使连锁发动无效且目标卡仍存在
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将目标卡破坏
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
