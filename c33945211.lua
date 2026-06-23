--海晶乙女バシランリマ
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：从自己墓地把1张「海晶少女」陷阱卡除外才能发动。和那张卡卡名不同的1张「海晶少女」陷阱卡从卡组加入手卡。
-- ②：自己场上的怪兽被效果破坏的场合，可以作为代替把墓地的这张卡除外。
-- ③：这张卡被除外的场合，以自己场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力上升600。
function c33945211.initial_effect(c)
	-- ①：从自己墓地把1张「海晶少女」陷阱卡除外才能发动。和那张卡卡名不同的1张「海晶少女」陷阱卡从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(33945211,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,33945211)
	e1:SetCost(c33945211.srcost)
	e1:SetTarget(c33945211.srtg)
	e1:SetOperation(c33945211.srop)
	c:RegisterEffect(e1)
	-- ②：自己场上的怪兽被效果破坏的场合，可以作为代替把墓地的这张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTarget(c33945211.reptg)
	e2:SetValue(c33945211.repval)
	c:RegisterEffect(e2)
	-- ③：这张卡被除外的场合，以自己场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力上升600。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(33945211,1))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_REMOVE)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,33945212)
	e3:SetTarget(c33945211.atktg)
	e3:SetOperation(c33945211.atkop)
	c:RegisterEffect(e3)
end
-- 过滤函数，检查墓地是否存在满足条件的「海晶少女」陷阱卡并确保卡组中存在不同名的「海晶少女」陷阱卡
function c33945211.costfilter(c,tp)
	return c:IsSetCard(0x12b) and c:IsType(TYPE_TRAP) and c:IsAbleToRemoveAsCost()
		-- 检查卡组中是否存在与除外卡不同名的「海晶少女」陷阱卡
		and Duel.IsExistingMatchingCard(c33945211.srfilter,tp,LOCATION_DECK,0,1,nil,c:GetCode())
end
-- 过滤函数，用于检索卡组中满足条件的「海晶少女」陷阱卡
function c33945211.srfilter(c,code)
	return c:IsSetCard(0x12b) and c:IsType(TYPE_TRAP) and not c:IsCode(code) and c:IsAbleToHand()
end
-- 发动效果时，从墓地选择一张「海晶少女」陷阱卡除外作为费用
function c33945211.srcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件，即墓地存在满足条件的「海晶少女」陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c33945211.costfilter,tp,LOCATION_GRAVE,0,1,nil,tp) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择一张满足条件的卡并获取其引用
	local tc=Duel.SelectMatchingCard(tp,c33945211.costfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
	e:SetLabel(tc:GetCode())
	-- 将选中的卡从墓地除外作为发动效果的费用
	Duel.Remove(tc,POS_FACEUP,REASON_COST)
end
-- 设置效果处理时的操作信息，准备从卡组检索卡牌
function c33945211.srtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示将从卡组检索一张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，选择一张卡组中的「海晶少女」陷阱卡加入手牌
function c33945211.srop(e,tp,eg,ep,ev,re,r,rp)
	local code=e:GetLabel()
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择一张满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c33945211.srfilter,tp,LOCATION_DECK,0,1,1,nil,code)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤函数，用于判断是否为被效果破坏且未被代替破坏的场上怪兽
function c33945211.repfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
		and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- 代替破坏效果的处理函数，判断是否发动效果并除外自身
function c33945211.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(c33945211.repfilter,1,nil,tp) end
	-- 询问玩家是否发动效果
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		-- 将自身从墓地除外
		Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
		return true
	else return false end
end
-- 返回代替破坏的条件，即是否为场上被效果破坏的怪兽
function c33945211.repval(e,c)
	return c33945211.repfilter(c,e:GetHandlerPlayer())
end
-- 设置效果处理时的目标选择，选择一只表侧表示的怪兽
function c33945211.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 检查是否满足发动条件，即场上是否存在表侧表示的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择一只表侧表示的怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理函数，使目标怪兽攻击力上升600
function c33945211.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 创建攻击力上升600的效果并注册到目标怪兽上
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(600)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
