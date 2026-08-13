--雷源龍－サンダー・ドラゴン
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：自己·对方回合，把这张卡从手卡丢弃，以自己场上1只雷族怪兽为对象才能发动。那只怪兽的攻击力上升500。
-- ②：这张卡被除外的场合或者从场上送去墓地的场合才能发动。从卡组把1只「雷源龙-雷龙」加入手卡。
function c20318029.initial_effect(c)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。①：自己·对方回合，把这张卡从手卡丢弃，以自己场上1只雷族怪兽为对象才能发动。那只怪兽的攻击力上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20318029,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(TIMING_DAMAGE_STEP+TIMING_END_PHASE)
	e1:SetCountLimit(1,20318029)
	-- 设置效果的发动条件为伤害步骤限制：当前不是伤害步骤或尚未进行伤害计算，因此可以在伤害步骤内、伤害计算前发动，但不能在伤害计算时发动。
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
-- 定义①效果的发动代价：从手卡丢弃这张卡。该函数先检查这张卡是否可以被丢弃，可以则将其送去墓地作为代价。
function c20318029.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将这张卡从手卡送去墓地，丢弃原因标记为代价（REASON_COST）与丢弃（REASON_DISCARD）。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 定义效果对象的筛选条件：表侧表示且种族为雷族的怪兽。
function c20318029.atkfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_THUNDER)
end
-- 定义效果发动时的取对象处理：检查指定对象是否满足我方场上的表侧雷族怪兽；在正式发动时让玩家选择1只表侧雷族怪兽作为对象。
function c20318029.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c20318029.atkfilter(chkc) end
	-- 发动合法性检查：确认自己场上存在至少1只表侧表示雷族怪兽可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c20318029.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向操作玩家显示选择对象的提示，提示文字为“请选择效果的对象”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从自己场上选择1只满足条件的雷族怪兽，并设置为当前连锁的效果对象（取对象）。
	Duel.SelectTarget(tp,c20318029.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：获取对象卡；若对象仍与本次效果关联且为表侧表示，则为该对象附加攻击力上升500的效果。
function c20318029.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次连锁中第一个（也是唯一一个）效果对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只怪兽的攻击力上升500。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- 定义②效果中“从场上送去墓地”的追加条件：这张卡在送去墓地前位于场上（LOCATION_ONFIELD），用于区分不是从手卡或卡组送去墓地。
function c20318029.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 定义检索筛选条件：卡名为「雷源龙-雷龙」且可以加入手卡。
function c20318029.thfilter(c)
	return c:IsCode(20318029) and c:IsAbleToHand()
end
-- 定义②效果的发动目标检查与操作信息：确认卡组中存在符合条件的卡，并设置效果为从卡组检索加入手卡。
function c20318029.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：确认卡组中存在至少1张卡名是「雷源龙-雷龙」且可以加入手卡的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c20318029.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果为从卡组（LOCATION_DECK）将1张卡加入手卡（CATEGORY_TOHAND），供系统和其他卡的效果检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1张「雷源龙-雷龙」加入手卡，并向对方展示。
function c20318029.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向操作玩家显示从卡组选择要加入手卡的卡的提示，提示文字为“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足条件的「雷源龙-雷龙」作为加入手卡的卡。
	local g=Duel.SelectMatchingCard(tp,c20318029.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入其持有者的手卡，操作原因标记为效果（REASON_EFFECT）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认展示刚刚加入手卡的卡，以公开检索信息。
		Duel.ConfirmCards(1-tp,g)
	end
end
