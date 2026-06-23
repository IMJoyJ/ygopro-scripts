--ドリトル・キメラ
-- 效果：
-- 炎属性怪兽2只
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：场上的炎属性怪兽的攻击力·守备力上升500，水属性怪兽的攻击力·守备力下降400。
-- ②：这张卡被战斗·效果破坏的场合，以自己墓地1只炎属性怪兽为对象才能发动。那只怪兽加入手卡。
function c37880706.initial_effect(c)
	-- 添加连接召唤手续，需要2只炎属性怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkAttribute,ATTRIBUTE_FIRE),2,2)
	c:EnableReviveLimit()
	-- 场上的炎属性怪兽的攻击力·守备力上升500
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	-- 设置效果目标为炎属性怪兽
	e1:SetTarget(aux.TargetBoolFunction(Card.IsAttribute,ATTRIBUTE_FIRE))
	e1:SetValue(500)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	-- 设置效果目标为水属性怪兽
	e3:SetTarget(aux.TargetBoolFunction(Card.IsAttribute,ATTRIBUTE_WATER))
	e3:SetValue(-400)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4)
	-- 这张卡被战斗·效果破坏的场合，以自己墓地1只炎属性怪兽为对象才能发动。那只怪兽加入手卡。
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
-- 判断破坏原因是否为效果或战斗破坏
function c37880706.thcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
-- 过滤墓地中的炎属性怪兽
function c37880706.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToHand()
end
-- 选择目标：从自己墓地选择1只炎属性怪兽
function c37880706.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c37880706.thfilter(chkc) end
	-- 检查是否满足选择目标的条件
	if chk==0 then return Duel.IsExistingTarget(c37880706.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择1只符合条件的墓地怪兽作为目标
	local g=Duel.SelectTarget(tp,c37880706.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁操作信息，指定将怪兽送入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 执行效果操作：将选中的怪兽加入手牌
function c37880706.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以效果原因送入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
