--Gゴーレム・インヴァリッド・ドルメン
-- 效果：
-- 地属性怪兽2只以上
-- ①：只要这张卡在怪兽区域存在，自己场上的互相连接状态的怪兽不受对方场上发动的怪兽的效果影响。
-- ②：可以攻击的对方怪兽必须向这张卡作出攻击。
-- ③：1回合1次，从手卡丢弃1只电子界族怪兽才能发动。自己从卡组抽1张。
-- ④：互相连接状态的这张卡被破坏的场合才能发动。对方场上的全部表侧表示的卡的效果无效化。
function c24151924.initial_effect(c)
	-- 添加连接召唤手续，要求使用至少2只地属性怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkAttribute,ATTRIBUTE_EARTH),2)
	c:EnableReviveLimit()
	-- 只要这张卡在怪兽区域存在，自己场上的互相连接状态的怪兽不受对方场上发动的怪兽的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c24151924.indtg)
	e1:SetValue(c24151924.efilter)
	c:RegisterEffect(e1)
	-- 可以攻击的对方怪兽必须向这张卡作出攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_MUST_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_MUST_ATTACK_MONSTER)
	e3:SetValue(c24151924.atklimit)
	c:RegisterEffect(e3)
	-- 1回合1次，从手卡丢弃1只电子界族怪兽才能发动。自己从卡组抽1张。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(24151924,0))
	e4:SetCategory(CATEGORY_DRAW)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCost(c24151924.drcost)
	e4:SetTarget(c24151924.drtg)
	e4:SetOperation(c24151924.drop)
	c:RegisterEffect(e4)
	-- 互相连接状态的这张卡被破坏的场合才能发动。对方场上的全部表侧表示的卡的效果无效化。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(24151924,1))
	e5:SetCategory(CATEGORY_DISABLE)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e5:SetCondition(c24151924.discon)
	e5:SetTarget(c24151924.distg)
	e5:SetOperation(c24151924.disop)
	c:RegisterEffect(e5)
	-- 当此卡离开场上的时候，记录其是否处于连接状态以供后续效果判断。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_LEAVE_FIELD_P)
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e6:SetLabelObject(e5)
	e6:SetOperation(c24151924.chk)
	c:RegisterEffect(e6)
end
-- 判断目标怪兽是否处于互相连接状态
function c24151924.indtg(e,c)
	return c:GetMutualLinkedGroupCount()>0
end
-- 过滤掉非怪兽类型、或属于同一玩家、或不是从怪兽区域发动的效果
function c24151924.efilter(e,te,ev)
	return te:IsActiveType(TYPE_MONSTER) and te:GetOwnerPlayer()~=e:GetHandlerPlayer()
		-- 确保效果是从怪兽区域发动的
		and Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)==LOCATION_MZONE
end
-- 设置必须攻击的怪兽为自身
function c24151924.atklimit(e,c)
	return c==e:GetHandler()
end
-- 筛选手卡中可丢弃的电子界族怪兽
function c24151924.costfilter(c)
	return c:IsRace(RACE_CYBERSE) and c:IsDiscardable()
end
-- 检查是否满足丢弃1只电子界族怪兽的条件并执行丢弃操作
function c24151924.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足丢弃1只电子界族怪兽的条件
	if chk==0 then return Duel.IsExistingMatchingCard(c24151924.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 执行丢弃1只电子界族怪兽的操作
	Duel.DiscardHand(tp,c24151924.costfilter,1,1,REASON_DISCARD+REASON_COST)
end
-- 设置抽卡效果的目标玩家和抽卡数量
function c24151924.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置抽卡效果的目标玩家
	Duel.SetTargetPlayer(tp)
	-- 设置抽卡效果的抽卡数量
	Duel.SetTargetParam(1)
	-- 设置抽卡效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 执行抽卡操作
function c24151924.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡操作
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 记录此卡连接状态以供后续效果判断
function c24151924.chk(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():SetLabel(e:GetHandler():GetMutualLinkedGroupCount())
end
-- 判断此卡是否处于连接状态
function c24151924.discon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabel()>0
end
-- 检查对方场上是否存在表侧表示的卡
function c24151924.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在表侧表示的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,nil) end
end
-- 使对方场上的所有表侧表示的卡效果无效
function c24151924.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有表侧表示的卡
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_ONFIELD,nil)
	local tc=g:GetFirst()
	local c=e:GetHandler()
	while tc do
		-- 使目标卡相关的连锁无效
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 使目标卡效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 使目标卡的效果处理无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(RESET_TURN_SET)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
end
