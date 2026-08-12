--ミセス・レディエント
-- 效果：
-- 地属性怪兽2只
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：场上的地属性怪兽的攻击力·守备力上升500，风属性怪兽的攻击力·守备力下降400。
-- ②：这张卡被战斗·效果破坏的场合，以自己墓地1只地属性怪兽为对象才能发动。那只怪兽加入手卡。
function c3987233.initial_effect(c)
	-- 添加连接召唤手续，要求使用2只地属性怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkAttribute,ATTRIBUTE_EARTH),2,2)
	c:EnableReviveLimit()
	-- 场上的地属性怪兽的攻击力·守备力上升500
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	-- 设置效果目标为地属性怪兽
	e1:SetTarget(aux.TargetBoolFunction(Card.IsAttribute,ATTRIBUTE_EARTH))
	e1:SetValue(500)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	-- 设置效果目标为风属性怪兽
	e3:SetTarget(aux.TargetBoolFunction(Card.IsAttribute,ATTRIBUTE_WIND))
	e3:SetValue(-400)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4)
	-- 这张卡被战斗·效果破坏的场合，以自己墓地1只地属性怪兽为对象才能发动。那只怪兽加入手卡。
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
-- 判断破坏原因是否为效果或战斗破坏
function c3987233.thcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
-- 定义过滤函数，用于筛选墓地中的地属性怪兽
function c3987233.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsAbleToHand()
end
-- 设置效果的发动条件和目标选择逻辑
function c3987233.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c3987233.thfilter(chkc) end
	-- 检查是否满足发动条件，即是否存在符合条件的墓地目标
	if chk==0 then return Duel.IsExistingTarget(c3987233.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择符合条件的墓地目标怪兽
	local g=Duel.SelectTarget(tp,c3987233.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果操作信息，指定将目标怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 执行效果操作，将目标怪兽加入手牌
function c3987233.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以效果原因加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
