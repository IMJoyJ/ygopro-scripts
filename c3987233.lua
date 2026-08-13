--ミセス・レディエント
-- 效果：
-- 地属性怪兽2只
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：场上的地属性怪兽的攻击力·守备力上升500，风属性怪兽的攻击力·守备力下降400。
-- ②：这张卡被战斗·效果破坏的场合，以自己墓地1只地属性怪兽为对象才能发动。那只怪兽加入手卡。
function c3987233.initial_effect(c)
	-- 为这张卡添加连接召唤手续：以2只地属性连接怪兽作为连接素材进行连接召唤。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkAttribute,ATTRIBUTE_EARTH),2,2)
	c:EnableReviveLimit()
	-- ①：场上的地属性怪兽的攻击力·守备力上升500
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	-- 将该永续效果的影响对象限定为场上的地属性怪兽，即只有地属性怪兽会受到攻击力上升效果。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsAttribute,ATTRIBUTE_EARTH))
	e1:SetValue(500)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	-- 将攻击力下降效果的影响对象限定为场上的风属性怪兽。
	e3:SetTarget(aux.TargetBoolFunction(Card.IsAttribute,ATTRIBUTE_WIND))
	e3:SetValue(-400)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡被战斗·效果破坏的场合，以自己墓地1只地属性怪兽为对象才能发动。那只怪兽加入手卡。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(3987233,0))
	e5:SetCategory(CATEGORY_TOHAND)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetCountLimit(1,3987233)
	e5:SetCondition(c3987233.thcon)
	e5:SetTarget(c3987233.thtg)
	e5:SetOperation(c3987233.thop)
	c:RegisterEffect(e5)
end
-- 效果发动条件：这张卡被战斗或效果破坏的场合才能发动（通过检查破坏理由中含有战斗破坏或效果破坏）。
function c3987233.thcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
-- 对象选择过滤器：必须是墓地中的地属性怪兽，并且可以被加入手卡。
function c3987233.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsAbleToHand()
end
-- 取对象处理：检查是否存在合法对象，若有则提示玩家选择自己墓地1只地属性地属性怪兽作为对象，并登记回手牌的操作信息。
function c3987233.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c3987233.thfilter(chkc) end
	-- 发动合法性检查阶段：确认自己墓地存在至少1只可以成为对象的地属性怪兽。
	if chk==0 then return Duel.IsExistingTarget(c3987233.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 弹出选择提示，提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地的满足条件的怪兽中选择1张作为效果对象，并将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c3987233.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置当前连锁的操作信息：效果类别为回手牌，对象为选中的怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理：取得对象卡，若对象仍与效果关联，则将其加入手卡。
function c3987233.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本次效果处理的对象卡（即选择的那1张墓地怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将被选择的怪兽加入其持有者的手卡（nil表示回持有者手卡），处理原因为效果。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
