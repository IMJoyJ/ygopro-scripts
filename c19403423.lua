--時を裂く魔瞳
-- 效果：
-- ①：这次决斗中，以下效果各适用。
-- ●自己不能把手卡的怪兽的效果发动。
-- ●自己抽卡阶段的通常抽卡变成2张。
-- ●自己1回合可以进行通常召唤最多2次。
-- ②：把墓地的这张卡除外，从手卡丢弃1张「撕裂时间的魔瞳」才能发动。这个回合，在自己怪兽的召唤成功时对方不能把怪兽的效果发动。
function c19403423.initial_effect(c)
	-- ①：这次决斗中，以下效果各适用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19403423,0))  --"适用效果"
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c19403423.target)
	e1:SetOperation(c19403423.activate)
	e1:SetLabel(19403423)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，从手卡丢弃1张「撕裂时间的魔瞳」才能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(19403423,1))  --"把墓地的这张卡除外"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(c19403423.cost)
	e2:SetTarget(c19403423.target)
	e2:SetOperation(c19403423.operation)
	e2:SetLabel(19403424)
	c:RegisterEffect(e2)
end
-- 检查是否已适用过此效果
function c19403423.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetLabel()
	-- 若未适用过则返回true
	if chk==0 then return Duel.GetFlagEffect(tp,ct)==0 end
end
-- 发动①效果：使自己不能把手卡的怪兽的效果发动、抽卡阶段通常抽卡变成2张、1回合可以进行通常召唤最多2次
function c19403423.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 使自己不能把手卡的怪兽的效果发动
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19403423,2))  --"「撕裂时间的魔瞳」的效果适用中"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(c19403423.aclimit)
	-- 注册效果：使自己不能把手卡的怪兽的效果发动
	Duel.RegisterEffect(e1,tp)
	-- 使自己抽卡阶段的通常抽卡变成2张
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_DRAW_COUNT)
	e2:SetTargetRange(1,0)
	e2:SetValue(2)
	-- 注册效果：使自己抽卡阶段的通常抽卡变成2张
	Duel.RegisterEffect(e2,tp)
	-- 使自己1回合可以进行通常召唤最多2次
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SET_SUMMON_COUNT_LIMIT)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetValue(2)
	-- 注册效果：使自己1回合可以进行通常召唤最多2次
	Duel.RegisterEffect(e3,tp)
	-- 注册标识效果：标记①效果已适用
	Duel.RegisterFlagEffect(tp,19403423,0,0,1)
end
-- 限制手卡怪兽效果发动的判断函数
function c19403423.aclimit(e,re,tp)
	return re:GetActivateLocation()==LOCATION_HAND and re:IsActiveType(TYPE_MONSTER)
end
-- 筛选手卡中「撕裂时间的魔瞳」的过滤函数
function c19403423.filter(c)
	return c:IsCode(19403423) and c:IsDiscardable()
end
-- 支付发动②效果的代价：将此卡从墓地除外并丢弃1张手卡中的「撕裂时间的魔瞳」
function c19403423.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost()
		-- 检查手卡中是否存在1张「撕裂时间的魔瞳」
		and Duel.IsExistingMatchingCard(c19403423.filter,tp,LOCATION_HAND,0,1,nil) end
	-- 将此卡从场上除外作为代价
	Duel.Remove(c,POS_FACEUP,REASON_COST)
	-- 丢弃1张手卡中的「撕裂时间的魔瞳」作为代价
	Duel.DiscardHand(tp,c19403423.filter,1,1,REASON_COST+REASON_DISCARD,nil)
end
-- 发动②效果：在自己怪兽召唤成功时对方不能把怪兽的效果发动
function c19403423.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 注册召唤成功时触发的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c19403423.nsumcon)
	e1:SetOperation(c19403423.nsumsuc)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册效果：在自己怪兽召唤成功时对方不能把怪兽的效果发动
	Duel.RegisterEffect(e1,tp)
	-- 注册标识效果：标记②效果已适用
	Duel.RegisterFlagEffect(tp,19403424,RESET_PHASE+PHASE_END,0,1)
end
-- 判断召唤成功是否为己方怪兽
function c19403423.nsumcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=eg:GetFirst()
	return ec and ec:IsControler(tp)
end
-- 设置连锁限制：对方不能发动怪兽效果
function c19403423.nsumsuc(e,tp,eg,ep,ev,re,r,rp)
	-- 设置连锁限制：对方不能发动怪兽效果
	Duel.SetChainLimitTillChainEnd(c19403423.efun)
end
-- 连锁限制函数：若为己方或非怪兽效果则不生效
function c19403423.efun(e,ep,tp)
	return ep==tp or not e:IsActiveType(TYPE_MONSTER)
end
