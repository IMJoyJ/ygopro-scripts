--炎斬機マグマ
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡战斗破坏怪兽时，以对方场上最多2张卡为对象才能发动。那些卡破坏。
-- ②：这张卡被战斗或者对方的效果破坏的场合才能发动。从卡组把1张「斩机」魔法·陷阱卡加入手卡。
function c15248594.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和1只调整以外的怪兽作为素材
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡战斗破坏怪兽时，以对方场上最多2张卡为对象才能发动。那些卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(15248594,0))  --"卡片破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,15248594)
	-- 设置效果发动条件为当前怪兽正在参与战斗破坏怪兽的处理
	e1:SetCondition(aux.bdcon)
	e1:SetTarget(c15248594.destg)
	e1:SetOperation(c15248594.desop)
	c:RegisterEffect(e1)
	-- ②：这张卡被战斗或者对方的效果破坏的场合才能发动。从卡组把1张「斩机」魔法·陷阱卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(15248594,1))  --"卡组检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,15248595)
	e2:SetCondition(c15248594.thcon)
	e2:SetTarget(c15248594.thtg)
	e2:SetOperation(c15248594.thop)
	c:RegisterEffect(e2)
end
-- 处理效果选择目标时的函数，用于选择对方场上的1~2张卡作为破坏对象
function c15248594.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 检查是否满足选择目标的条件，即对方场上是否存在至少1张卡
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向玩家提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	-- 选择对方场上的1~2张卡作为破坏对象
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,2,nil)
	-- 设置效果操作信息，指定将要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 处理效果发动时的破坏操作，获取连锁中设定的目标卡并进行破坏
function c15248594.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标卡组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 将目标卡组中的卡以效果原因破坏
		Duel.Destroy(tg,REASON_EFFECT)
	end
end
-- 设置效果发动条件，判断是否为战斗破坏或对方效果破坏
function c15248594.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_BATTLE) or (rp==1-tp and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp))
end
-- 检索过滤函数，用于筛选「斩机」魔法·陷阱卡
function c15248594.thfilter(c)
	return c:IsSetCard(0x132) and c:IsAbleToHand() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 处理效果选择目标时的函数，用于检索满足条件的「斩机」魔法·陷阱卡
function c15248594.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足检索条件，即卡组中是否存在至少1张「斩机」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c15248594.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果操作信息，指定将要加入手卡的卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 处理效果发动时的检索操作，选择并把卡加入手卡
function c15248594.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示选择要加入手卡的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 从卡组中选择1张「斩机」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,c15248594.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因送入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认送入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
