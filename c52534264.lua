--第弐次未界域探険隊
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：丢弃1张手卡，以自己场上1只「未界域」怪兽为对象才能发动。那只怪兽的攻击力·守备力直到回合结束时上升500。
-- ②：这张卡在墓地存在的场合，从手卡丢弃1只「未界域」怪兽才能发动。这张卡回到卡组最下面。那之后，自己从卡组抽1张。
function c52534264.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次。①：丢弃1张手卡，以自己场上1只「未界域」怪兽为对象才能发动。那只怪兽的攻击力·守备力直到回合结束时上升500。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetDescription(aux.Stringid(52534264,0))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置效果发动条件：不在伤害步骤或尚未进行伤害计算时才能发动，即允许在伤害步骤的伤害计算前发动。
	e2:SetCondition(aux.dscon)
	e2:SetCost(c52534264.atkcost)
	e2:SetTarget(c52534264.atktg)
	e2:SetOperation(c52534264.atkop)
	c:RegisterEffect(e2)
	-- 这个卡名的①②的效果1回合各能使用1次。②：这张卡在墓地存在的场合，从手卡丢弃1只「未界域」怪兽才能发动。这张卡回到卡组最下面。那之后，自己从卡组抽1张。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e3:SetDescription(aux.Stringid(52534264,1))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,52534264)
	e3:SetCost(c52534264.tdcost)
	e3:SetTarget(c52534264.tdtg)
	e3:SetOperation(c52534264.tdop)
	c:RegisterEffect(e3)
end
-- 定义①效果对象筛选条件：选择自己场上表侧表示且属于「未界域」系列的怪兽。
function c52534264.filter1(c)
	return c:IsFaceup() and c:IsSetCard(0x11e)
end
-- 定义①效果发动代价：丢弃1张手卡。先检查手牌是否有可丢弃的卡，执行时丢弃1张手卡，代价原因含REASON_COST和REASON_DISCARD。
function c52534264.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价合法性检查：确认手牌中存在至少1张可以丢弃的手卡（排除此卡自身），有才能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 实际支付代价：从手牌选择并丢弃1张手卡，丢弃原因视为代价丢弃。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 定义①效果的目标函数：使用flag确保本回合未发动过此卡名①效果；选择自己场上1只表侧表示的「未界域」怪兽为对象。同时处理对象合法性确认（chkc分支）。
function c52534264.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	if chk==0 then return e:GetHandler():GetFlagEffect(52534264)==0
		-- 确认场上存在满足条件的「未界域」怪兽可以成为对象，且①效果在本回合尚未使用（flag为0）。
		and Duel.IsExistingTarget(c52534264.filter1,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 向玩家发出“请选择效果的对象”的提示消息，作为选对象时的界面提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家选择1只符合条件的「未界域」怪兽，并将其设为效果对象（与当前连锁建立联系）。
	Duel.SelectTarget(tp,c52534264.filter1,tp,LOCATION_MZONE,0,1,1,nil)
	e:GetHandler():RegisterFlagEffect(52534264,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 定义①效果处理：取得对象怪兽，若仍与效果关联且表侧表示，则使其攻击力和守备力直到回合结束时各上升500（分别注册增减攻击/守备的效果）。
function c52534264.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的对象卡片（本效果只选1只，所以取首张）。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只怪兽的攻击力·守备力直到回合结束时上升500。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
	end
end
-- 定义②效果代价的筛选条件：手卡中1只属于「未界域」系列、是怪兽且可以丢弃的卡。
function c52534264.costfilter(c)
	return c:IsSetCard(0x11e) and c:IsType(TYPE_MONSTER) and c:IsDiscardable()
end
-- 定义②效果发动代价：从手卡丢弃1只「未界域」怪兽。检查阶段确认手牌有符合条件者，执行时丢弃1只。
function c52534264.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价合法性检查：确认手牌中存在至少1只符合条件的「未界域」怪兽可供丢弃。
	if chk==0 then return Duel.IsExistingMatchingCard(c52534264.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 实际支付②效果代价：从手牌选择并丢弃1只「未界域」怪兽，原因设为代价丢弃。
	Duel.DiscardHand(tp,c52534264.costfilter,1,1,REASON_COST+REASON_DISCARD,nil)
end
-- 定义②效果的发动条件与操作信息：确认本卡在墓地且能回卡组、自己可以抽卡；随后登记回卡组与抽卡的操作信息。
function c52534264.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：这张卡在墓地且能够回到卡组，并且自己当前可以抽1张卡（未被禁止抽卡）。
	if chk==0 then return e:GetHandler():IsAbleToDeck() and Duel.IsPlayerCanDraw(tp,1) end
	-- 登记本次连锁处理信息：将这张卡自身送回卡组（数量1），供其他卡效果进行连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
	-- 登记本次连锁处理信息：自己抽1张卡，目标卡未知（nil），数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 定义②效果处理：若这张卡仍与效果关联，先将其送回卡组最下面；若回卡组成功且位于卡组，则中断效果后自己抽1张卡。
function c52534264.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果处理前检查：这张卡仍与效果关联，且将其送回卡组最下面操作成功（返回值≠0）并位于卡组中，才继续抽卡。
	if c:IsRelateToEffect(e) and Duel.SendtoDeck(c,nil,SEQ_DECKBOTTOM,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_DECK) then
		-- 中断当前效果处理，使回卡组与抽卡被视为不同时处理（错开时点），让玩家可以响应抽卡前的时点。
		Duel.BreakEffect()
		-- 效果处理：让自己从卡组抽1张卡。
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
