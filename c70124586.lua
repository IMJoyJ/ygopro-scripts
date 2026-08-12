--ホールディング・レッグス
-- 效果：
-- ①：这张卡召唤·反转召唤·特殊召唤成功的场合发动。场上盖放的魔法·陷阱卡全部回到持有者手卡。
-- ②：把墓地的这张卡除外，以对方场上盖放的1张魔法·陷阱卡为对象才能发动。直到下个回合的结束时那张卡不能发动。
function c70124586.initial_effect(c)
	-- ①：这张卡召唤·反转召唤·特殊召唤成功的场合发动。场上盖放的魔法·陷阱卡全部回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(70124586,0))  --"回到手卡"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c70124586.thtg)
	e1:SetOperation(c70124586.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ②：把墓地的这张卡除外，以对方场上盖放的1张魔法·陷阱卡为对象才能发动。直到下个回合的结束时那张卡不能发动。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(70124586,1))  --"不能发动"
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	-- 将墓地的这张卡除外作为发动效果的代价
	e4:SetCost(aux.bfgcost)
	e4:SetTarget(c70124586.target)
	e4:SetOperation(c70124586.operation)
	c:RegisterEffect(e4)
end
-- ①号效果的发动准备：获取场上所有盖放的魔陷卡并设置送回手卡的操作信息
function c70124586.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return true end
	-- 获取双方魔陷区所有盖放的卡片
	local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,LOCATION_SZONE,LOCATION_SZONE,nil)
	-- 设置操作信息为将上述卡片送回手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- ①号效果的实际处理：将场上所有盖放的魔陷卡送回持有者手卡
function c70124586.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有盖放的魔陷卡
	local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,LOCATION_SZONE,LOCATION_SZONE,nil)
	-- 将这些卡片因效果送回持有者的手卡
	Duel.SendtoHand(g,nil,REASON_EFFECT)
end
-- ②号效果的发动准备：选择对方场上1张盖放的魔陷卡作为对象
function c70124586.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_SZONE) and chkc:IsFacedown() end
	-- 在发动阶段检测对方场上是否存在至少1张盖放的魔陷卡作为可选对象
	if chk==0 then return Duel.IsExistingTarget(Card.IsFacedown,tp,0,LOCATION_SZONE,1,nil) end
	-- 给玩家发送提示信息，要求选择里侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEDOWN)  --"请选择里侧表示的卡"
	-- 让玩家选择对方场上1张盖放的魔陷卡作为效果对象
	Duel.SelectTarget(tp,Card.IsFacedown,tp,0,LOCATION_SZONE,1,1,nil)
end
-- ②号效果的实际处理：使作为对象的卡片直到下个回合结束时不能发动
function c70124586.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() and tc:IsRelateToEffect(e) then
		-- 直到下个回合的结束时那张卡不能发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		tc:RegisterEffect(e1,true)
	end
end
