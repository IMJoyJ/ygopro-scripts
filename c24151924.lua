--Gゴーレム・インヴァリッド・ドルメン
-- 效果：
-- 地属性怪兽2只以上
-- ①：只要这张卡在怪兽区域存在，自己场上的互相连接状态的怪兽不受对方场上发动的怪兽的效果影响。
-- ②：可以攻击的对方怪兽必须向这张卡作出攻击。
-- ③：1回合1次，从手卡丢弃1只电子界族怪兽才能发动。自己从卡组抽1张。
-- ④：互相连接状态的这张卡被破坏的场合才能发动。对方场上的全部表侧表示的卡的效果无效化。
function c24151924.initial_effect(c)
	-- 为这张卡添加连接召唤手续：以2只以上地属性怪兽作为连接素材（最少2只）。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkAttribute,ATTRIBUTE_EARTH),2)
	c:EnableReviveLimit()
	-- ①：只要这张卡在怪兽区域存在，自己场上的互相连接状态的怪兽不受对方场上发动的怪兽的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c24151924.indtg)
	e1:SetValue(c24151924.efilter)
	c:RegisterEffect(e1)
	-- ②：可以攻击的对方怪兽必须向这张卡作出攻击。
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
	-- ③：1回合1次，从手卡丢弃1只电子界族怪兽才能发动。自己从卡组抽1张。
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
	-- ④：互相连接状态的这张卡被破坏的场合才能发动。对方场上的全部表侧表示的卡的效果无效化。
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
	-- ④：互相连接状态的这张卡被破坏的场合才能发动。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_LEAVE_FIELD_P)
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e6:SetLabelObject(e5)
	e6:SetOperation(c24151924.chk)
	c:RegisterEffect(e6)
end
-- 判断卡片是否处于互相连接状态（其互相连接的怪兽数量大于0），用于指定自己场上互相连接状态的怪兽。
function c24151924.indtg(e,c)
	return c:GetMutualLinkedGroupCount()>0
end
-- 作为效果e1的Value判断：免疫对方玩家在怪兽区域发动的怪兽效果。
function c24151924.efilter(e,te,ev)
	return te:IsActiveType(TYPE_MONSTER) and te:GetOwnerPlayer()~=e:GetHandlerPlayer()
		-- 追加条件：该效果的发动位置必须是怪兽区域，即“对方场上发动”的怪兽效果。
		and Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)==LOCATION_MZONE
end
-- 作为效果e3的Value：指定强制攻击对象为这张卡自身，即对方怪兽必须向这张卡攻击。
function c24151924.atklimit(e,c)
	return c==e:GetHandler()
end
-- 丢弃代价的筛选条件：手卡中的电子界族怪兽，且可以被丢弃。
function c24151924.costfilter(c)
	return c:IsRace(RACE_CYBERSE) and c:IsDiscardable()
end
-- ③的发动代价：检查并从手卡丢弃1只电子界族怪兽作为代价。
function c24151924.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动确认时，检查手卡是否存在至少1只满足costfilter条件的电子界族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c24151924.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 执行代价：从手卡选择并丢弃1只电子界族怪兽（丢弃原因包含丢弃和代价）。
	Duel.DiscardHand(tp,c24151924.costfilter,1,1,REASON_DISCARD+REASON_COST)
end
-- 抽卡效果的发动目标：确认自己可以抽1张卡，并设定目标玩家为自己、抽卡数为1，设置操作信息。
function c24151924.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动确认时，判断自己是否可以进行1张卡的抽卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将当前连锁的对象玩家设为自己，以便效果处理时由自己抽卡。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设为1，表示要抽的卡数量。
	Duel.SetTargetParam(1)
	-- 设置操作信息：该效果为抽卡效果，预计让玩家tp抽1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 抽卡效果处理：从当前连锁信息中取出目标玩家和抽卡数量，令该玩家抽相应数量的卡。
function c24151924.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁信息中的目标玩家（p）和抽卡参数（d），供抽卡处理使用。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 令玩家p以效果原因抽d张卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 在卡片离场前，将这张卡当前处于互相连接状态的连接怪兽数量记录到e5效果的Label中，用于④效果的发动条件判定。
function c24151924.chk(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():SetLabel(e:GetHandler():GetMutualLinkedGroupCount())
end
-- ④的发动条件：e5的Label值大于0，即这张卡在被破坏前处于互相连接状态。
function c24151924.discon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabel()>0
end
-- ④的发动目标确认：对方场上有表侧表示的卡存在，以便作为无效化对象。
function c24151924.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动确认时，检查对方场上是否存在至少1张表侧表示的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,nil) end
end
-- ④的效果处理：获取对方场上的全部表侧表示卡，逐一将相关连锁无效，并对其赋予效果无效化和效果发动无效化的效果。
function c24151924.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的全部表侧表示的卡，作为无效化对象。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_ONFIELD,nil)
	local tc=g:GetFirst()
	local c=e:GetHandler()
	while tc do
		-- 将与该卡相关的连锁无效化，持续到回合结束（RESET_TURN_SET）。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 对方场上的全部表侧表示的卡的效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 对方场上的全部表侧表示的卡的效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(RESET_TURN_SET)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
end
