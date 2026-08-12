--マスター・ボーイ
-- 效果：
-- 水属性怪兽2只
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：场上的水属性怪兽的攻击力·守备力上升500，炎属性怪兽的攻击力·守备力下降400。
-- ②：这张卡被战斗·效果破坏的场合，以自己墓地1只水属性怪兽为对象才能发动。那只怪兽加入手卡。
function c65170459.initial_effect(c)
	-- 设置连接召唤手续：水属性怪兽2只
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkAttribute,ATTRIBUTE_WATER),2,2)
	c:EnableReviveLimit()
	-- ①：场上的水属性怪兽的攻击力·守备力上升500
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	-- 设置效果影响的对象为场上的水属性怪兽
	e1:SetTarget(aux.TargetBoolFunction(Card.IsAttribute,ATTRIBUTE_WATER))
	e1:SetValue(500)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	-- 设置效果影响的对象为场上的炎属性怪兽
	e3:SetTarget(aux.TargetBoolFunction(Card.IsAttribute,ATTRIBUTE_FIRE))
	e3:SetValue(-400)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4)
	-- ②：这张卡被战斗·效果破坏的场合，以自己墓地1只水属性怪兽为对象才能发动。那只怪兽加入手卡。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(65170459,0))
	e5:SetCategory(CATEGORY_TOHAND)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetCountLimit(1,65170459)
	e5:SetCondition(c65170459.thcon)
	e5:SetTarget(c65170459.thtg)
	e5:SetOperation(c65170459.thop)
	c:RegisterEffect(e5)
end
-- 判定发动条件：这张卡被战斗或效果破坏
function c65170459.thcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
-- 过滤条件：自己墓地的水属性怪兽
function c65170459.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsAbleToHand()
end
-- 效果发动的目标选择与检测（选择自己墓地1只水属性怪兽作为对象）
function c65170459.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c65170459.thfilter(chkc) end
	-- 在效果发动时，检查自己墓地是否存在符合条件、可作为效果对象的水属性怪兽
	if chk==0 then return Duel.IsExistingTarget(c65170459.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只水属性怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c65170459.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息为：将选中的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理的执行：将作为对象的水属性怪兽加入手牌
function c65170459.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
