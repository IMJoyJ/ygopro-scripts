--召喚獣メルカバー
-- 效果：
-- 「召唤师 阿莱斯特」＋光属性怪兽
-- ①：1回合1次，怪兽的效果·魔法·陷阱卡发动时，把和那个效果相同种类（怪兽·魔法·陷阱）的1张卡从手卡送去墓地才能发动。那个发动无效并除外。
function c75286621.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合素材为「召唤师 阿莱斯特」和1只光属性怪兽
	aux.AddFusionProcCodeFun(c,86120751,aux.FilterBoolFunction(Card.IsFusionAttribute,ATTRIBUTE_LIGHT),1,true,true)
	-- ①：1回合1次，怪兽的效果·魔法·陷阱卡发动时，把和那个效果相同种类（怪兽·魔法·陷阱）的1张卡从手卡送去墓地才能发动。那个发动无效并除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(75286621,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c75286621.negcon)
	e1:SetCost(c75286621.negcost)
	-- 设置效果的目标处理函数为系统内置的无效并除外辅助函数
	e1:SetTarget(aux.nbtg)
	e1:SetOperation(c75286621.negop)
	c:RegisterEffect(e1)
end
-- 定义效果发动条件：自身未被战斗确定破坏，且被连锁的效果是怪兽效果、魔法或陷阱卡的发动，并且该发动可以被无效
function c75286621.negcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		-- 判断被连锁的效果是否为怪兽效果、魔法或陷阱卡的发动，且该发动可以被无效
		and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev)
end
-- 过滤手牌中与被连锁效果相同种类且可以作为代价送去墓地的卡
function c75286621.cfilter(c,rtype)
	return c:IsType(rtype) and c:IsAbleToGraveAsCost()
end
-- 定义效果发动代价：从手卡将1张与被连锁效果相同种类的卡送去墓地
function c75286621.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local rtype=bit.band(re:GetActiveType(),0x7)
	-- 在发动阶段检查手牌中是否存在满足条件的卡作为代价
	if chk==0 then return Duel.IsExistingMatchingCard(c75286621.cfilter,tp,LOCATION_HAND,0,1,nil,rtype) end
	-- 让玩家选择手牌中1张与被连锁效果相同种类的卡送去墓地作为发动代价
	Duel.DiscardHand(tp,c75286621.cfilter,1,1,REASON_COST,nil,rtype)
end
-- 定义效果处理：使该发动无效并除外
function c75286621.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果成功使该发动无效，且该卡在连锁中关系成立
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将被无效发动的卡表侧表示除外
		Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
	end
end
