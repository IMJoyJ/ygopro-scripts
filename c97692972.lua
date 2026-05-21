--アマゾネスの金鞭使い
-- 效果：
-- ←1 【灵摆】 1→
-- 这个卡名的②的灵摆效果1回合只能使用1次。
-- ①：自己场上的「亚马逊」怪兽的攻击力上升自身的等级×100。
-- ②：自己的「亚马逊」怪兽进行战斗的攻击宣言时，以场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
-- 【怪兽效果】
-- 这个卡名的①②的怪兽效果1回合各能使用1次。
-- ①：怪兽区域的这张卡被战斗·效果破坏的场合才能发动。这张卡在自己的灵摆区域放置。
-- ②：这张卡在墓地存在的状态，自己场上有「亚马逊」怪兽特殊召唤的场合才能发动。这张卡在自己的灵摆区域放置。
function c97692972.initial_effect(c)
	-- 注册灵摆怪兽的灵摆召唤和灵摆卡发动等基本属性。
	aux.EnablePendulumAttribute(c)
	-- ①：自己场上的「亚马逊」怪兽的攻击力上升自身的等级×100。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	-- 过滤受攻击力上升效果影响的卡片为「亚马逊」怪兽。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x4))
	e1:SetValue(c97692972.atkval)
	c:RegisterEffect(e1)
	-- ②：自己的「亚马逊」怪兽进行战斗的攻击宣言时，以场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,97692972)
	e2:SetCondition(c97692972.descon)
	e2:SetTarget(c97692972.destg)
	e2:SetOperation(c97692972.desop)
	c:RegisterEffect(e2)
	-- ①：怪兽区域的这张卡被战斗·效果破坏的场合才能发动。这张卡在自己的灵摆区域放置。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,97692973)
	e3:SetCondition(c97692972.pencon)
	e3:SetTarget(c97692972.pentg)
	e3:SetOperation(c97692972.penop)
	c:RegisterEffect(e3)
	-- ②：这张卡在墓地存在的状态，自己场上有「亚马逊」怪兽特殊召唤的场合才能发动。这张卡在自己的灵摆区域放置。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_LEAVE_GRAVE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,97692974)
	e4:SetCondition(c97692972.pencon2)
	e4:SetTarget(c97692972.pentg2)
	e4:SetOperation(c97692972.penop)
	c:RegisterEffect(e4)
end
-- 计算攻击力上升数值的函数，返回怪兽等级×100。
function c97692972.atkval(e,c)
	return c:GetLevel()*100
end
-- 灵摆效果②的发动条件：进行战斗的怪兽是自己场上表侧表示的「亚马逊」怪兽。
function c97692972.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前回合玩家操控的处于战斗中的怪兽。
	local tc=Duel.GetBattleMonster(tp)
	return tc and tc:IsSetCard(0x4) and tc:IsFaceup()
end
-- 过滤场上的魔法·陷阱卡。
function c97692972.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 灵摆效果②的发动准备：选择场上1张魔法·陷阱卡作为对象，并设置破坏的操作信息。
function c97692972.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c97692972.desfilter(chkc) end
	-- 检查场上是否存在可以作为对象的魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingTarget(c97692972.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择1张魔法·陷阱卡作为效果的对象。
	local g=Duel.SelectTarget(tp,c97692972.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息为破坏选中的卡片。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 灵摆效果②的效果处理：破坏作为对象的卡。
function c97692972.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动的效果所指向的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果破坏目标卡片。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 怪兽效果①的发动条件：怪兽区域的这张卡因战斗或效果被破坏。
function c97692972.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
-- 怪兽效果①的发动准备：检查自己的灵摆区域是否有空位。
function c97692972.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查左侧或右侧的灵摆区域是否可用。
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
-- 怪兽效果①和②的共同效果处理：将这张卡放置在自己的灵摆区域。
function c97692972.penop(e,tp,eg,ep,ev,re,r,rp)
	-- 若两个灵摆区域都不可用，则不进行处理。
	if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡表侧表示移动到自己的灵摆区域。
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
-- 过滤特殊召唤的卡片为自己场上的「亚马逊」怪兽。
function c97692972.penfilter(c,tp)
	return c:IsSetCard(0x4) and c:IsControler(tp)
end
-- 怪兽效果②的发动条件：这张卡在墓地存在，且自己场上有「亚马逊」怪兽特殊召唤（不包含自身）。
function c97692972.pencon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c97692972.penfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- 怪兽效果②的发动准备：检查灵摆区域是否有空位，并设置涉及墓地的操作信息。
function c97692972.pentg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查左侧或右侧的灵摆区域是否可用。
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
	-- 设置效果处理信息为这张卡离开墓地。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
