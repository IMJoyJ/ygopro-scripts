--雷源龍－サンダー・ドラゴン
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：自己·对方回合，把这张卡从手卡丢弃，以自己场上1只雷族怪兽为对象才能发动。那只怪兽的攻击力上升500。
-- ②：这张卡被除外的场合或者从场上送去墓地的场合才能发动。从卡组把1只「雷源龙-雷龙」加入手卡。
function c20318029.initial_effect(c)
	-- ①：自己·对方回合，把这张卡从手卡丢弃，以自己场上1只雷族怪兽为对象才能发动。那只怪兽的攻击力上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20318029,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(TIMING_DAMAGE_STEP+TIMING_END_PHASE)
	e1:SetCountLimit(1,20318029)
	-- 限制效果只能在伤害计算前的时机发动或适用
	e1:SetCondition(aux.dscon)
	e1:SetCost(c20318029.atkcost)
	e1:SetTarget(c20318029.atktg)
	e1:SetOperation(c20318029.atkop)
	c:RegisterEffect(e1)
	c20318029.discard_effect=e1
	-- ②：这张卡被除外的场合或者从场上送去墓地的场合才能发动。从卡组把1只「雷源龙-雷龙」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(20318029,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,20318029)
	e2:SetTarget(c20318029.thtg)
	e2:SetOperation(c20318029.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c20318029.thcon)
	c:RegisterEffect(e3)
end
-- 将此卡从手卡丢弃作为费用
function c20318029.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将此卡从手卡丢弃作为费用
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 过滤出场上正面表示的雷族怪兽
function c20318029.atkfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_THUNDER)
end
-- 选择场上正面表示的雷族怪兽作为效果对象
function c20318029.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c20318029.atkfilter(chkc) end
	-- 检查场上是否存在正面表示的雷族怪兽
	if chk==0 then return Duel.IsExistingTarget(c20318029.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择场上正面表示的雷族怪兽作为效果对象
	Duel.SelectTarget(tp,c20318029.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 使选中的雷族怪兽攻击力上升500
function c20318029.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 使对象怪兽攻击力上升500
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- 判断此卡是否从场上离开
function c20318029.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤出卡组中可加入手牌的雷源龙-雷龙
function c20318029.thfilter(c)
	return c:IsCode(20318029) and c:IsAbleToHand()
end
-- 检索卡组中的雷源龙-雷龙加入手牌
function c20318029.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在雷源龙-雷龙
	if chk==0 then return Duel.IsExistingMatchingCard(c20318029.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理时要加入手牌的卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 从卡组检索雷源龙-雷龙加入手牌
function c20318029.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择一张雷源龙-雷龙加入手牌
	local g=Duel.SelectMatchingCard(tp,c20318029.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
