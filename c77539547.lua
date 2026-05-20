--戦華の美－周公
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1张永续魔法·永续陷阱卡为对象才能发动。那张卡送去墓地，从卡组把1张「战华」魔法·陷阱卡加入手卡。
-- ②：这张卡以外的自己的「战华」怪兽的效果发动的场合，以对方场上1只效果怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。
function c77539547.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：以自己场上1张永续魔法·永续陷阱卡为对象才能发动。那张卡送去墓地，从卡组把1张「战华」魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(77539547,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,77539547)
	e1:SetTarget(c77539547.thtg)
	e1:SetOperation(c77539547.thop)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次。②：这张卡以外的自己的「战华」怪兽的效果发动的场合，以对方场上1只效果怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(77539547,1))  --"怪兽无效"
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,77539548)
	e3:SetCondition(c77539547.discon)
	e3:SetTarget(c77539547.distg)
	e3:SetOperation(c77539547.disop)
	c:RegisterEffect(e3)
end
-- 过滤条件：自己场上表侧表示且可以送去墓地的永续魔法或永续陷阱卡
function c77539547.tgfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsType(TYPE_CONTINUOUS) and c:IsAbleToGrave()
end
-- 过滤条件：卡组中可以加入手牌的「战华」魔法或陷阱卡
function c77539547.thfilter(c)
	return c:IsSetCard(0x137) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果①的发动准备与目标选择
function c77539547.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c77539547.tgfilter(chkc) end
	-- 检查自己场上是否存在至少1张满足过滤条件的永续魔法或永续陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c77539547.tgfilter,tp,LOCATION_ONFIELD,0,1,nil)
		-- 并且检查卡组中是否存在至少1张可以加入手牌的「战华」魔法或陷阱卡
		and Duel.IsExistingMatchingCard(c77539547.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择自己场上1张满足过滤条件的永续魔法或永续陷阱卡作为效果对象
	local g=Duel.SelectTarget(tp,c77539547.tgfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 设置效果处理信息：将选中的对象卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
	-- 设置效果处理信息：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理（送去墓地并检索）
function c77539547.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的第一个对象卡
	local tc=Duel.GetFirstTarget()
	-- 若对象卡仍与效果相关，则将其因效果送去墓地，并确认其已成功送去墓地
	if tc:IsRelateToEffect(e) and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE) then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组中选择1张满足过滤条件的「战华」魔法或陷阱卡
		local g=Duel.SelectMatchingCard(tp,c77539547.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的卡因效果加入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方玩家展示加入手牌的卡
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- 效果②的发动条件：自己场上这张卡以外的「战华」怪兽的效果发动
function c77539547.discon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsSetCard(0x137) and rp==tp and re:GetHandler()~=e:GetHandler()
end
-- 效果②的发动准备与目标选择
function c77539547.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查作为对象的卡是否是对方场上表侧表示且未被无效的效果怪兽
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and aux.NegateEffectMonsterFilter(chkc) end
	-- 检查对方场上是否存在至少1只未被无效的效果怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要无效效果的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择对方场上1只未被无效的效果怪兽作为效果对象
	local g=Duel.SelectTarget(tp,aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息：使选中的怪兽效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 效果②的效果处理（无效对方怪兽效果）
function c77539547.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取在发动时选择的第一个对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e) then
		-- 使和该怪兽有关的连锁都无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那只怪兽的效果直到回合结束时无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 那只怪兽的效果直到回合结束时无效。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
