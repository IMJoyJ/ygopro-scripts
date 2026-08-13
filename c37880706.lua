--ドリトル・キメラ
-- 效果：
-- 炎属性怪兽2只
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：场上的炎属性怪兽的攻击力·守备力上升500，水属性怪兽的攻击力·守备力下降400。
-- ②：这张卡被战斗·效果破坏的场合，以自己墓地1只炎属性怪兽为对象才能发动。那只怪兽加入手卡。
function c37880706.initial_effect(c)
	-- 为这张卡添加连接召唤手续：需要以2只炎属性连接怪兽作为连接素材。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkAttribute,ATTRIBUTE_FIRE),2,2)
	c:EnableReviveLimit()
	-- ①：场上的炎属性怪兽的攻击力·守备力上升500，水属性怪兽的攻击力·守备力下降400。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	-- 设置该效果的影响对象为炎属性怪兽，即只有场上的炎属性怪兽才会受到攻击力上升效果。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsAttribute,ATTRIBUTE_FIRE))
	e1:SetValue(500)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	-- 设置该效果的影响对象为水属性怪兽，使场上的水属性怪兽受到攻击力下降效果。
	e3:SetTarget(aux.TargetBoolFunction(Card.IsAttribute,ATTRIBUTE_WATER))
	e3:SetValue(-400)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4)
	-- ②：这张卡被战斗·效果破坏的场合，以自己墓地1只炎属性怪兽为对象才能发动。那只怪兽加入手卡。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(37880706,0))
	e5:SetCategory(CATEGORY_TOHAND)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetCountLimit(1,37880706)
	e5:SetCondition(c37880706.thcon)
	e5:SetTarget(c37880706.thtg)
	e5:SetOperation(c37880706.thop)
	c:RegisterEffect(e5)
end
-- 效果发动条件：这张卡被战斗破坏或效果破坏时满足条件（破坏原因包含战斗或效果）。
function c37880706.thcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
-- 作为选择对象的过滤条件：自己墓地的炎属性怪兽，且能够加入手卡。
function c37880706.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToHand()
end
-- 效果发动时的取对象处理：选择自己墓地1只满足条件的炎属性怪兽为对象，并设置将对象加入手卡的操作信息。
function c37880706.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c37880706.thfilter(chkc) end
	-- 检查自己墓地是否存在至少1只满足条件的炎属性怪兽，作为效果可以发动的判定。
	if chk==0 then return Duel.IsExistingTarget(c37880706.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家显示选择提示，提示内容为“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择1只满足条件的炎属性怪兽作为效果对象，并登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c37880706.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：本次连锁处理包含将1张卡加入手卡，处理对象为已选择的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理时的操作：若对象仍与效果关联，则将那只怪兽加入持有者的手卡。
function c37880706.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的第一个（即唯一一个）对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以效果原因送回持有者手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
