--戦場の惨劇
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：怪兽之间没有进行战斗的回合的自己主要阶段2，丢弃1张手卡才能发动。从卡组选1张「战场的惨剧」在自己的魔法与陷阱区域盖放。
-- ②：怪兽之间进行战斗的回合的结束阶段发动。回合玩家从自身卡组上面把5张卡送去墓地。
function c42228966.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 这个卡名的①的效果1回合只能使用1次。①：怪兽之间没有进行战斗的回合的自己主要阶段2，丢弃1张手卡才能发动。从卡组选1张「战场的惨剧」在自己的魔法与陷阱区域盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCategory(CATEGORY_SSET)
	e2:SetCountLimit(1,42228966)
	e2:SetCondition(c42228966.sscon)
	e2:SetCost(c42228966.sscost)
	e2:SetTarget(c42228966.sstg)
	e2:SetOperation(c42228966.ssop)
	c:RegisterEffect(e2)
	-- ②：怪兽之间进行战斗的回合的结束阶段发动。回合玩家从自身卡组上面把5张卡送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DECKDES)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c42228966.tgcon)
	e3:SetTarget(c42228966.tgtg)
	e3:SetOperation(c42228966.tgop)
	c:RegisterEffect(e3)
	if not c42228966.global_check then
		c42228966.global_check=true
		-- 怪兽之间进行战斗的回合
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_BATTLED)
		ge1:SetOperation(c42228966.checkop)
		-- 将全局监测效果ge1注册到决斗中（归属玩家0），使每次发生伤害计算后（EVENT_BATTLED）都会执行checkop，用来记录本回合是否存在过怪兽之间的战斗。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 全局监测效果的操作函数：每当发生战斗事件时，如果攻击目标存在（即怪兽之间进行了战斗），就为双方玩家（0）注册一个结束阶段重置的标识，表示本回合发生过怪兽间战斗。
function c42228966.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断本次战斗是否为怪兽之间的战斗：若存在攻击目标则不是直接攻击，于是给玩家0注册标识，记录本回合已发生怪兽间战斗。
	if Duel.GetAttackTarget() then Duel.RegisterFlagEffect(0,42228966,RESET_PHASE+PHASE_END,0,1) end
end
-- ①效果的发动条件：本回合没有发生过怪兽之间的战斗（标识数为0），且当前处于自己主要阶段2（PHASE_MAIN2）。
function c42228966.sscon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断条件：全场没有‘发生过怪兽间战斗’的标识（flag=0），并且当前阶段是主要阶段2。
	return Duel.GetFlagEffect(0,42228966)==0 and Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- ①效果的发动代价：从手卡丢弃1张卡。chk==0时只检查能否支付；实际处理时让玩家选择1张可丢弃的手卡丢弃，原因为代价和丢弃。
function c42228966.sscost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：确认手牌中存在至少1张可以丢弃的卡，以确保能够支付丢弃1张手卡的代价。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 实际支付代价：玩家从手卡选择1张可以丢弃的卡送去墓地，丢弃原因设置为‘代价+丢弃’（REASON_COST+REASON_DISCARD）。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 定义检索过滤条件：卡必须是「战场的惨剧」（卡号42228966）且能够盖放到魔法与陷阱区（IsSSetable）。
function c42228966.ssfilter(c)
	return c:IsCode(42228966) and c:IsSSetable()
end
-- ①效果的目标设定：确认卡组中存在至少1张符合条件的「战场的惨剧」才能发动；效果处理时从卡组选卡，不取对象。
function c42228966.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：确认卡组中存在至少1张满足 c42228966.ssfilter 条件的「战场的惨剧」可供盖放。
	if chk==0 then return Duel.IsExistingMatchingCard(c42228966.ssfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- ①效果处理操作：先给玩家显示选择提示，然后从自己卡组选择1张符合条件的「战场的惨剧」，将其盖放到自己的魔法与陷阱区域。
function c42228966.ssop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送‘请选择要盖放的卡’的提示消息（HINTMSG_SET），供后续选择卡时显示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家从自己卡组中选择1张满足 c42228966.ssfilter 的卡（即「战场的惨剧」），结果存入临时组g。
	local g=Duel.SelectMatchingCard(tp,c42228966.ssfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选出的卡以表侧表示盖放到自己的魔法与陷阱区域（不发动，仅Set）。
		Duel.SSet(tp,g)
	end
end
-- ②效果的发动条件：本回合发生过怪兽之间的战斗（标识数大于0）。该效果为必发诱发效果，满足条件时在结束阶段强制发动。
function c42228966.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否存在‘本回合发生过怪兽间战斗’的标识，若存在则返回true，满足②效果的发动条件。
	return Duel.GetFlagEffect(0,42228966)>0
end
-- ②效果的目标设定：发动不需要选择对象；同时设置操作信息，告知系统将从卡组把5张卡送去墓地，处理对象为当前回合玩家。
function c42228966.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记操作信息：效果类别为卡组送墓（CATEGORY_DECKDES），数量为5，处理对象为当前回合玩家（Duel.GetTurnPlayer()），位置为卡组。用于联动其他卡片的检测。
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,Duel.GetTurnPlayer(),5)
end
-- ②效果处理操作：将当前回合玩家的卡组最上方5张卡送去墓地。
function c42228966.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 实际执行：从当前回合玩家卡组上面取5张卡送去墓地，原因为效果（REASON_EFFECT）。
	Duel.DiscardDeck(Duel.GetTurnPlayer(),5,REASON_EFFECT)
end
