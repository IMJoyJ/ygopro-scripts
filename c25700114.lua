--ダストンローラー
-- 效果：
-- 选择场上1只怪兽才能发动。这个回合，选择的怪兽不能解放，也不能作为融合·同调·超量召唤的素材。此外，盖放的这张卡被对方的卡的效果破坏送去墓地的场合，可以从卡组把1只名字带有「尘妖」的怪兽加入手卡。
function c25700114.initial_effect(c)
	-- 对应效果原文：『选择场上1只怪兽才能发动。这个回合，选择的怪兽不能解放，也不能作为融合·同调·超量召唤的素材。』
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c25700114.target)
	e1:SetOperation(c25700114.activate)
	c:RegisterEffect(e1)
	-- 对应效果原文：『此外，盖放的这张卡被对方的卡的效果破坏送去墓地的场合，可以从卡组把1只名字带有「尘妖」的怪兽加入手卡。』
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(25700114,0))  --"检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c25700114.thcon)
	e2:SetTarget(c25700114.thtg)
	e2:SetOperation(c25700114.thop)
	c:RegisterEffect(e2)
end
-- 效果发动的取对象处理：检查并选择场上1只怪兽作为对象。
function c25700114.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	-- 发动条件判定：双方场上主要怪兽区是否存在至少1只可选怪兽，若没有则不能发动。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 弹出提示消息，告知玩家正在选择效果对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从双方场上选择1只怪兽，并将其设为这张卡效果的对象。
	Duel.SelectTarget(tp,nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果处理：将对象怪兽附加不能解放、不能作为融合·同调·超量素材的持续效果（直到回合结束）。
function c25700114.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得这张卡效果选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 对应效果原文：『这个回合，选择的怪兽不能解放』（用EFFECT_UNRELEASABLE_SUM限制其不能作为上级召唤的祭品）。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UNRELEASABLE_SUM)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
		tc:RegisterEffect(e2)
		-- 对应效果原文：『也不能作为融合·同调·超量召唤的素材』（此处实现其中的不能作为融合素材限制，且仅对融合召唤生效）。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
		e3:SetValue(c25700114.fuslimit)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3)
		local e4=e3:Clone()
		e4:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
		e4:SetValue(1)
		tc:RegisterEffect(e4)
		local e5=e4:Clone()
		e5:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
		tc:RegisterEffect(e5)
	end
end
-- 判定是否禁止作为融合素材：当召唤类型为融合召唤时返回true，即该怪兽不能作为融合素材。
function c25700114.fuslimit(e,c,sumtype)
	return sumtype==SUMMON_TYPE_FUSION
end
-- 检索效果的发动条件：这张卡以里侧表示在场上存在时，被对方发动的卡的效果破坏并送去墓地，且此前由我方控制。
function c25700114.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and bit.band(r,0x41)==0x41 and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEDOWN)
end
-- 检索过滤条件：选择卡组中1张名含「尘妖」的怪兽卡，并且能够加入手卡。
function c25700114.filter(c)
	return c:IsSetCard(0x80) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 检索效果的发动时判定与操作信息设置：确认卡组有符合条件的「尘妖」怪兽，并宣告将进行‘从卡组加入手卡’的处理。
function c25700114.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时判定：我方卡组是否存在至少1张符合条件的「尘妖」怪兽，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c25700114.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果处理将把1张卡从卡组加入手卡，供其他卡进行连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索处理：从卡组选择1张「尘妖」怪兽加入手卡，并向对手展示。
function c25700114.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择要加入手卡的卡的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组筛选并选择1张符合条件的「尘妖」怪兽。
	local g=Duel.SelectMatchingCard(tp,c25700114.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入手卡（REASON_EFFECT表示是效果导致的移动）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方确认这次加入手卡的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
