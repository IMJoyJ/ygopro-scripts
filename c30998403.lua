--DDD天空王ゼウス・ラグナロク
-- 效果：
-- 「DD」怪兽2只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：以自己场上1张「DD」卡或「契约书」卡为对象才能发动。那张卡破坏。这个回合，自己在通常的灵摆召唤外加上只有1次，自己主要阶段可以把「DD」怪兽灵摆召唤。
-- ②：对方把手卡的怪兽的效果发动时，从自己墓地把1只「DD」怪兽和1张「契约书」卡除外才能发动。那个发动无效。
local s,id,o=GetID()
-- 初始化效果，设置连接召唤手续并启用复活限制，注册两个效果：①破坏并获得额外灵摆召唤；②对方手卡怪兽发动效果时使发动无效
function s.initial_effect(c)
	-- 为该卡添加连接召唤手续，要求使用至少2张「DD」卡作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0xaf),2)
	c:EnableReviveLimit()
	-- 效果①：以自己场上1张「DD」卡或「契约书」卡为对象才能发动。那张卡破坏。这个回合，自己在通常的灵摆召唤外加上只有1次，自己主要阶段可以把「DD」怪兽灵摆召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"破坏并获得额外灵摆"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	-- 效果②：对方把手卡的怪兽的效果发动时，从自己墓地把1只「DD」怪兽和1张「契约书」卡除外才能发动。那个发动无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"发动无效"
	e2:SetCategory(CATEGORY_NEGATE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.negcon)
	e2:SetCost(s.negcost)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断目标卡是否为表侧表示的「DD」或「契约书」卡
function s.desfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xaf,0xae)
end
-- 效果①的发动时处理函数，检查是否满足发动条件并选择目标卡
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.desfilter(chkc) end
	-- 检查是否满足效果①的发动条件：本回合未发动过此效果且场上存在满足条件的目标卡
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 and Duel.IsExistingTarget(s.desfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择满足条件的目标卡
	local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 设置操作信息，指定将要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果①的处理函数，破坏目标卡并为本回合添加一次额外灵摆召唤效果
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	-- 如果目标卡仍然存在于连锁中，则将其破坏
	if tc:IsRelateToChain() then Duel.Destroy(tc,REASON_EFFECT) end
	-- 检查本回合是否已发动过效果①
	if Duel.GetFlagEffect(tp,id)==0 then
		-- 为本回合添加一次额外灵摆召唤效果并注册标识效果
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,2))  --"使用「DDD 天空王 宙斯末日神」的效果灵摆召唤"
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_EXTRA_PENDULUM_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetCountLimit(1,id+o)
		e1:SetValue(s.pendvalue)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册额外灵摆召唤效果
		Duel.RegisterEffect(e1,tp)
		-- 注册标识效果，防止本回合再次发动效果①
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	end
end
-- 返回值函数，用于判断是否为「DD」卡
function s.pendvalue(e,c)
	return c:IsSetCard(0xaf)
end
-- 效果②的发动条件函数，判断是否为对方手卡怪兽发动的效果
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的发动位置信息
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	-- 返回是否为对方手卡发动的怪兽效果且可被无效
	return ep==1-tp and loc==LOCATION_HAND and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end
-- 过滤函数，用于判断墓地中的卡是否可以作为除外的代价
function s.rmfilter(c)
	return c:IsAbleToRemoveAsCost() and
		(c:IsSetCard(0xaf) and c:IsType(TYPE_MONSTER) or c:IsSetCard(0xae))
end
-- 过滤函数，用于判断墓地中的「DD」怪兽是否可以作为除外的代价
function s.cfilter1(c)
	return c:IsSetCard(0xaf) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 过滤函数，用于判断墓地中的「契约书」卡是否可以作为除外的代价
function s.cfilter2(c)
	return c:IsSetCard(0xae) and c:IsAbleToRemoveAsCost()
end
-- 效果②的发动时处理函数，检查是否满足发动条件并选择除外的卡
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家墓地中所有可作为除外代价的卡
	local rg=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_GRAVE,0,nil)
	-- 检查是否满足效果②的发动条件：墓地中有满足条件的2张卡
	if chk==0 then return rg:CheckSubGroup(aux.gffcheck,2,2,s.cfilter1,nil,s.cfilter2,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的2张卡作为除外代价
	local g=rg:SelectSubGroup(tp,aux.gffcheck,false,2,2,s.cfilter1,nil,s.cfilter2,nil)
	-- 将选择的卡除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果②的目标处理函数，设置操作信息
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，指定将要无效的发动
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 效果②的处理函数，使发动无效
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 使当前连锁的发动无效
	Duel.NegateActivation(ev)
end
