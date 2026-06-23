--剣闘獣ヘラクレイノス
-- 效果：
-- 「剑斗兽 绳斗」＋名字带有「剑斗兽」的怪兽×2
-- 让自己场上的上记的卡回到卡组的场合才能从额外卡组特殊召唤（不需要「融合」魔法卡）。只要这张卡在场上表侧表示存在，可以通过丢弃1张手卡，魔法·陷阱卡的发动无效并破坏。
function c27346636.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用卡号为78868776的怪兽和2个名字带有「剑斗兽」的怪兽作为融合素材
	aux.AddFusionProcCodeFun(c,78868776,aux.FilterBoolFunction(Card.IsFusionSetCard,0x1019),2,true,true)
	-- 添加接触融合特殊召唤规则，通过将自己场上的符合条件的卡送回卡组来特殊召唤此卡
	aux.AddContactFusionProcedure(c,c27346636.cfilter,LOCATION_ONFIELD,0,aux.ContactFusionSendToDeck(c))
	-- 只要这张卡在场上表侧表示存在，可以通过丢弃1张手卡，魔法·陷阱卡的发动无效并破坏
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c27346636.splimit)
	c:RegisterEffect(e1)
	-- 无效发动并破坏
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
-- 限制此卡不能从额外卡组特殊召唤，只能通过接触融合方式特殊召唤
function c27346636.splimit(e,se,sp,st)
	return e:GetHandler():GetLocation()~=LOCATION_EXTRA
end
-- 过滤场上可以作为接触融合素材的卡，必须是「剑斗兽 绳斗」或名字带有「剑斗兽」的怪兽，并且可以作为召唤代价送回卡组
function c27346636.cfilter(c)
	return (c:IsFusionCode(78868776) or c:IsFusionSetCard(0x1019) and c:IsType(TYPE_MONSTER))
		and c:IsAbleToDeckOrExtraAsCost()
end
-- 连锁发动时的条件判断，确保此卡未在战斗中被破坏且对方发动的是魔法·陷阱卡
function c27346636.discon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		-- 对方发动的是魔法·陷阱卡且该连锁可以被无效
		and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
-- 丢弃1张手卡作为发动代价
function c27346636.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足丢弃手卡的条件
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 执行丢弃1张手卡的操作
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 设置连锁发动时的操作信息，包括使发动无效和破坏目标卡
function c27346636.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置使发动无效的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置破坏目标卡的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 执行效果操作，使连锁发动无效并破坏对应卡
function c27346636.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 判断连锁发动是否成功无效且目标卡仍然有效
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏目标卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
