--妖刀竹光
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：装备怪兽的攻击力上升0。
-- ②：以自己场上1张其他的「竹光」卡为对象才能发动。那张卡回到手卡，装备怪兽在这个回合可以直接攻击。
-- ③：这张卡被送去墓地的场合才能发动。从卡组把「妖刀竹光」以外的1张「竹光」卡加入手卡。
function c42199039.initial_effect(c)
	-- ①：装备怪兽的攻击力上升0。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c42199039.target)
	e1:SetOperation(c42199039.activate)
	c:RegisterEffect(e1)
	-- 装备怪兽（①中的“装备怪兽”限定了本卡只能装备给怪兽）
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ②：以自己场上1张其他的「竹光」卡为对象才能发动。那张卡回到手卡，装备怪兽在这个回合可以直接攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(42199039,0))  --"回到手卡"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,42199039)
	e3:SetTarget(c42199039.dttg)
	e3:SetOperation(c42199039.dtop)
	c:RegisterEffect(e3)
	-- ③：这张卡被送去墓地的场合才能发动。从卡组把「妖刀竹光」以外的1张「竹光」卡加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(42199039,1))  --"卡组检索"
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetTarget(c42199039.thtg)
	e4:SetOperation(c42199039.thop)
	c:RegisterEffect(e4)
end
-- 装备魔法发动时的目标选择：选择场上1只表侧表示怪兽作为此卡的装备对象。
function c42199039.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查场上是否存在1只以上表侧表示怪兽可以作为装备对象，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家提示选择要装备的卡（装备对象）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只表侧表示怪兽作为装备对象，并登记为当前连锁的对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：本连锁将对这张妖刀竹光进行装备处理，数量1。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理时，若此卡和选择的怪兽仍与效果关联且怪兽表侧表示，则将此卡装备给该怪兽。
function c42199039.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中选择的装备对象怪兽。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将此卡装备给对象怪兽。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 定义②的“其他的『竹光』卡”的过滤条件：表侧表示、属于『竹光』系列、可以加入手卡。
function c42199039.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x60) and c:IsAbleToHand()
end
-- ②的发动条件和目标选择：需要此卡处于装备状态且装备怪兽没有直接攻击效果，选择自己场上1张其他『竹光』卡为对象并返回手牌。
function c42199039.dttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c42199039.filter(chkc) and chkc~=e:GetHandler() end
	local eq=e:GetHandler():GetEquipTarget()
	-- 检查是否满足发动条件：存在装备怪兽、该怪兽不持有直接攻击效果、且场上存在可选择的『竹光』卡。
	if chk==0 then return eq and not eq:IsHasEffect(EFFECT_DIRECT_ATTACK) and Duel.IsExistingTarget(c42199039.filter,tp,LOCATION_ONFIELD,0,1,e:GetHandler()) end
	-- 向玩家提示选择要返回手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择自己场上1张其他的『竹光』卡作为效果对象。
	local g=Duel.SelectTarget(tp,c42199039.filter,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler())
	-- 设置操作信息：将对选择的对象卡执行回手牌操作，数量1。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②的效果处理：将对象卡返回手牌并展示；若返回成功，则给装备怪兽赋予本回合可直接攻击的效果。
function c42199039.dtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得②选择的对象卡。
	local tc=Duel.GetFirstTarget()
	-- 确认对象卡仍与效果关联、返回手牌成功且位于手牌中，才继续赋予直接攻击效果。
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) then
		-- 向对方玩家展示返回手牌的那张卡。
		Duel.ConfirmCards(1-tp,tc)
		local ec=c:GetEquipTarget()
		-- 装备怪兽在这个回合可以直接攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DIRECT_ATTACK)
		e1:SetCondition(c42199039.dircon)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		ec:RegisterEffect(e1)
	end
end
-- 直接攻击效果的条件：装备怪兽的控制者必须为此卡的原持有者。
function c42199039.dircon(e)
	return e:GetHandler():GetControler()==e:GetOwnerPlayer()
end
-- 定义③的检索过滤条件：卡名属于『竹光』系列、不是『妖刀竹光』自身、且可以加入手卡。
function c42199039.thfilter(c)
	return c:IsSetCard(0x60) and not c:IsCode(42199039) and c:IsAbleToHand()
end
-- ③的发动条件设定：检查卡组中是否存在符合条件的『竹光』卡，并设置从卡组检索到手的操作信息。
function c42199039.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在1张以上满足条件的『竹光』卡，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c42199039.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：将从卡组把1张『竹光』卡加入手牌（目标未确定，不取对象）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ③的效果处理：从卡组选1张符合条件的『竹光』卡加入手牌，并向对方展示。
function c42199039.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张符合条件的『竹光』卡。
	local g=Duel.SelectMatchingCard(tp,c42199039.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
