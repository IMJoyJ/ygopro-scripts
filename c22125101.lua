--軌跡の魔術師
-- 效果：
-- 包含灵摆怪兽的效果怪兽2只
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡在额外怪兽区域连接召唤的场合，支付1200基本分才能发动。从卡组把1只灵摆怪兽加入手卡。这个回合自己只要灵摆召唤不成功，不能把怪兽的效果发动，自己的灵摆区域的卡的效果无效化。
-- ②：这张卡所连接区有原本等级不同的怪兽2只同时灵摆召唤的场合，以场上2张卡为对象才能发动。那些卡破坏。
function c22125101.initial_effect(c)
	-- 为卡片添加连接召唤手续，要求使用至少2张且至多2张满足类型为效果怪兽的连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),2,2,c22125101.lcheck)
	c:EnableReviveLimit()
	-- ①：这张卡在额外怪兽区域连接召唤的场合，支付1200基本分才能发动。从卡组把1只灵摆怪兽加入手卡。这个回合自己只要灵摆召唤不成功，不能把怪兽的效果发动，自己的灵摆区域的卡的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(22125101,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(c22125101.thcon)
	e1:SetCost(c22125101.thcost)
	e1:SetTarget(c22125101.thtg)
	e1:SetOperation(c22125101.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡所连接区有原本等级不同的怪兽2只同时灵摆召唤的场合，以场上2张卡为对象才能发动。那些卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(22125101,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,22125101)
	e2:SetCondition(c22125101.descon)
	e2:SetTarget(c22125101.destg)
	e2:SetOperation(c22125101.desop)
	c:RegisterEffect(e2)
	if not c22125101.global_check then
		c22125101.global_check=true
		-- 注册一个全局持续效果，用于记录灵摆召唤成功的玩家
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS_G_P)
		ge1:SetOperation(c22125101.checkop)
		-- 将全局效果ge1注册到玩家0（游戏环境）
		Duel.RegisterEffect(ge1,0)
	end
end
-- 当有灵摆召唤成功时，为对应玩家注册一个标识效果
function c22125101.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 为玩家rp注册一个标识效果，用于标记该玩家在本回合内是否已经发动过②效果
	Duel.RegisterFlagEffect(rp,22125101,RESET_PHASE+PHASE_END,0,1)
end
-- 连接召唤时的过滤函数，检查连接素材中是否包含灵摆怪兽
function c22125101.lcheck(g)
	return g:IsExists(Card.IsLinkType,1,nil,TYPE_PENDULUM)
end
-- 判断是否为连接召唤且在额外怪兽区域
function c22125101.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_LINK) and c:GetSequence()>4
end
-- 支付1200基本分作为效果发动的费用
function c22125101.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付1200基本分
	if chk==0 then return Duel.CheckLPCost(tp,1200) end
	-- 让玩家支付1200基本分
	Duel.PayLPCost(tp,1200)
end
-- 检索满足条件的灵摆怪兽过滤函数
function c22125101.thfilter(c)
	return c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
-- 设置效果发动时的操作信息，指定从卡组检索1张灵摆怪兽加入手牌
function c22125101.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家在卡组中是否存在满足条件的灵摆怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c22125101.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，指定将1张卡从卡组加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 处理效果发动的执行逻辑，包括检索灵摆怪兽、确认卡片、重置标识并施加限制
function c22125101.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的灵摆怪兽加入手牌
	local g=Duel.SelectMatchingCard(tp,c22125101.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的灵摆怪兽送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认被送入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
	-- 重置玩家的标识效果，表示本回合已使用过②效果
	Duel.ResetFlagEffect(tp,22125101)
	-- 创建并注册一个禁止玩家发动怪兽效果的永续效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetCondition(c22125101.discon)
	e1:SetValue(c22125101.actlimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果e1注册给玩家tp
	Duel.RegisterEffect(e1,tp)
	-- 创建并注册一个无效化玩家灵摆区域卡片效果的永续效果
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DISABLE)
	e2:SetTargetRange(LOCATION_PZONE,0)
	e2:SetCondition(c22125101.discon)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果e2注册给玩家tp
	Duel.RegisterEffect(e2,tp)
	-- 创建并注册一个在连锁处理时无效灵摆区域魔法卡效果的持续效果
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetCondition(c22125101.discon)
	e3:SetOperation(c22125101.disop)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果e3注册给玩家tp
	Duel.RegisterEffect(e3,tp)
end
-- 限制效果发动的函数，仅对怪兽类型的效果生效
function c22125101.actlimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER)
end
-- 判断是否为本回合内未使用过②效果的玩家
function c22125101.discon(e)
	local tp=e:GetHandlerPlayer()
	-- 判断玩家是否未使用过②效果
	return Duel.GetFlagEffect(tp,22125101)==0
end
-- 处理连锁中灵摆区域魔法卡效果被无效的逻辑
function c22125101.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁触发时的玩家和位置信息
	local p,loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CONTROLER,CHAININFO_TRIGGERING_LOCATION)
	if re:GetActiveType()==TYPE_PENDULUM+TYPE_SPELL and p==tp and bit.band(loc,LOCATION_PZONE)~=0 then
		-- 使连锁效果无效
		Duel.NegateEffect(ev)
	end
end
-- 灵摆召唤成功时的过滤函数，用于筛选满足条件的灵摆怪兽
function c22125101.cfilter(c,eg)
	return c:IsFaceup() and c:IsSummonType(SUMMON_TYPE_PENDULUM) and c:GetOriginalLevel()>0 and eg:IsContains(c)
end
-- 判断是否满足②效果发动条件，即连接区有2只不同等级的灵摆怪兽
function c22125101.descon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetLinkedGroup():Filter(c22125101.cfilter,nil,eg)
	return #g==2 and g:GetClassCount(Card.GetOriginalLevel)==2
end
-- 设置效果发动时的操作信息，指定选择2张场上卡进行破坏
function c22125101.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 检查场上是否存在至少2张满足条件的卡
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,2,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择2张场上卡作为破坏对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,2,2,nil)
	-- 设置操作信息，指定破坏2张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
end
-- 处理效果发动的执行逻辑，包括选择破坏对象并执行破坏
function c22125101.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中目标卡组并筛选出与效果相关的卡
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 将目标卡破坏
	Duel.Destroy(g,REASON_EFFECT)
end
