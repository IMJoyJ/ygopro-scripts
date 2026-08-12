--神碑の翼ムニン
-- 效果：
-- 「神碑」怪兽×2
-- ①：这张卡从额外卡组的特殊召唤成功的场合，丢弃1张手卡才能发动。从卡组把1张「神碑」永续魔法卡加入手卡。
-- ②：以自己场上的「神碑」卡或者盖放的卡为对象的魔法·陷阱·怪兽的效果由对方发动时，把场上的这张卡除外才能发动。那个发动无效并破坏。
-- ③：自己·对方的结束阶段发动。自己回复1000基本分。
function c92385016.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤手续，需要2只「神碑」怪兽作为融合素材
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x17f),2,true)
	-- ①：这张卡从额外卡组的特殊召唤成功的场合，丢弃1张手卡才能发动。从卡组把1张「神碑」永续魔法卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(92385016,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCost(c92385016.thcost)
	e1:SetCondition(c92385016.thcon)
	e1:SetTarget(c92385016.thtg)
	e1:SetOperation(c92385016.thop)
	c:RegisterEffect(e1)
	-- ②：以自己场上的「神碑」卡或者盖放的卡为对象的魔法·陷阱·怪兽的效果由对方发动时，把场上的这张卡除外才能发动。那个发动无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(92385016,1))  --"发动无效并破坏"
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c92385016.discon)
	-- 把场上的这张卡除外作为发动的代价（Cost）
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c92385016.distg)
	e2:SetOperation(c92385016.disop)
	c:RegisterEffect(e2)
	-- ③：自己·对方的结束阶段发动。自己回复1000基本分。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(92385016,2))  --"回复基本分"
	e3:SetCategory(CATEGORY_RECOVER)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCountLimit(1)
	e3:SetTarget(c92385016.rectg)
	e3:SetOperation(c92385016.recop)
	c:RegisterEffect(e3)
end
-- 效果①的Cost函数：丢弃1张手卡
function c92385016.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在至少1张可以丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 玩家选择并丢弃1张手卡作为发动代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 效果①的发动条件：此卡必须是从额外卡组特殊召唤成功
function c92385016.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonLocation(LOCATION_EXTRA)
end
-- 效果①的检索过滤条件：卡组中的「神碑」永续魔法卡
function c92385016.thfilter(c)
	return c:IsType(TYPE_CONTINUOUS) and c:IsType(TYPE_SPELL) and c:IsSetCard(0x17f) and c:IsAbleToHand()
end
-- 效果①的Target函数：检查卡组中是否存在符合条件的卡，并设置检索的操作信息
function c92385016.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张符合条件的「神碑」永续魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c92385016.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息，表示将从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的Operation函数：从卡组将1张「神碑」永续魔法卡加入手卡
function c92385016.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组中选择1张符合条件的「神碑」永续魔法卡
	local g=Duel.SelectMatchingCard(tp,c92385016.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果②的对象过滤条件：自己场上的「神碑」卡或者盖放的卡
function c92385016.tfilter(c,tp)
	return c:IsOnField() and c:IsControler(tp) and (c:IsSetCard(0x17f) or c:IsFacedown())
end
-- 效果②的发动条件：对方发动了以自己场上的「神碑」卡或盖放的卡为对象的效果，且该发动可以被无效
function c92385016.discon(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁的对象卡片组
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 检查对象卡片组中是否存在自己场上的「神碑」卡或盖放的卡，且该连锁的发动可以被无效
	return tg and tg:IsExists(c92385016.tfilter,1,nil,tp) and Duel.IsChainNegatable(ev)
end
-- 效果②的Target函数：设置无效发动和破坏的操作信息
function c92385016.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理的操作信息，表示将无效该效果的发动
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置连锁处理的操作信息，表示将破坏该卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果②的Operation函数：使该发动无效并破坏
function c92385016.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果成功使该发动无效，且该卡在连锁处理时仍与效果相关联
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏该卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 效果③的Target函数：设置回复基本分的对象玩家和数值，并设置回复的操作信息
function c92385016.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置回复效果的对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置回复的数值为1000
	Duel.SetTargetParam(1000)
	-- 设置连锁处理的操作信息，表示自己将回复1000基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1000)
end
-- 效果③的Operation函数：执行回复1000基本分的操作
function c92385016.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的对象玩家和回复数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 玩家回复对应的基本分
	Duel.Recover(p,d,REASON_EFFECT)
end
