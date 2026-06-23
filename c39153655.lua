--DDケルベロス
-- 效果：
-- ←6 【灵摆】 6→
-- ①：1回合1次，以自己场上1只「DD」怪兽为对象才能发动。那只怪兽的等级变成4星，攻击力·守备力上升400。
-- 【怪兽效果】
-- ①：这张卡从手卡的灵摆召唤成功时，「DD 刻耳柏洛斯」以外的「DD」怪兽在自己场上存在的场合以自己墓地1张永续魔法卡为对象才能发动。那张卡加入手卡。
function c39153655.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性，使其可以进行灵摆召唤和灵摆卡的发动
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，以自己场上1只「DD」怪兽为对象才能发动。那只怪兽的等级变成4星，攻击力·守备力上升400。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(39153655,0))  --"攻守变化"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c39153655.atktg)
	e2:SetOperation(c39153655.atkop)
	c:RegisterEffect(e2)
	-- ①：这张卡从手卡的灵摆召唤成功时，「DD 刻耳柏洛斯」以外的「DD」怪兽在自己场上存在的场合以自己墓地1张永续魔法卡为对象才能发动。那张卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCondition(c39153655.thcon)
	e3:SetTarget(c39153655.thtg)
	e3:SetOperation(c39153655.thop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于筛选满足条件的「DD」怪兽（表侧表示、属于DD卡组、等级不是4、等级大于等于1）
function c39153655.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xaf) and not c:IsLevel(4) and c:IsLevelAbove(1)
end
-- 设置效果目标选择函数，用于选择满足条件的怪兽作为效果对象
function c39153655.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c39153655.filter(chkc) end
	-- 检查是否存在满足条件的怪兽作为效果对象
	if chk==0 then return Duel.IsExistingTarget(c39153655.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足条件的怪兽作为效果对象
	Duel.SelectTarget(tp,c39153655.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 处理效果的执行函数，将目标怪兽等级变为4，并提升其攻击力和守备力
function c39153655.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and not tc:IsLevel(4) then
		-- 将目标怪兽的等级变为4
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(4)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(400)
		tc:RegisterEffect(e2)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e3)
	end
end
-- 过滤函数，用于筛选满足条件的「DD」怪兽（表侧表示、属于DD卡组、不是刻耳柏洛斯）
function c39153655.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xaf) and not c:IsCode(39153655)
end
-- 判断效果发动条件：卡片是通过灵摆召唤从手牌特殊召唤成功，并且自己场上存在其他「DD」怪兽
function c39153655.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_PENDULUM) and c:IsPreviousLocation(LOCATION_HAND)
		-- 检查自己场上是否存在其他「DD」怪兽
		and Duel.IsExistingMatchingCard(c39153655.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤函数，用于筛选满足条件的永续魔法卡（类型为魔法+永续、可以加入手牌）
function c39153655.thfilter(c)
	return c:GetType()==TYPE_SPELL+TYPE_CONTINUOUS and c:IsAbleToHand()
end
-- 设置效果目标选择函数，用于选择满足条件的墓地永续魔法卡作为效果对象
function c39153655.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c39153655.thfilter(chkc) end
	-- 检查是否存在满足条件的墓地永续魔法卡作为效果对象
	if chk==0 then return Duel.IsExistingTarget(c39153655.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的墓地永续魔法卡作为效果对象
	local g=Duel.SelectTarget(tp,c39153655.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果操作信息，指定效果处理的分类为回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 处理效果的执行函数，将目标永续魔法卡加入手牌
function c39153655.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
