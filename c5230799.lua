--魔弾の射手 ザ・キッド
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，自己·对方回合自己可以把「魔弹」魔法·陷阱卡从手卡发动。
-- ②：和这张卡相同纵列有魔法·陷阱卡发动的场合，从手卡丢弃1张「魔弹」卡才能发动。自己抽2张。
function c5230799.initial_effect(c)
	-- 效果原文内容：①：只要这张卡在怪兽区域存在，自己·对方回合自己可以把「魔弹」魔法·陷阱卡从手卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(5230799,1))  --"适用「魔弹射手 小子」的效果来发动"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
	e1:SetRange(LOCATION_MZONE)
	-- 规则层面操作：设置效果目标为拥有「魔弹」字段的卡片。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x108))
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetValue(32841045)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	c:RegisterEffect(e2)
	-- 效果原文内容：②：和这张卡相同纵列有魔法·陷阱卡发动的场合，从手卡丢弃1张「魔弹」卡才能发动。自己抽2张。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(5230799,0))  --"抽滤"
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,5230799)
	e3:SetCondition(c5230799.drcon)
	e3:SetCost(c5230799.drcost)
	e3:SetTarget(c5230799.drtg)
	e3:SetOperation(c5230799.drop)
	c:RegisterEffect(e3)
end
-- 规则层面操作：判断连锁发动的卡片是否为魔法或陷阱卡且与该卡在同一纵列。
function c5230799.drcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and e:GetHandler():GetColumnGroup():IsContains(re:GetHandler())
end
-- 规则层面操作：过滤函数，用于筛选手牌中拥有「魔弹」字段且可丢弃的卡片。
function c5230799.cfilter(c)
	return c:IsSetCard(0x108) and c:IsDiscardable()
end
-- 规则层面操作：检查玩家手牌是否存在满足条件的「魔弹」卡并将其丢弃1张作为发动代价。
function c5230799.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面操作：检测是否满足丢弃1张「魔弹」卡的条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c5230799.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 规则层面操作：执行丢弃1张符合条件的「魔弹」卡的操作。
	Duel.DiscardHand(tp,c5230799.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 规则层面操作：检查玩家是否可以抽2张卡并设置抽卡效果的目标参数。
function c5230799.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面操作：检测是否满足抽卡条件。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 规则层面操作：设置连锁处理中抽卡效果的目标玩家为当前玩家。
	Duel.SetTargetPlayer(tp)
	-- 规则层面操作：设置连锁处理中抽卡效果的抽卡数量为2张。
	Duel.SetTargetParam(2)
	-- 规则层面操作：设置连锁处理中的抽卡效果信息，包括抽卡数量和目标玩家。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 规则层面操作：执行抽卡效果，从当前玩家的牌组中抽取指定数量的卡。
function c5230799.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：获取当前连锁处理中抽卡效果的目标玩家和抽卡数量。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 规则层面操作：根据目标玩家和抽卡数量执行实际抽卡动作。
	Duel.Draw(p,d,REASON_EFFECT)
end
