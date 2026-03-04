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
-- 效果作用：在通常召唤成功时触发，用于注册额外召唤次数效果。
function c13455953.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：检查是否已使用过额外召唤次数，避免重复使用。
	if Duel.GetFlagEffect(tp,13455953)~=0 then return end
	-- 效果作用：创建并注册一个影响场上的「极星」怪兽的额外召唤次数效果。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(13455953,1))  --"使用「极星灵 矮人」的效果召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	-- 效果作用：设置目标为名字带有「极星」的怪兽。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x42))
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 效果作用：将效果注册给玩家。
	Duel.RegisterEffect(e1,tp)
	-- 效果作用：为玩家注册一个标识效果，防止重复使用额外召唤次数。
	Duel.RegisterFlagEffect(tp,13455953,RESET_PHASE+PHASE_END,0,1)
end
-- 效果作用：判断场上的这张卡是否以正面表示状态被送去墓地。
function c13455953.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP)
end
-- 效果作用：过滤名字带有「极星宝」且能加入手牌的卡。
function c13455953.filter(c)
	return c:IsSetCard(0x5042) and c:IsAbleToHand()
end
-- 效果作用：设置选择目标时的处理逻辑。
function c13455953.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c13455953.filter(chkc) end
	if chk==0 then return true end
	-- 效果作用：提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 效果作用：选择满足条件的1张墓地中的「极星宝」卡作为目标。
	local g=Duel.SelectTarget(tp,c13455953.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 效果作用：设置连锁操作信息，表明将要执行回手牌的效果。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果作用：处理将目标卡加入手牌的操作。
function c13455953.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前连锁中被选择的目标卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 效果作用：将目标卡以效果原因送入手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 效果作用：向对方确认被送入手牌的卡。
		Duel.ConfirmCards(1-tp,tc)
	end
end
