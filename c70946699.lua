--炎虎梁山爆
-- 效果：
-- 这张卡的发动时，自己回复自己场上的永续魔法·永续陷阱卡数量×500基本分。此外，场上表侧表示存在的这张卡被对方的效果送去墓地的场合，给与对方基本分自己墓地的永续魔法·永续陷阱卡数量×500的数值的伤害。
function c70946699.initial_effect(c)
	-- 这张卡的发动时，自己回复自己场上的永续魔法·永续陷阱卡数量×500基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c70946699.target)
	e1:SetOperation(c70946699.operation)
	c:RegisterEffect(e1)
	-- 此外，场上表侧表示存在的这张卡被对方的效果送去墓地的场合，给与对方基本分自己墓地的永续魔法·永续陷阱卡数量×500的数值的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(70946699,0))  --"LP伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c70946699.damcon)
	e2:SetTarget(c70946699.damtg)
	e2:SetOperation(c70946699.damop)
	c:RegisterEffect(e2)
end
-- 卡片发动时的效果目标处理函数，设置回复对象和预估回复数值
function c70946699.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 计算自己场上表侧表示的永续魔法·永续陷阱卡数量乘以500的数值
	local rec=Duel.GetMatchingGroupCount(c70946699.filter,tp,LOCATION_ONFIELD,0,nil)*500
	-- 设置当前连锁的对象参数为计算出的回复数值
	Duel.SetTargetParam(rec)
	-- 设置当前连锁的操作信息为：使自己回复指定数值的生命值
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,rec)
end
-- 过滤函数：筛选表侧表示的永续卡（永续魔法或永续陷阱）
function c70946699.filter(c)
	return c:IsType(TYPE_CONTINUOUS) and c:IsFaceup()
end
-- 卡片发动时的效果处理函数，执行回复生命值的操作
function c70946699.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时，重新计算自己场上表侧表示的永续魔法·永续陷阱卡数量乘以500的数值
	local rec=Duel.GetMatchingGroupCount(c70946699.filter,tp,LOCATION_ONFIELD,0,nil)*500
	-- 获取当前连锁设定的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 因效果使目标玩家回复计算出的生命值
	Duel.Recover(p,rec,REASON_EFFECT)
end
-- 伤害效果的发动条件：此卡原本在自己场上表侧表示存在，因对方的效果被送去墓地
function c70946699.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP) and c:IsReason(REASON_EFFECT)
		and	c:GetReasonPlayer()==1-tp and c:IsPreviousControler(tp)
end
-- 伤害效果的目标处理函数，设置伤害对象和预估伤害数值
function c70946699.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的对象玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 计算自己墓地中永续魔法·永续陷阱卡数量乘以500的数值
	local dam=Duel.GetMatchingGroupCount(c70946699.filter,tp,LOCATION_GRAVE,0,nil)*500
	-- 设置当前连锁的对象参数为计算出的伤害数值
	Duel.SetTargetParam(dam)
	-- 设置当前连锁的操作信息为：给与对方伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 伤害效果的处理函数，执行给与对方伤害的操作
function c70946699.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时，重新计算自己墓地中永续魔法·永续陷阱卡数量乘以500的数值
	local dam=Duel.GetMatchingGroupCount(c70946699.filter,tp,LOCATION_GRAVE,0,nil)*500
	-- 获取当前连锁设定的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 因效果给与目标玩家计算出的伤害数值
	Duel.Damage(p,dam,REASON_EFFECT)
end
