--魔界台本「魔王の降臨」
-- 效果：
-- ①：以最多有自己场上的攻击表示的「魔界剧团」怪兽种类数量的场上的表侧表示的卡为对象才能发动。那些卡破坏。自己场上有7星以上的「魔界剧团」怪兽存在的场合，对方不能对应这张卡的发动把效果发动。
-- ②：自己的额外卡组有表侧表示的「魔界剧团」灵摆怪兽存在，盖放的这张卡被对方的效果破坏的场合才能发动。从卡组把「魔界剧团」卡或者「魔界台本」魔法卡合计最多2张加入手卡（同名卡最多1张）。
function c13662809.initial_effect(c)
	-- 效果原文内容：①：以最多有自己场上的攻击表示的「魔界剧团」怪兽种类数量的场上的表侧表示的卡为对象才能发动。那些卡破坏。自己场上有7星以上的「魔界剧团」怪兽存在的场合，对方不能对应这张卡的发动把效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(13662809,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c13662809.target)
	e1:SetOperation(c13662809.activate)
	c:RegisterEffect(e1)
	-- 效果原文内容：②：自己的额外卡组有表侧表示的「魔界剧团」灵摆怪兽存在，盖放的这张卡被对方的效果破坏的场合才能发动。从卡组把「魔界剧团」卡或者「魔界台本」魔法卡合计最多2张加入手卡（同名卡最多1张）。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(13662809,1))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(c13662809.thcon)
	e2:SetTarget(c13662809.thtg)
	e2:SetOperation(c13662809.thop)
	c:RegisterEffect(e2)
end
-- 规则层面作用：定义用于筛选场上攻击表示的「魔界剧团」怪兽的过滤函数
function c13662809.cfilter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsSetCard(0x10ec)
end
-- 规则层面作用：定义用于筛选自己场上7星以上的「魔界剧团」怪兽的过滤函数
function c13662809.lmfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x10ec) and c:IsLevelAbove(7)
end
-- 规则层面作用：定义效果①的处理函数，用于设置效果目标
function c13662809.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsFaceup() and chkc~=e:GetHandler() end
	-- 规则层面作用：检查自己场上是否存在至少1只攻击表示的「魔界剧团」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c13662809.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 规则层面作用：检查自己场上是否存在至少1张表侧表示的场上卡作为目标
		and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 规则层面作用：获取自己场上所有攻击表示的「魔界剧团」怪兽组成的卡片组
	local g=Duel.GetMatchingGroup(c13662809.cfilter,tp,LOCATION_MZONE,0,nil)
	local ct=g:GetClassCount(Card.GetCode)
	-- 规则层面作用：向玩家提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	-- 规则层面作用：选择最多与攻击表示的「魔界剧团」怪兽种类数相同的场上表侧表示的卡作为目标
	local sg=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,e:GetHandler())
	-- 规则层面作用：设置效果处理信息，表示将要破坏目标卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
	-- 规则层面作用：检查自己场上是否存在7星以上的「魔界剧团」怪兽，若存在则设置连锁限制
	if Duel.IsExistingMatchingCard(c13662809.lmfilter,tp,LOCATION_MZONE,0,1,nil) and e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 规则层面作用：设置连锁限制，禁止对方在该效果发动时连锁发动效果
		Duel.SetChainLimit(c13662809.chainlm)
	end
end
-- 规则层面作用：定义效果①的发动处理函数
function c13662809.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：获取当前连锁的目标卡片组，并筛选出与该效果相关的卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 规则层面作用：将目标卡片组中的卡片以效果原因破坏
	Duel.Destroy(g,REASON_EFFECT)
end
-- 规则层面作用：定义连锁限制函数，用于限制对方不能连锁发动效果
function c13662809.chainlm(e,rp,tp)
	return tp==rp
end
-- 规则层面作用：定义用于筛选自己额外卡组中表侧表示的「魔界剧团」灵摆怪兽的过滤函数
function c13662809.filter2(c)
	return c:IsSetCard(0x10ec) and c:IsFaceup() and c:IsType(TYPE_PENDULUM)
end
-- 规则层面作用：定义效果②的发动条件函数，用于判断是否满足发动条件
function c13662809.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and rp==1-tp and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEDOWN)
		-- 规则层面作用：检查自己额外卡组是否存在至少1张表侧表示的「魔界剧团」灵摆怪兽
		and Duel.IsExistingMatchingCard(c13662809.filter2,tp,LOCATION_EXTRA,0,1,nil)
end
-- 规则层面作用：定义用于筛选可以加入手牌的「魔界剧团」卡或「魔界台本」魔法卡的过滤函数
function c13662809.thfilter(c)
	return (c:IsSetCard(0x10ec) or (c:IsSetCard(0x20ec) and c:IsType(TYPE_SPELL))) and c:IsAbleToHand()
end
-- 规则层面作用：定义效果②的目标设置函数
function c13662809.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：检查自己卡组是否存在至少1张符合条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c13662809.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 规则层面作用：设置效果处理信息，表示将要从卡组检索并加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 规则层面作用：定义效果②的发动处理函数
function c13662809.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：获取自己卡组中所有符合条件的卡组成的卡片组
	local g=Duel.GetMatchingGroup(c13662809.thfilter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()<=0 then return end
	-- 规则层面作用：向玩家提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 规则层面作用：从符合条件的卡中选择最多2张且卡名各不相同的卡
	local sg1=g:SelectSubGroup(tp,aux.dncheck,false,1,2)
	-- 规则层面作用：将选中的卡以效果原因加入手牌
	Duel.SendtoHand(sg1,nil,REASON_EFFECT)
	-- 规则层面作用：向对方确认加入手牌的卡
	Duel.ConfirmCards(1-tp,sg1)
end
