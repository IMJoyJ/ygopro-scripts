--アマゾネスの銀剣使い
-- 效果：
-- ←7 【灵摆】 7→
-- 这个卡名的②的灵摆效果1回合只能使用1次。
-- ①：自己场上的「亚马逊」怪兽的攻击力上升自身的等级×100。
-- ②：自己的「亚马逊」怪兽进行战斗的攻击宣言时，以自己墓地1张「亚马逊」魔法·陷阱卡为对象才能发动。那张卡加入手卡。
-- 【怪兽效果】
-- 这个卡名的①②的怪兽效果1回合各能使用1次。
-- ①：怪兽区域的这张卡被战斗·效果破坏的场合才能发动。这张卡在自己的灵摆区域放置。
-- ②：这张卡在墓地存在的状态，自己场上有「亚马逊」怪兽特殊召唤的场合才能发动。这张卡在自己的灵摆区域放置。
function c24087580.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性，使其可以进行灵摆召唤和灵摆卡的发动
	aux.EnablePendulumAttribute(c)
	-- ①：自己场上的「亚马逊」怪兽的攻击力上升自身的等级×100。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	-- 设置效果目标为场上所有「亚马逊」怪兽
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x4))
	e1:SetValue(c24087580.atkval)
	c:RegisterEffect(e1)
	-- ②：自己的「亚马逊」怪兽进行战斗的攻击宣言时，以自己墓地1张「亚马逊」魔法·陷阱卡为对象才能发动。那张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,24087580)
	e2:SetCondition(c24087580.thcon)
	e2:SetTarget(c24087580.thtg)
	e2:SetOperation(c24087580.thop)
	c:RegisterEffect(e2)
	-- ①：怪兽区域的这张卡被战斗·效果破坏的场合才能发动。这张卡在自己的灵摆区域放置。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,24087581)
	e3:SetCondition(c24087580.pencon)
	e3:SetTarget(c24087580.pentg)
	e3:SetOperation(c24087580.penop)
	c:RegisterEffect(e3)
	-- ②：这张卡在墓地存在的状态，自己场上有「亚马逊」怪兽特殊召唤的场合才能发动。这张卡在自己的灵摆区域放置。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_LEAVE_GRAVE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,24087582)
	e4:SetCondition(c24087580.pencon2)
	e4:SetTarget(c24087580.pentg2)
	e4:SetOperation(c24087580.penop)
	c:RegisterEffect(e4)
end
-- 计算攻击力提升值，为自身等级乘以100
function c24087580.atkval(e,c)
	return c:GetLevel()*100
end
-- 判断是否为攻击宣言时，且攻击怪兽为「亚马逊」怪兽且表侧表示
function c24087580.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前正在攻击的怪兽
	local tc=Duel.GetBattleMonster(tp)
	return tc and tc:IsSetCard(0x4) and tc:IsFaceup()
end
-- 定义墓地「亚马逊」魔法·陷阱卡的筛选条件
function c24087580.thfilter(c)
	return c:IsSetCard(0x4) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 设置效果目标为墓地中的「亚马逊」魔法·陷阱卡，用于选择加入手牌
function c24087580.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c24087580.thfilter(chkc) end
	-- 检查是否满足选择目标的条件，即墓地是否存在符合条件的「亚马逊」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c24087580.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择墓地中的「亚马逊」魔法·陷阱卡作为效果对象
	local g=Duel.SelectTarget(tp,c24087580.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果操作信息，表示将选择的卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 执行效果操作，将选择的卡加入手牌
function c24087580.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡以效果原因送入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 判断是否为因战斗或效果破坏且从怪兽区域被破坏
function c24087580.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
-- 设置效果目标，检查灵摆区域是否有空位
function c24087580.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查灵摆区域是否有空位
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
-- 执行效果操作，将此卡移至灵摆区域
function c24087580.penop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查灵摆区域是否有空位
	if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡移动到玩家的灵摆区域
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
-- 定义「亚马逊」怪兽的筛选条件
function c24087580.penfilter(c,tp)
	return c:IsSetCard(0x4) and c:IsControler(tp)
end
-- 判断是否为特殊召唤成功且不包含此卡
function c24087580.pencon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c24087580.penfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- 设置效果目标，检查灵摆区域是否有空位
function c24087580.pentg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查灵摆区域是否有空位
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
	-- 设置效果操作信息，表示将此卡移至灵摆区域
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
