--神碑の翼フギン
-- 效果：
-- 「神碑」怪兽×2
-- ①：这张卡从额外卡组的特殊召唤成功的场合，丢弃1张手卡才能发动。从卡组把1张「神碑」场地魔法卡加入手卡。
-- ②：这张卡以外的自己场上的卡被效果破坏的场合，可以作为代替把场上的这张卡除外。
-- ③：场上的这张卡被战斗·效果破坏的场合发动。这张卡回到持有者的额外卡组。
function c55990317.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤手续，需要2只「神碑」怪兽作为融合素材
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x17f),2,true)
	-- ①：这张卡从额外卡组的特殊召唤成功的场合，丢弃1张手卡才能发动。从卡组把1张「神碑」场地魔法卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(55990317,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(c55990317.thcon)
	e1:SetCost(c55990317.thcost)
	e1:SetTarget(c55990317.thtg)
	e1:SetOperation(c55990317.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡以外的自己场上的卡被效果破坏的场合，可以作为代替把场上的这张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c55990317.desreptg)
	e2:SetValue(c55990317.desrepval)
	e2:SetOperation(c55990317.desrepop)
	c:RegisterEffect(e2)
	-- ③：场上的这张卡被战斗·效果破坏的场合发动。这张卡回到持有者的额外卡组。
	local e3=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(55990317,1))
	e3:SetCategory(CATEGORY_TOEXTRA)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(c55990317.tecon)
	e3:SetTarget(c55990317.tetg)
	e3:SetOperation(c55990317.teop)
	c:RegisterEffect(e3)
end
-- 效果①的发动条件：此卡是从额外卡组特殊召唤成功
function c55990317.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonLocation(LOCATION_EXTRA)
end
-- 效果①的代价：丢弃1张手卡
function c55990317.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在可以丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 玩家选择并丢弃1张手卡作为发动代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤条件：卡组中可加入手卡的「神碑」场地魔法卡
function c55990317.thfilter(c)
	return c:IsSetCard(0x17f) and c:IsType(TYPE_FIELD) and c:IsAbleToHand()
end
-- 效果①的靶向处理：检查卡组中是否存在「神碑」场地魔法卡，并设置检索的操作信息
function c55990317.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在符合条件的「神碑」场地魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c55990317.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示此效果会将卡组中的1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理：从卡组将1张「神碑」场地魔法卡加入手卡
function c55990317.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张符合条件的「神碑」场地魔法卡
	local g=Duel.SelectMatchingCard(tp,c55990317.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤条件：自己场上因效果破坏且非代替破坏的卡
function c55990317.repfilter(c,tp)
	return c:IsControler(tp) and c:IsOnField()
		and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- 代替破坏效果的靶向处理：检查是否有自己场上的卡被效果破坏，且此卡可以被除外
function c55990317.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(c55990317.repfilter,1,nil,tp)
		and c:IsAbleToRemove() and not c:IsStatus(STATUS_DESTROY_CONFIRMED+STATUS_BATTLE_DESTROYED) end
	-- 询问玩家是否使用此卡代替破坏
	return Duel.SelectEffectYesNo(tp,c,96)
end
-- 确定被代替破坏的卡是否符合过滤条件
function c55990317.desrepval(e,c)
	return c55990317.repfilter(c,e:GetHandlerPlayer())
end
-- 代替破坏的效果处理：将此卡除外
function c55990317.desrepop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示发动此卡的效果（显示卡片动画）
	Duel.Hint(HINT_CARD,0,55990317)
	-- 将此卡表侧表示除外，作为代替破坏的处理
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
end
-- 效果③的发动条件：场上的此卡被战斗或效果破坏
function c55990317.tecon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT+REASON_BATTLE) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 效果③的靶向处理：设置将此卡送回额外卡组的操作信息
function c55990317.tetg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示此效果会将此卡送回额外卡组
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,e:GetHandler(),1,0,0)
end
-- 效果③的效果处理：将此卡回到持有者的额外卡组
function c55990317.teop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡送回额外卡组
		Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
