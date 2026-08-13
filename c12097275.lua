--剛鬼ハッグベア
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤或者用「刚鬼」卡的效果特殊召唤成功的场合，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时变成原本攻击力的一半。
-- ②：这张卡从场上送去墓地的场合才能发动。从卡组把「刚鬼 熊抱熊精」以外的1张「刚鬼」卡加入手卡。
function c12097275.initial_effect(c)
	-- ①：这张卡召唤或者用「刚鬼」卡的效果特殊召唤成功的场合，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时变成原本攻击力的一半。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetDescription(aux.Stringid(12097275,0))
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,12097275)
	e1:SetTarget(c12097275.atktg)
	e1:SetOperation(c12097275.atkop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c12097275.atkcon)
	c:RegisterEffect(e2)
	-- ②：这张卡从场上送去墓地的场合才能发动。从卡组把「刚鬼 熊抱熊精」以外的1张「刚鬼」卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(12097275,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,12097276)
	e3:SetCondition(c12097275.thcon)
	e3:SetTarget(c12097275.thtg)
	e3:SetOperation(c12097275.thop)
	c:RegisterEffect(e3)
end
-- ①效果的发动条件与取对象处理：选择对方场上1只攻击力不为0的表侧表示怪兽作为对象，若不存在合法对象则不能发动。
function c12097275.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 连锁处理时判定候选对象是否合法：必须是对方场上的表侧表示怪兽且攻击力不为0。
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and aux.nzatk(chkc) end
	-- 发动时检查是否存在至少1只对方场上的表侧表示且攻击力不为0的怪兽可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(aux.nzatk,tp,0,LOCATION_MZONE,1,nil) end
	-- 显示选择表侧表示怪兽的提示信息，引导玩家进行选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 从对方场上的表侧表示且攻击力不为0的怪兽中选择1只作为效果对象。
	Duel.SelectTarget(tp,aux.nzatk,tp,0,LOCATION_MZONE,1,1,nil)
end
-- ①效果处理：若对象怪兽仍表侧表示且与效果关联，则将其攻击力变成原本攻击力的一半直到回合结束。
function c12097275.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得①效果选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽的攻击力直到回合结束时变成原本攻击力的一半。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(math.ceil(tc:GetBaseAttack()/2))
		tc:RegisterEffect(e1)
	end
end
-- 此条件用于区分用「刚鬼」卡的效果特殊召唤成功的场合（e2的追加条件），与召唤成功时共用同一套效果处理。
function c12097275.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSpecialSummonSetCard(0xfc)
end
-- ②效果的发动条件：这张卡从场上（怪兽区域或魔陷区域）被送去墓地的场合才能发动。
function c12097275.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 检索过滤条件：卡组中满足「刚鬼」字段、不是「刚鬼 熊抱熊精」自身且能够加入手卡的卡。
function c12097275.thfilter(c)
	return c:IsSetCard(0xfc) and not c:IsCode(12097275) and c:IsAbleToHand()
end
-- ②效果发动时的目标判定：确认卡组存在符合条件的「刚鬼」卡，并向系统宣告本次操作会加入手卡。
function c12097275.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断卡组中是否存在至少1张符合条件的「刚鬼」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c12097275.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果处理会将1张卡从卡组加入手卡，用于后续连锁检测与效果抵消判定。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：从卡组选1张符合条件的「刚鬼」卡加入手卡，并让对方确认。
function c12097275.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择要加入手牌的卡的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组筛选并选择1张符合条件的「刚鬼」卡。
	local g=Duel.SelectMatchingCard(tp,c12097275.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入其持有者的手卡，原因记为效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对手确认加入手卡的那张卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
