--極星霊ドヴェルグ
-- 效果：
-- 这张卡召唤成功的回合，自己在通常召唤外加上只有1次可以把1只名字带有「极星」的怪兽召唤。场上表侧表示存在的这张卡被送去墓地时，从自己墓地选择1张名字带有「极星宝」的卡加入手卡。
function c13455953.initial_effect(c)
	-- 这张卡召唤成功的回合，自己在通常召唤外加上只有1次可以把1只名字带有「极星」的怪兽召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetOperation(c13455953.sumop)
	c:RegisterEffect(e1)
	-- 场上表侧表示存在的这张卡被送去墓地时，从自己墓地选择1张名字带有「极星宝」的卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(13455953,0))  --"加入手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c13455953.thcon)
	e2:SetTarget(c13455953.thtg)
	e2:SetOperation(c13455953.thop)
	c:RegisterEffect(e2)
end
-- 召唤成功时，若本回合尚未使用过该追加召唤效果，则为玩家tp赋予一个持续到结束阶段的追加召唤效果，使之在通常召唤外还可以把1只名字带有「极星」的怪兽通常召唤，并记录已发动标志，避免重复发动。
function c13455953.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家tp是否已有本回合使用过该效果的标志（13455953），若已有则直接结束该操作，保证额外召唤次数只处理一次。
	if Duel.GetFlagEffect(tp,13455953)~=0 then return end
	-- 这张卡召唤成功的回合，自己在通常召唤外加上只有1次可以把1只名字带有「极星」的怪兽召唤。场上表侧表示存在的这张卡被送去墓地时，从自己墓地选择1张名字带有「极星宝」的卡加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(13455953,1))  --"使用「极星灵 矮人」的效果召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	-- 设置追加召唤效果的适用目标：只有名字带有「极星」字段（0x42）的怪兽才能享受这次追加召唤次数。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x42))
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将追加召唤效果e1注册到玩家tp身上，使tp的手牌/场上符合条件（「极星」怪兽）的卡获得1次额外的通常召唤次数。
	Duel.RegisterEffect(e1,tp)
	-- 为玩家tp注册一个本回合的标识效果（13455953），并在结束阶段重置，用来标记本回合已经使用过“极星灵 矮人”的追加召唤效果。
	Duel.RegisterFlagEffect(tp,13455953,RESET_PHASE+PHASE_END,0,1)
end
-- 墓地诱发效果的发动条件：这张卡在被送去墓地之前是场上表侧表示存在，满足“场上表侧表示存在的这张卡被送去墓地时”的触发时机。
function c13455953.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP)
end
-- 定义墓地可选卡片的过滤条件：拥有「极星宝」字段（0x5042），并且能够被加入手牌。
function c13455953.filter(c)
	return c:IsSetCard(0x5042) and c:IsAbleToHand()
end
-- 回手牌效果的目标选择处理：选择自己墓地1张符合条件的「极星宝」卡作为对象，并设置本次连锁将执行加入手牌的操作信息。
function c13455953.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c13455953.filter(chkc) end
	if chk==0 then return true end
	-- 在玩家选择卡片前给出提示信息，提示文字为“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家tp从自己墓地选择1张符合c13455953.filter条件的卡，并将其设为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,c13455953.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息，声明本次效果将把对象卡加入手牌（CATEGORY_TOHAND），用于后续时点/其他效果的连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 回手牌效果的处理：取得对象卡，若其仍与本效果关联，则将其加入手牌，并让对方确认加入手牌的卡。
function c13455953.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得这个效果发动时选择的那一张对象卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将对象卡因效果（REASON_EFFECT）送入其持有者的手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 让对手（1-tp）确认这张加入手牌的卡，符合“从自己墓地选择……加入手卡”的公开确认要求。
		Duel.ConfirmCards(1-tp,tc)
	end
end
