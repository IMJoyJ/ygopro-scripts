--スクラップ・ラプター
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1只怪兽为对象才能发动。那只怪兽破坏。这个回合，自己在通常召唤外加上只有1次，自己主要阶段可以把1只「废铁」怪兽召唤。
-- ②：这张卡被「废铁」卡的效果破坏送去墓地的场合才能发动。从卡组把1张「废铁工厂」或者1只调整以外的「废铁」怪兽加入手卡。
function c80529459.initial_effect(c)
	-- 记录该卡卡名记有「废铁工厂」
	aux.AddCodeList(c,28388296)
	-- ①：以自己场上1只怪兽为对象才能发动。那只怪兽破坏。这个回合，自己在通常召唤外加上只有1次，自己主要阶段可以把1只「废铁」怪兽召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(80529459,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,80529459)
	e1:SetTarget(c80529459.destg)
	e1:SetOperation(c80529459.desop)
	c:RegisterEffect(e1)
	-- ②：这张卡被「废铁」卡的效果破坏送去墓地的场合才能发动。从卡组把1张「废铁工厂」或者1只调整以外的「废铁」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(80529459,1))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,80529460)
	e2:SetCondition(c80529459.thcon)
	e2:SetTarget(c80529459.thtg)
	e2:SetOperation(c80529459.thop)
	c:RegisterEffect(e2)
end
-- ①效果的发动准备（检查自己场上是否有怪兽可作为对象，以及是否能进行通常召唤和追加召唤）
function c80529459.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) end
	-- 检查自己场上是否存在可以作为对象破坏的怪兽
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_MZONE,0,1,nil)
		-- 检查玩家是否可以进行通常召唤以及是否还有追加召唤的次数
		and Duel.IsPlayerCanSummon(tp) and Duel.IsPlayerCanAdditionalSummon(tp) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上1只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置破坏操作的信息，包含被选择的对象怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ①效果的处理（破坏对象怪兽，并赋予本回合追加召唤「废铁」怪兽的效果）
function c80529459.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽因效果破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
	-- 检查玩家是否能召唤、是否有追加召唤次数，且本回合尚未适用过此追加召唤效果
	if Duel.IsPlayerCanSummon(tp) and Duel.IsPlayerCanAdditionalSummon(tp) and Duel.GetFlagEffect(tp,80529459)==0 then
		-- 这个回合，自己在通常召唤外加上只有1次，自己主要阶段可以把1只「废铁」怪兽召唤。②：这张卡被「废铁」卡的效果破坏送去墓地的场合才能发动。从卡组把1张「废铁工厂」或者1只调整以外的「废铁」怪兽加入手卡。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(80529459,2))  --"使用「废铁盗龙」的效果召唤"
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
		e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
		-- 设置追加召唤的怪兽必须是「废铁」怪兽
		e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x24))
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 给玩家注册该追加召唤的效果
		Duel.RegisterEffect(e1,tp)
		-- 为玩家注册本回合已适用该追加召唤效果的标记
		Duel.RegisterFlagEffect(tp,80529459,RESET_PHASE+PHASE_END,0,1)
	end
end
-- ②效果的发动条件（这张卡被「废铁」卡的效果破坏送去墓地）
function c80529459.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return re and re:GetHandler():IsSetCard(0x24) and c:IsReason(REASON_EFFECT) and c:IsReason(REASON_DESTROY)
end
-- 检索卡片的过滤条件（「废铁工厂」或者调整以外的「废铁」怪兽）
function c80529459.thfilter(c)
	return (c:IsCode(28388296) or not c:IsType(TYPE_TUNER) and c:IsSetCard(0x24) and c:IsType(TYPE_MONSTER)) and c:IsAbleToHand()
end
-- ②效果的发动准备（检查卡组中是否存在符合条件的卡，并设置检索操作信息）
function c80529459.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在符合检索条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c80529459.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置将卡组中的卡加入手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果的处理（从卡组选择1张符合条件的卡加入手牌并给对方确认）
function c80529459.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张符合检索条件的卡
	local g=Duel.SelectMatchingCard(tp,c80529459.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡因效果加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
