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
-- 作为①的代价过滤器：判断墓地中的卡是否为「海晶少女」陷阱卡、能否作为代价除外，并且卡组中存在至少1张卡名不同的可加入手卡的「海晶少女」陷阱卡。
function c33945211.costfilter(c,tp)
	return c:IsSetCard(0x12b) and c:IsType(TYPE_TRAP) and c:IsAbleToRemoveAsCost()
		-- 额外检查卡组中是否有与该墓地陷阱卡卡名不同的「海晶少女」陷阱卡可加入手卡，以保证检索目标存在。
		and Duel.IsExistingMatchingCard(c33945211.srfilter,tp,LOCATION_DECK,0,1,nil,c:GetCode())
end
-- 检索目标过滤器：满足「海晶少女」陷阱卡、与除外的那张卡卡名不同，并且可以加入手卡。
function c33945211.srfilter(c,code)
	return c:IsSetCard(0x12b) and c:IsType(TYPE_TRAP) and not c:IsCode(code) and c:IsAbleToHand()
end
-- ①效果的代价处理：从自己墓地选择1张符合条件的「海晶少女」陷阱卡，记录其卡号后将其表侧除外作为发动代价，后续检索时排除同名卡。
function c33945211.srcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测：确认自己墓地存在至少1张可作为代价的「海晶少女」陷阱卡且卡组中有可检索的对应目标。
	if chk==0 then return Duel.IsExistingMatchingCard(c33945211.costfilter,tp,LOCATION_GRAVE,0,1,nil,tp) end
	-- 显示提示，让玩家选择要从墓地除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1张符合条件的「海晶少女」陷阱卡作为代价卡。
	local tc=Duel.SelectMatchingCard(tp,c33945211.costfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
	e:SetLabel(tc:GetCode())
	-- 将选中的墓地陷阱卡表侧表示除外，支付发动代价。
	Duel.Remove(tc,POS_FACEUP,REASON_COST)
end
-- ①效果的发动目标：无特殊发动条件，同时设置操作信息，表示后续会从卡组把1张卡加入手卡。
function c33945211.srtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：效果处理时将执行从卡组加入1张手卡的操作（CATEGORY_TOHAND），供连锁与相关效果检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：根据代价除外的那张卡的卡名，从卡组选择1张卡名不同的「海晶少女」陷阱卡加入手卡，并向对方展示。
function c33945211.srop(e,tp,eg,ep,ev,re,r,rp)
	local code=e:GetLabel()
	-- 显示提示，让玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张与除外卡卡名不同的「海晶少女」陷阱卡作为加入手卡的对象。
	local g=Duel.SelectMatchingCard(tp,c33945211.srfilter,tp,LOCATION_DECK,0,1,1,nil,code)
	if g:GetCount()>0 then
		-- 将检索到的卡加入持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示本次检索加入手卡的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 代替破坏的过滤条件：被破坏的怪兽必须在自己场上且位于怪兽区域，破坏原因是效果破坏，并且不是由代替破坏造成的破坏。
function c33945211.repfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
		and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- ②效果的发动判定：当自己场上的怪兽将被效果破坏时，判断墓地这张卡能否除外并询问玩家是否使用代替破坏；若选择是，则除外自身并允许代替。
function c33945211.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(c33945211.repfilter,1,nil,tp) end
	-- 询问玩家是否发动②效果，用墓地这张卡代替怪兽被效果破坏。
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		-- 将墓地的这张卡除外，执行代替破坏的替代处理。
		Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
		return true
	else return false end
end
-- 代替破坏判定值函数：判断将被破坏的怪兽是否为满足条件的己方效果破坏怪兽，供EFFECT_DESTROY_REPLACE调用。
function c33945211.repval(e,c)
	return c33945211.repfilter(c,e:GetHandlerPlayer())
end
-- ③效果的发动条件与取对象：这张卡被除外时，可以选择自己场上1只表侧表示怪兽为对象；此函数负责检查合法对象并选择对象。
function c33945211.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 发动条件检测：确认自己场上存在至少1只表侧表示怪兽可作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	-- 显示提示，让玩家选择要上升攻击力的对象怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只表侧表示怪兽作为效果的对象，并登记到当前连锁。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ③效果处理：如果对象怪兽仍在场上且表侧表示，则给它装备一个攻击力上升600的效果。
function c33945211.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果处理的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只怪兽的攻击力上升600。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(600)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
