--血の沼地
-- 效果：
-- 自己场上有这张卡以外的魔法·陷阱卡存在的场合，这张卡破坏。只要这张卡在场上存在，魔法与陷阱卡区域盖放的卡不能发动。第2次的自己的准备阶段时这张卡破坏。
function c60627999.initial_effect(c)
	-- 第2次的自己的准备阶段时这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c60627999.target)
	c:RegisterEffect(e1)
	-- 自己场上有这张卡以外的魔法·陷阱卡存在的场合，这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EFFECT_SELF_DESTROY)
	e2:SetCondition(c60627999.sdescon)
	c:RegisterEffect(e2)
	-- 只要这张卡在场上存在，魔法与陷阱卡区域盖放的卡不能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetCode(EFFECT_CANNOT_TRIGGER)
	e3:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
	e3:SetTarget(c60627999.acttg)
	c:RegisterEffect(e3)
end
-- 卡片发动时，将自身的回合计数器清零，并注册一个不可无效的持续效果，用于在每次自己的准备阶段计数，到第2次时破坏这张卡。
function c60627999.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	c:SetTurnCounter(0)
	-- 第2次的自己的准备阶段时这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(c60627999.descon)
	e1:SetOperation(c60627999.desop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,2)
	c:RegisterEffect(e1)
end
-- 作为持续效果的发动条件，判定当前是否为这张卡的控制者的回合，即只有自己的准备阶段才进行后续处理。
function c60627999.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为这张卡的控制者，以限定只有自己的准备阶段才满足条件。
	return tp==Duel.GetTurnPlayer()
end
-- 在每个满足条件的自己的准备阶段，将这张卡的回合计数器加1；当计数器达到2时，以效果原因破坏这张卡。
function c60627999.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetTurnCounter()
	ct=ct+1
	c:SetTurnCounter(ct)
	if ct==2 then
		-- 以效果原因将这张卡破坏（此时已经经过第2次自己的准备阶段）。
		Duel.Destroy(c,REASON_EFFECT)
	end
end
-- 检查这张卡的控制者场上是否存在这张卡以外的魔法·陷阱卡，若存在则满足自我破坏条件。
function c60627999.sdescon(e)
	-- 从控制者场上检查是否存在至少1张这张卡以外的魔法·陷阱卡，作为触发自我破坏的条件。
	return Duel.IsExistingMatchingCard(Card.IsType,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,e:GetHandler(),TYPE_SPELL+TYPE_TRAP)
end
-- 筛选出里侧表示且不在场地魔法区域（第6个魔法与陷阱区域）的卡，即魔法与陷阱区域盖放的卡，作为不能发动效果的对象。
function c60627999.acttg(e,c)
	return c:IsFacedown() and c:GetSequence()~=5
end
