--ダストンローラー
-- 效果：
-- 选择场上1只怪兽才能发动。这个回合，选择的怪兽不能解放，也不能作为融合·同调·超量召唤的素材。此外，盖放的这张卡被对方的卡的效果破坏送去墓地的场合，可以从卡组把1只名字带有「尘妖」的怪兽加入手卡。
function c25700114.initial_effect(c)
	-- 选择场上1只怪兽才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c25700114.target)
	e1:SetOperation(c25700114.activate)
	c:RegisterEffect(e1)
	-- 此外，盖放的这张卡被对方的卡的效果破坏送去墓地的场合，可以从卡组把1只名字带有「尘妖」的怪兽加入手卡。
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
-- 选择场上1只怪兽作为效果的对象。
function c25700114.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	-- 检查场上是否存在1只怪兽可以作为效果的对象。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择场上1只怪兽作为效果的对象。
	Duel.SelectTarget(tp,nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 处理效果的发动，使选择的怪兽在本回合不能解放，也不能作为融合·同调·超量召唤的素材。
function c25700114.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁效果选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 使选择的怪兽在本回合不能解放。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UNRELEASABLE_SUM)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
		tc:RegisterEffect(e2)
		-- 使选择的怪兽不能作为融合召唤的素材。
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
-- 融合召唤的素材限制函数。
function c25700114.fuslimit(e,c,sumtype)
	return sumtype==SUMMON_TYPE_FUSION
end
-- 判断是否为对方破坏并送去墓地的场合。
function c25700114.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and bit.band(r,0x41)==0x41 and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEDOWN)
end
-- 检索卡组中名字带有「尘妖」的怪兽的过滤函数。
function c25700114.filter(c)
	return c:IsSetCard(0x80) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 设置检索效果的处理信息。
function c25700114.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的卡片。
	if chk==0 then return Duel.IsExistingMatchingCard(c25700114.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置将要处理的卡牌数量和位置信息。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 处理检索效果，从卡组选择1只名字带有「尘妖」的怪兽加入手牌。
function c25700114.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1只名字带有「尘妖」的怪兽。
	local g=Duel.SelectMatchingCard(tp,c25700114.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡牌加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡牌。
		Duel.ConfirmCards(1-tp,g)
	end
end
