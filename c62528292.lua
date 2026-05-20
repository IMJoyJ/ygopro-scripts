--戦華史略－東南之風
-- 效果：
-- 这张卡发动后，第2次的自己准备阶段送去墓地。
-- ①：1回合1次，自己主要阶段才能发动。进行1次投掷硬币。表的场合，这张卡送去墓地。
-- ②：这张卡从魔法与陷阱区域送去墓地的场合才能发动。这个回合对方不能对应自己的「战华」卡的效果的发动把效果发动，自己场上的全部「战华」效果怪兽直到回合结束时得到以下效果。
-- ●这张卡的攻击宣言时才能发动。选对方场上1张卡破坏。
function c62528292.initial_effect(c)
	-- 这张卡发动后，第2次的自己准备阶段送去墓地。
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(62528292,0))
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetTarget(c62528292.target)
	c:RegisterEffect(e0)
	-- ①：1回合1次，自己主要阶段才能发动。进行1次投掷硬币。表的场合，这张卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(62528292,1))
	e1:SetCategory(CATEGORY_COIN+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c62528292.cointg)
	e1:SetOperation(c62528292.coinop)
	c:RegisterEffect(e1)
	-- ②：这张卡从魔法与陷阱区域送去墓地的场合才能发动。这个回合对方不能对应自己的「战华」卡的效果的发动把效果发动，自己场上的全部「战华」效果怪兽直到回合结束时得到以下效果。●这张卡的攻击宣言时才能发动。选对方场上1张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(62528292,2))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(c62528292.efcon)
	e2:SetTarget(c62528292.eftg)
	e2:SetOperation(c62528292.efop)
	c:RegisterEffect(e2)
end
-- 魔法卡发动时的效果处理，注册在第2个自己的准备阶段将这张卡送去墓地的效果。
function c62528292.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 这张卡发动后，第2次的自己准备阶段送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(c62528292.stgcon)
	e1:SetOperation(c62528292.stgop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,2)
	c:SetTurnCounter(0)
	c:RegisterEffect(e1)
end
-- 检查当前回合玩家是否为自己（准备阶段送去墓地效果的触发条件）。
function c62528292.stgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己。
	return Duel.GetTurnPlayer()==tp
end
-- 准备阶段送去墓地的效果处理，累加回合计数器，在第2次自己准备阶段时将这张卡送去墓地。
function c62528292.stgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetTurnCounter()
	ct=ct+1
	c:SetTurnCounter(ct)
	if ct==2 then
		-- 因规则原因将这张卡送去墓地。
		Duel.SendtoGrave(c,REASON_RULE)
	end
end
-- 投硬币效果的发动准备，检查自身是否能送去墓地，并设置投硬币和送去墓地的操作信息。
function c62528292.cointg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGrave() end
	-- 设置投硬币的操作信息（投掷1次）。
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
	-- 设置将这张卡送去墓地的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,e:GetHandler(),0,0,0)
end
-- 投硬币效果的处理，进行1次投硬币，若为正面（表）则将这张卡送去墓地。
function c62528292.coinop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 让玩家进行1次投硬币。
	local res=Duel.TossCoin(tp,1)
	if res==1 then
		-- 因效果原因将这张卡送去墓地。
		Duel.SendtoGrave(c,REASON_EFFECT)
	end
end
-- 检查这张卡之前是否在魔法与陷阱区域（送去墓地效果的发动条件）。
function c62528292.efcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_SZONE)
end
-- 过滤自己场上表侧表示的「战华」效果怪兽。
function c62528292.effilter(c)
	return c:IsFaceup() and c:IsSetCard(0x137) and c:IsType(TYPE_EFFECT)
end
-- 送去墓地时效果的发动准备（直接返回true）。
function c62528292.eftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
-- 送去墓地时效果的处理，注册本回合对方不能对应「战华」卡的效果发动而限制连锁的全局效果，并给自己场上所有「战华」效果怪兽注册攻击宣言时破坏卡片的效果。
function c62528292.efop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合对方不能对应自己的「战华」卡的效果的发动把效果发动，自己场上的全部「战华」效果怪兽直到回合结束时得到以下效果。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAINING)
	e1:SetOperation(c62528292.chainop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册全局效果（限制对方连锁）。
	Duel.RegisterEffect(e1,tp)
	-- 获取自己场上所有表侧表示的「战华」效果怪兽。
	local g=Duel.GetMatchingGroup(c62528292.effilter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- ●这张卡的攻击宣言时才能发动。选对方场上1张卡破坏。
		local e2=Effect.CreateEffect(tc)
		e2:SetDescription(aux.Stringid(62528292,3))  --"「战华史略-东南之风」效果适用中"
		e2:SetCategory(CATEGORY_DESTROY)
		e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
		e2:SetCode(EVENT_ATTACK_ANNOUNCE)
		e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetTarget(c62528292.destg)
		e2:SetOperation(c62528292.desop)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
end
-- 连锁发生时的处理，若是我方发动的「战华」卡的效果，则限制对方的连锁。
function c62528292.chainop(e,tp,eg,ep,ev,re,r,rp)
	if re:GetHandler():IsSetCard(0x137) and ep==tp then
		-- 设定连锁限制条件。
		Duel.SetChainLimit(c62528292.chainlm)
	end
end
-- 连锁限制条件函数，仅允许发动玩家（自己）进行连锁。
function c62528292.chainlm(e,ep,tp)
	return tp==ep
end
-- 赋予怪兽的破坏效果的发动准备，检查对方场上是否存在卡片，并设置破坏操作信息。
function c62528292.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1张卡。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上的所有卡。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 设置破坏对方场上1张卡的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 赋予怪兽的破坏效果的处理，让玩家选择对方场上1张卡并破坏。
function c62528292.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择对方场上1张卡。
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	if g:GetCount()>0 then
		-- 显式显示所选卡片的选中动画。
		Duel.HintSelection(g)
		-- 因效果原因破坏选中的卡。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
