--ブンボーグ006
-- 效果：
-- ←1 【灵摆】 1→
-- ①：自己不是「文具电子人」怪兽不能灵摆召唤。这个效果不会被无效化。
-- 【怪兽效果】
-- 「文具电子人006」的③的怪兽效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合，以场上1只怪兽为对象才能发动。那只怪兽的表示形式变更。
-- ②：这张卡的攻击力上升自己的额外卡组的表侧表示的「文具电子人」怪兽数量×500。
-- ③：这张卡在灵摆区域被破坏的场合，以自己墓地1张「文具电子人」卡为对象才能发动。那张卡加入手卡。
function c55106249.initial_effect(c)
	-- 注册灵摆怪兽的灵摆属性（灵摆召唤、作为灵摆卡发动等基本规则）。
	aux.EnablePendulumAttribute(c)
	-- ①：自己不是「文具电子人」怪兽不能灵摆召唤。这个效果不会被无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c55106249.splimit)
	c:RegisterEffect(e2)
	-- ①：这张卡召唤·特殊召唤成功的场合，以场上1只怪兽为对象才能发动。那只怪兽的表示形式变更。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_POSITION)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetTarget(c55106249.postg)
	e3:SetOperation(c55106249.posop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
	-- ②：这张卡的攻击力上升自己的额外卡组的表侧表示的「文具电子人」怪兽数量×500。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_UPDATE_ATTACK)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetValue(c55106249.atkval)
	c:RegisterEffect(e5)
	-- ③：这张卡在灵摆区域被破坏的场合，以自己墓地1张「文具电子人」卡为对象才能发动。那张卡加入手卡。
	local e6=Effect.CreateEffect(c)
	e6:SetCategory(CATEGORY_TOHAND)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_DESTROYED)
	e6:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e6:SetCountLimit(1,55106249)
	e6:SetCondition(c55106249.thcon)
	e6:SetTarget(c55106249.thtg)
	e6:SetOperation(c55106249.thop)
	c:RegisterEffect(e6)
end
-- 限制只能灵摆召唤「文具电子人」怪兽的过滤条件函数。
function c55106249.splimit(e,c,tp,sumtp,sumpos)
	return not c:IsSetCard(0xab) and bit.band(sumtp,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
-- 过滤场上可以改变表示形式的怪兽。
function c55106249.filter(c)
	return c:IsCanChangePosition()
end
-- 改变表示形式效果的靶向/发动准备阶段（Target/Targeting check）。
function c55106249.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c55106249.filter(chkc) end
	-- 检查场上是否存在至少1只可以改变表示形式的怪兽作为可选对象。
	if chk==0 then return Duel.IsExistingTarget(c55106249.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 给发动效果的玩家发送“请选择要改变表示形式的怪兽”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 让玩家选择场上1只可以改变表示形式的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c55106249.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁处理信息，表明此效果包含“改变表示形式”的操作，涉及1张卡。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 改变表示形式效果的实际处理函数（Operation）。
function c55106249.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的第1个效果对象。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 改变目标怪兽的表示形式（若为攻击表示则变为表侧守备表示，若为守备表示则变为表侧攻击表示）。
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end
-- 过滤额外卡组中表侧表示的「文具电子人」怪兽。
function c55106249.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xab)
end
-- 计算攻击力上升数值的函数。
function c55106249.atkval(e,c)
	-- 返回自己额外卡组表侧表示的「文具电子人」怪兽数量乘以500的数值。
	return Duel.GetMatchingGroupCount(c55106249.cfilter,c:GetControler(),LOCATION_EXTRA,0,nil)*500
end
-- 检查此卡被破坏前是否处于灵摆区域，作为效果发动的条件。
function c55106249.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_PZONE)
end
-- 过滤墓地中可以加入手牌的「文具电子人」卡片。
function c55106249.thfilter(c)
	return c:IsSetCard(0xab) and c:IsAbleToHand()
end
-- 回收墓地卡片效果的靶向/发动准备阶段（Target/Targeting check）。
function c55106249.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c55106249.thfilter(chkc) end
	-- 检查自己墓地是否存在至少1张可以加入手牌的「文具电子人」卡片。
	if chk==0 then return Duel.IsExistingTarget(c55106249.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 给玩家发送“请选择要加入手牌的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家选择自己墓地1张「文具电子人」卡片作为效果对象。
	local g=Duel.SelectTarget(tp,c55106249.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁处理信息，表明此效果包含“加入手牌”的操作，涉及1张卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 回收墓地卡片效果的实际处理函数（Operation）。
function c55106249.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的第1个效果对象。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片因效果加入持有者的手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
