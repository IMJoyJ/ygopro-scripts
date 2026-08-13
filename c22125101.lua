--軌跡の魔術師
-- 效果：
-- 包含灵摆怪兽的效果怪兽2只
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡在额外怪兽区域连接召唤的场合，支付1200基本分才能发动。从卡组把1只灵摆怪兽加入手卡。这个回合自己只要灵摆召唤不成功，不能把怪兽的效果发动，自己的灵摆区域的卡的效果无效化。
-- ②：这张卡所连接区有原本等级不同的怪兽2只同时灵摆召唤的场合，以场上2张卡为对象才能发动。那些卡破坏。
function c22125101.initial_effect(c)
	-- 为这张卡设置连接召唤手续：用2只效果怪兽作为连接素材，且素材组中必须至少包含1只灵摆怪兽。
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
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡所连接区有原本等级不同的怪兽2只同时灵摆召唤的场合，以场上2张卡为对象才能发动。那些卡破坏。
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
		-- 包含灵摆怪兽的效果怪兽2只；①：这张卡在额外怪兽区域连接召唤的场合，支付1200基本分才能发动。从卡组把1只灵摆怪兽加入手卡。这个回合自己只要灵摆召唤不成功，不能把怪兽的效果发动，自己的灵摆区域的卡的效果无效化。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS_G_P)
		ge1:SetOperation(c22125101.checkop)
		-- 将全局判定效果ge1注册到场上，用于监听全场特殊召唤成功前事件，为①效果的自肃条件提供辅助标记。
		Duel.RegisterEffect(ge1,0)
	end
end
-- checkop：在每次特殊召唤成功前，给进行召唤的玩家rp注册1个22125101标记，用于记录发生过特殊召唤/灵摆召唤，从而控制①自肃是否适用。
function c22125101.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家rp注册22125101标记，持续到结束阶段；有该标记时①效果的自肃不再适用。
	Duel.RegisterFlagEffect(rp,22125101,RESET_PHASE+PHASE_END,0,1)
end
-- lcheck：连接素材的额外检查条件，要求素材组中至少存在1只灵摆怪兽，以满足“包含灵摆怪兽的效果怪兽2只”的素材要求。
function c22125101.lcheck(g)
	return g:IsExists(Card.IsLinkType,1,nil,TYPE_PENDULUM)
end
-- thcon：①效果的发动条件，判定这张卡是以连接召唤方式特殊召唤成功，并且位于额外怪兽区域（sequence>4）。
function c22125101.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_LINK) and c:GetSequence()>4
end
-- thcost：①效果的发动代价处理，检查并支付1200基本分。
function c22125101.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测：在chk==0时确认玩家能够支付1200基本分，否则不能发动。
	if chk==0 then return Duel.CheckLPCost(tp,1200) end
	-- 实际支付1200基本分作为①效果的发动代价。
	Duel.PayLPCost(tp,1200)
end
-- thfilter：检索过滤器，选择卡组中的灵摆怪兽且能够加入手卡的卡。
function c22125101.thfilter(c)
	return c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
-- thtg：①效果发动时确认卡组存在符合条件的灵摆怪兽，并登记“从卡组将1张卡加入手卡”的操作信息。
function c22125101.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 目标检测：若卡组中不存在符合条件的灵摆怪兽，则①效果无法发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c22125101.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记操作信息：本次效果处理中会有1张卡从卡组加入手卡（不确定具体哪张，因此目标组为nil）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- thop：①效果处理：玩家从卡组选择1只灵摆怪兽加入手卡并展示给对方；随后清除自己的22125101标记使自肃开始，并给自己附加“不能发动怪兽效果”“灵摆区域卡效果无效”以及“灵摆区发动无效化”的自我限制。
function c22125101.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给出选择提示，让玩家在卡组中选择一张要加入手卡的灵摆怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张满足thfilter的灵摆怪兽。
	local g=Duel.SelectMatchingCard(tp,c22125101.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的灵摆怪兽加入持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡片展示给对手确认。
		Duel.ConfirmCards(1-tp,g)
	end
	-- 清除自己22125101的标记，使①效果的自肃开始适用（即保持“本回合尚未灵摆召唤成功”的状态）。
	Duel.ResetFlagEffect(tp,22125101)
	-- 这个回合自己只要灵摆召唤不成功，不能把怪兽的效果发动。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetCondition(c22125101.discon)
	e1:SetValue(c22125101.actlimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将“不能发动怪兽效果”的自肃效果注册给自己玩家，持续到结束阶段。
	Duel.RegisterEffect(e1,tp)
	-- 自己的灵摆区域的卡的效果无效化。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DISABLE)
	e2:SetTargetRange(LOCATION_PZONE,0)
	e2:SetCondition(c22125101.discon)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 将“自己灵摆区域的卡的效果无效化”的自肃效果注册给自己，持续到结束阶段。
	Duel.RegisterEffect(e2,tp)
	-- 这个回合自己只要灵摆召唤不成功，自己的灵摆区域的卡的效果无效化；②：这张卡所连接区有原本等级不同的怪兽2只同时灵摆召唤的场合，以场上2张卡为对象才能发动。那些卡破坏。
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetCondition(c22125101.discon)
	e3:SetOperation(c22125101.disop)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 注册自肃的连锁无效效果：在处理连锁时，若自己从灵摆区域发动了效果，则将其无效。
	Duel.RegisterEffect(e3,tp)
end
-- actlimit：限制本次“不能发动”的范围为怪兽效果，即只有发动的效果类型为怪兽卡时才被禁止。
function c22125101.actlimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER)
end
-- discon：自肃效果的适用条件，玩家没有22125101标记（本回合尚未灵摆召唤成功）时，自肃效果适用。
function c22125101.discon(e)
	local tp=e:GetHandlerPlayer()
	-- 判断玩家tp的22125101标记数量是否为0；为0表示尚未灵摆召唤成功，自肃条件满足。
	return Duel.GetFlagEffect(tp,22125101)==0
end
-- disop：连锁处理时，若该连锁是自己从灵摆区域发动的灵摆魔法效果，则将其无效化，完善“灵摆区域卡的效果无效化”的判定。
function c22125101.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的发动者所属玩家和发动位置，用于判断是否为自己从灵摆区域发动的效果。
	local p,loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CONTROLER,CHAININFO_TRIGGERING_LOCATION)
	if re:GetActiveType()==TYPE_PENDULUM+TYPE_SPELL and p==tp and bit.band(loc,LOCATION_PZONE)~=0 then
		-- 将对应的连锁效果无效化。
		Duel.NegateEffect(ev)
	end
end
-- cfilter：筛选出表侧表示、刚刚以灵摆召唤方式特殊召唤成功、原本等级大于0，并且包含在这次灵摆召唤组eg中的怪兽。
function c22125101.cfilter(c,eg)
	return c:IsFaceup() and c:IsSummonType(SUMMON_TYPE_PENDULUM) and c:GetOriginalLevel()>0 and eg:IsContains(c)
end
-- descon：②效果的发动条件，这张卡的连接区中存在2只同时灵摆召唤的怪兽，且它们的原本等级互不相同。
function c22125101.descon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetLinkedGroup():Filter(c22125101.cfilter,nil,eg)
	return #g==2 and g:GetClassCount(Card.GetOriginalLevel)==2
end
-- destg：②效果发动时选择场上2张卡作为对象，并登记破坏这些卡的操作信息。
function c22125101.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 目标检测：场上存在2张可以成为对象的卡时才可发动②效果。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,2,nil) end
	-- 提示玩家选择要破坏的2张卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上2张卡作为②效果的对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,2,2,nil)
	-- 登记操作信息：本次效果将破坏这2张卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
end
-- desop：②效果处理时，将选择的目标中仍与效果相关的卡破坏。
function c22125101.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本连锁发动时选择的2张目标卡，并筛选出仍然与效果e保持联系的卡（未被离场重置联系）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 以效果原因将这些卡破坏。
	Duel.Destroy(g,REASON_EFFECT)
end
