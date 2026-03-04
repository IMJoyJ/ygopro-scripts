--P.U.N.K.JAM FEVER!
-- 效果：
-- 8星怪兽×2
-- 「朋克即兴狂热！」1回合1次也能在自己场上的「朋克」融合·同调怪兽上面重叠来超量召唤。这个卡名的①②的效果1回合各能使用1次。
-- ①：支付600基本分，把这张卡1个超量素材取除才能发动。自己抽1张。
-- ②：自己墓地有念动力族·3星怪兽存在，这张卡以外的怪兽的效果发动时，把这张卡1个超量素材取除才能发动。那个发动无效并破坏。
local s,id,o=GetID()
-- 初始化效果函数
function s.initial_effect(c)
	aux.AddXyzProcedure(c,nil,8,2,s.ovfilter,aux.Stringid(id,0),2,s.xyzop)
	c:EnableReviveLimit()
	-- ①：支付600基本分，把这张卡1个超量素材取除才能发动。自己抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.drtg)
	e1:SetOperation(s.drop)
	c:RegisterEffect(e1)
	-- ②：自己墓地有念动力族·3星怪兽存在，这张卡以外的怪兽的效果发动时，把这张卡1个超量素材取除才能发动。那个发动无效并破坏。
	local e2=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_NEGATE|CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.negcon)
	e2:SetCost(s.negcost)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
end
-- 判断是否满足超量召唤条件的过滤函数
function s.ovfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x171) and c:IsType(TYPE_FUSION+TYPE_SYNCHRO)
end
-- 超量召唤时的处理函数
function s.xyzop(e,tp,chk)
	-- 检查是否已使用过效果
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	-- 注册标识效果，防止效果重复使用
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- 支付费用的处理函数
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否能支付费用
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) and Duel.CheckLPCost(tp,600) end
	-- 支付600基本分
	Duel.PayLPCost(tp,600)
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 抽卡效果的目标设定函数
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置目标玩家
	Duel.SetTargetPlayer(tp)
	-- 设置目标参数
	Duel.SetTargetParam(1)
	-- 设置操作信息，准备执行抽卡效果
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 抽卡效果的执行函数
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁信息中的目标玩家和参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡效果
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 墓地念动力族3星怪兽的过滤函数
function s.cfilter(c)
	return c:IsLevel(3) and c:IsRace(RACE_PSYCHO)
end
-- 无效效果发动的条件函数
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查连锁是否可以被无效
	return Duel.IsChainNegatable(ev) and not c:IsStatus(STATUS_BATTLE_DESTROYED)
		and re:GetHandler()~=c and re:IsActiveType(TYPE_MONSTER)
		-- 检查自己墓地是否存在念动力族3星怪兽
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil)
end
-- 无效效果发动的费用支付函数
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 无效效果发动的目标设定函数
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，准备执行无效效果
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息，准备执行破坏效果
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 无效效果发动的执行函数
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 执行无效效果并判断是否可以破坏
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏发动的效果卡片
		Duel.Destroy(re:GetHandler(),REASON_EFFECT)
	end
end
