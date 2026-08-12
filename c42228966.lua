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
	-- ①：怪兽之间没有进行战斗的回合的自己主要阶段2，丢弃1张手卡才能发动。从卡组选1张「战场的惨剧」在自己的魔法与陷阱区域盖放。
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
		-- 为玩家0注册一个在怪兽战斗时触发的全局标识效果，用于标记是否发生过战斗。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_BATTLED)
		ge1:SetOperation(c42228966.checkop)
		-- 将标识效果ge1注册给玩家0，使其在全局生效。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 当有怪兽进行战斗时，为玩家0注册一个标识效果，标记本回合已发生战斗。
function c42228966.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果当前有攻击目标，则为玩家0注册一个编号为42228966的标识效果，该效果在结束阶段重置。
	if Duel.GetAttackTarget() then Duel.RegisterFlagEffect(0,42228966,RESET_PHASE+PHASE_END,0,1) end
end
-- 判断是否为未发生过战斗的回合且当前处于主要阶段2。
function c42228966.sscon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回是否未发生过战斗且当前阶段为主要阶段2。
	return Duel.GetFlagEffect(0,42228966)==0 and Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 支付发动效果的代价：丢弃1张手卡。
function c42228966.sscost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家手牌中是否存在可丢弃的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 从玩家手牌中丢弃1张可丢弃的卡作为发动代价。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤函数，用于筛选卡组中可盖放的「战场的惨剧」。
function c42228966.ssfilter(c)
	return c:IsCode(42228966) and c:IsSSetable()
end
-- 设置发动效果的目标：从卡组中选择1张「战场的惨剧」。
function c42228966.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家卡组中是否存在满足条件的「战场的惨剧」。
	if chk==0 then return Duel.IsExistingMatchingCard(c42228966.ssfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 发动效果的处理：选择并盖放1张「战场的惨剧」。
function c42228966.ssop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从玩家卡组中选择1张满足条件的「战场的惨剧」。
	local g=Duel.SelectMatchingCard(tp,c42228966.ssfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡盖放在玩家的魔法与陷阱区域。
		Duel.SSet(tp,g)
	end
end
-- 判断是否为发生过战斗的回合。
function c42228966.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回是否已发生过战斗。
	return Duel.GetFlagEffect(0,42228966)>0
end
-- 设置发动效果的目标：回合玩家从卡组上面把5张卡送去墓地。
function c42228966.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息，表示将从卡组上面送去墓地5张卡。
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,Duel.GetTurnPlayer(),5)
end
-- 发动效果的处理：回合玩家从卡组上面把5张卡送去墓地。
function c42228966.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 将回合玩家卡组最上面的5张卡送去墓地。
	Duel.DiscardDeck(Duel.GetTurnPlayer(),5,REASON_EFFECT)
end
