--カードスキャナー
-- 效果：
-- ①：1回合1次，宣言1个卡的种类（怪兽·魔法·陷阱）才能发动。双方玩家各自把自身卡组最下面的卡给双方确认，宣言的种类的场合，那卡加入自身手卡。不是的场合，确认的卡在自身卡组最上面放置。
-- ②：魔法与陷阱区域的表侧表示的这张卡被对方的效果破坏的场合才能发动。对方选自身1张手卡回到卡组最下面。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，宣言1个卡的种类（怪兽·魔法·陷阱）才能发动。双方玩家各自把自身卡组最下面的卡给双方确认，宣言的种类的场合，那卡加入自身手卡。不是的场合，确认的卡在自身卡组最上面放置。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- ②：魔法与陷阱区域的表侧表示的这张卡被对方的效果破坏的场合才能发动。对方选自身1张手卡回到卡组最下面。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(s.tdcon)
	e3:SetTarget(s.tdtg)
	e3:SetOperation(s.tdop)
	c:RegisterEffect(e3)
end
-- 效果①的发动准备与合法性检测函数，检查双方卡组中是否存在可以加入手牌的卡
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方卡组中是否存在可以加入手牌的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_DECK,0,1,nil)
		-- 检查对方卡组中是否存在可以加入手牌的卡
		and Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,0,LOCATION_DECK,1,nil,1-tp) end
	-- 向发动效果的玩家提示选择卡片种类
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)  --"请选择一个种类"
	-- 让发动效果的玩家宣言一个卡片种类（怪兽·魔法·陷阱），并将宣言的结果保存为效果目标参数
	Duel.SetTargetParam(Duel.AnnounceType(tp))
end
-- 效果①的处理函数，双方确认各自卡组最下方的卡，根据是否符合宣言种类进行加入手牌或置于卡组最上方的处理
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 若任意一方的卡组数量为0，则不进行处理
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 or Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)==0 then return end
	-- 获取己方卡组最下方的卡
	local sc=Duel.GetFieldCard(tp,LOCATION_DECK,0)
	-- 获取对方卡组最下方的卡
	local oc=Duel.GetFieldCard(1-tp,LOCATION_DECK,0)
	-- 让己方玩家确认己方卡组最下方的卡
	Duel.ConfirmCards(tp,sc)
	-- 让对方玩家确认己方卡组最下方的卡
	Duel.ConfirmCards(1-tp,sc)
	-- 让己方玩家确认对方卡组最下方的卡
	Duel.ConfirmCards(tp,oc)
	-- 让对方玩家确认对方卡组最下方的卡
	Duel.ConfirmCards(1-tp,oc)
	-- 获取之前宣言的卡片种类
	local op=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if sc:IsType(1<<op) then
		-- 关闭接下来的洗牌检测，防止卡片加入手牌时自动洗牌
		Duel.DisableShuffleCheck()
		-- 将己方确认的卡加入己方手牌
		Duel.SendtoHand(sc,nil,REASON_EFFECT)
	-- 若不符合宣言种类，则将己方确认的卡放置在己方卡组最上面
	else Duel.MoveSequence(sc,SEQ_DECKTOP) end
	if oc:IsType(1<<op) then
		-- 关闭接下来的洗牌检测，防止卡片加入手牌时自动洗牌
		Duel.DisableShuffleCheck()
		-- 将对方确认的卡加入对方手牌
		Duel.SendtoHand(oc,nil,REASON_EFFECT,1-tp)
	-- 若不符合宣言种类，则将对方确认的卡放置在对方卡组最上面
	else Duel.MoveSequence(oc,SEQ_DECKTOP) end
end
-- 效果②的发动条件函数，检查是否是魔法与陷阱区域表侧表示的这张卡被对方的效果破坏
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_SZONE)
		and rp==1-tp and c:IsReason(REASON_EFFECT)
end
-- 效果②的发动准备与合法性检测函数，检查对方手牌是否大于0并设置操作信息
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方手牌数量是否大于0
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
	-- 设置效果处理信息，表示将对方手牌中的1张卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,1-tp,LOCATION_HAND)
end
-- 效果②的处理函数，让对方选择自身1张手牌回到卡组最下面
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 向对方玩家提示选择要送回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让对方玩家从自身手牌中选择1张卡
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND):Select(1-tp,1,1,nil)
	-- 将选中的卡送回持有者卡组的最下面
	Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_RULE)
end
