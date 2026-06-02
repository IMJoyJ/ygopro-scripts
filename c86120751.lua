--召喚師アレイスター
-- 效果：
-- ①：自己·对方回合，把这张卡从手卡送去墓地，以自己场上1只融合怪兽为对象才能发动。那只怪兽的攻击力·守备力直到回合结束时上升1000。
-- ②：这张卡召唤·反转的场合才能发动。从卡组把1张「召唤魔术」加入手卡。
function c86120751.initial_effect(c)
	-- 将「召唤魔术」卡片密码（74063034）添加到该卡的关系代码列表中，以在规则层面表明该卡上记载了其卡名。
	aux.AddCodeList(c,74063034)
	-- ①：自己·对方回合，把这张卡从手卡送去墓地，以自己场上1只融合怪兽为对象才能发动。那只怪兽的攻击力·守备力直到回合结束时上升1000。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(86120751,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+TIMINGS_CHECK_MONSTER)
	-- 设置效果发动的限制条件：可以在伤害步骤发动，但通过dscon限制其不能在伤害计算后发动。
	e1:SetCondition(aux.dscon)
	e1:SetCost(c86120751.adcost)
	e1:SetTarget(c86120751.adtg)
	e1:SetOperation(c86120751.adop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·反转的场合才能发动。从卡组把1张「召唤魔术」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(86120751,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(c86120751.thtg)
	e2:SetOperation(c86120751.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_FLIP)
	c:RegisterEffect(e3)
end
-- 效果①的支付代价：检查并把手牌中的这张卡送去墓地。
function c86120751.adcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将作为代价的该卡送去墓地。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤条件：场上表侧表示的融合怪兽。
function c86120751.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION)
end
-- 效果①的发动准备：判断并选择自己场上的1只表侧表示融合怪兽作为效果的对象。
function c86120751.adtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c86120751.filter(chkc) end
	-- 检查自己场上是否存在可以作为对象的表侧表示融合怪兽。
	if chk==0 then return Duel.IsExistingTarget(c86120751.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家发送提示消息，提示选择表侧表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上的1只表侧表示融合怪兽作为效果对象。
	Duel.SelectTarget(tp,c86120751.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果①的效果处理：让选中的融合怪兽直到回合结束时攻击力和守备力上升1000。
function c86120751.adop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果①的指定对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 那只怪兽的攻击力直到回合结束时上升1000。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
	end
end
-- 过滤条件：从卡组检索卡名是「召唤魔术」（74063034）且能加入手牌的卡。
function c86120751.thfilter(c)
	return c:IsCode(74063034) and c:IsAbleToHand()
end
-- 效果②的发动准备：检查卡组中是否存在可以检索的「召唤魔术」，并设置加入手牌的操作信息。
function c86120751.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在「召唤魔术」卡片。
	if chk==0 then return Duel.IsExistingMatchingCard(c86120751.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：将卡组中的1张卡加入玩家手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的效果处理：从卡组中取得1张「召唤魔术」加入手牌，并向对方确认。
function c86120751.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 从卡组中获取第1张符合过滤条件的「召唤魔术」卡片。
	local tc=Duel.GetFirstMatchingCard(c86120751.thfilter,tp,LOCATION_DECK,0,nil)
	if tc then
		-- 将检索到的卡片加入玩家手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家展示并确认加入手牌的卡片。
		Duel.ConfirmCards(1-tp,tc)
	end
end
