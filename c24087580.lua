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
	-- 为这张卡启用灵摆怪兽属性，使其可以作为灵摆卡在灵摆区域发动和放置，并能进行灵摆召唤。
	aux.EnablePendulumAttribute(c)
	-- ①：自己场上的「亚马逊」怪兽的攻击力上升自身的等级×100。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	-- 设置攻击力上升效果的对象筛选条件：拥有「亚马逊」字段的怪兽。
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
-- 计算攻击力上升值：返回该怪兽当前等级×100。
function c24087580.atkval(e,c)
	return c:GetLevel()*100
end
-- 效果发动条件：我方场上存在表侧表示的「亚马逊」怪兽正在进行战斗的攻击宣言。
function c24087580.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取我方当前正在参与战斗的怪兽。
	local tc=Duel.GetBattleMonster(tp)
	return tc and tc:IsSetCard(0x4) and tc:IsFaceup()
end
-- 筛选墓地中同时满足「亚马逊」字段、魔法·陷阱卡类型且能加入手卡的卡。
function c24087580.thfilter(c)
	return c:IsSetCard(0x4) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果发动时从自己墓地选择1张「亚马逊」魔法·陷阱卡为对象，并设置加入手牌的操作信息。
function c24087580.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c24087580.thfilter(chkc) end
	-- 检查自己墓地是否存在至少1张符合条件的「亚马逊」魔法·陷阱卡，以保证效果可以发动。
	if chk==0 then return Duel.IsExistingTarget(c24087580.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家发送选择提示，提示内容为“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择1张符合条件的「亚马逊」魔法·陷阱卡作为效果对象。
	local g=Duel.SelectTarget(tp,c24087580.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 登记本次连锁的处理信息：将选择的对象卡加入手牌，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理时，若对象卡仍与效果关联，则将其加入持有者手卡。
function c24087580.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取出当前连锁处理的第一个对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以效果原因送去其持有者的手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 条件判定：这张卡在怪兽区域被战斗或效果破坏，且破坏时为表侧表示。
function c24087580.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
-- 目标阶段检查自己的灵摆区域是否有空位，有才能发动。
function c24087580.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的灵摆区域两个位置中是否存在空位。
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
-- 效果处理时，若灵摆区域有空位且这张卡仍与效果关联，则将其表侧表示放置到自己的灵摆区域。
function c24087580.penop(e,tp,eg,ep,ev,re,r,rp)
	-- 若灵摆区域两个位置都不可用，则直接终止本次处理。
	if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示移动到自己的灵摆区域。
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
-- 筛选特殊召唤的怪兽是否为「亚马逊」字段且由我方控制。
function c24087580.penfilter(c,tp)
	return c:IsSetCard(0x4) and c:IsControler(tp)
end
-- 条件判定：这张卡在墓地存在时，场上有「亚马逊」怪兽特殊召唤成功，且特殊召唤的不是这张卡自身。
function c24087580.pencon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c24087580.penfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- 检查灵摆区域是否有空位，并登记这张卡从墓地移动的处理信息。
function c24087580.pentg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的灵摆区域两个位置中是否存在空位。
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
	-- 登记本次处理涉及这张卡离开墓地的信息，类别为CATEGORY_LEAVE_GRAVE。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
