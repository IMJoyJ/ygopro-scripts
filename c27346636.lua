--剣闘獣ヘラクレイノス
-- 效果：
-- 「剑斗兽 绳斗」＋名字带有「剑斗兽」的怪兽×2
-- 让自己场上的上记的卡回到卡组的场合才能从额外卡组特殊召唤（不需要「融合」魔法卡）。只要这张卡在场上表侧表示存在，可以通过丢弃1张手卡，魔法·陷阱卡的发动无效并破坏。
function c27346636.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：以1只「剑斗兽 绳斗」（卡号78868776）和2只名字带有「剑斗兽」的怪兽为融合素材，允许使用融合素材代用品。
	aux.AddFusionProcCodeFun(c,78868776,aux.FilterBoolFunction(Card.IsFusionSetCard,0x1019),2,true,true)
	-- 为这张卡添加接触融合召唤手续：无需「融合」魔法卡，将自己场上满足条件的融合素材送回卡组，作为从额外卡组特殊召唤的条件。
	aux.AddContactFusionProcedure(c,c27346636.cfilter,LOCATION_ONFIELD,0,aux.ContactFusionSendToDeck(c))
	-- 让自己场上的上记的卡回到卡组的场合才能从额外卡组特殊召唤（不需要「融合」魔法卡）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c27346636.splimit)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上表侧表示存在，可以通过丢弃1张手卡，魔法·陷阱卡的发动无效并破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(27346636,0))  --"无效发动并破坏"
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetCode(EVENT_CHAINING)
	e3:SetCondition(c27346636.discon)
	e3:SetCost(c27346636.discost)
	e3:SetTarget(c27346636.distg)
	e3:SetOperation(c27346636.disop)
	c:RegisterEffect(e3)
end
-- 特殊召唤条件判定函数：返回这张卡当前是否不在额外卡组，作为该特殊召唤限制效果的判定条件，以配合正规融合召唤手续。
function c27346636.splimit(e,se,sp,st)
	return e:GetHandler():GetLocation()~=LOCATION_EXTRA
end
-- 接触融合素材筛选条件：素材可以是「剑斗兽 绳斗」（卡号78868776），也可以是名字带有「剑斗兽」的怪兽；并且该素材必须能够作为Cost送回卡组/额外卡组。
function c27346636.cfilter(c)
	return (c:IsFusionCode(78868776) or c:IsFusionSetCard(0x1019) and c:IsType(TYPE_MONSTER))
		and c:IsAbleToDeckOrExtraAsCost()
end
-- 发动无效效果的发动条件：这张卡不在战斗破坏确定状态，且连锁的效果为魔法·陷阱卡的发动，并且该发动可以被无效时，才能发动此效果。
function c27346636.discon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		-- 且该连锁必须是魔法·陷阱卡的发动，且该发动可以被无效。
		and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
-- 效果发动代价：从手牌中丢弃1张卡；先检查手牌中是否存在可丢弃的卡，再选择1张手卡以『代价+丢弃』的理由丢弃。
function c27346636.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：当前是否存在至少1张除这张卡自身以外的、可以丢弃的手卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 支付代价：选择1张手卡丢弃，丢弃理由为『代价+丢弃』。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 目标处理：该效果无需选择对象；设置操作信息，将此次连锁中的魔法·陷阱卡作为无效对象；若该卡能被破坏且仍与效果关联，则同时设置其作为破坏对象。
function c27346636.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：对连锁的魔法·陷阱卡发动进行无效处理，对象为正在发动的效果卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：在无效成功后，将发动被无效的魔法·陷阱卡作为破坏对象，数量为1。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理：若此卡仍表侧表示在场且效果有效，则尝试无效该魔法·陷阱卡的发动；若无效成功且该卡仍与效果关联，则将其破坏。
function c27346636.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 执行无效该连锁的发动，并确认被无效的卡仍与效果关联，两者都满足才继续处理破坏。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将被无效并仍与效果关联的魔法·陷阱卡以效果理由破坏。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
