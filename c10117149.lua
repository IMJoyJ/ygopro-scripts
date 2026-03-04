--ブンボーグ005
-- 效果：
-- ←10 【灵摆】 10→
-- ①：自己不是「文具电子人」怪兽不能灵摆召唤。这个效果不会被无效化。
-- 【怪兽效果】
-- 「文具电子人005」的③的怪兽效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合，以场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
-- ②：这张卡的攻击力上升自己的额外卡组的表侧表示的「文具电子人」怪兽数量×500。
-- ③：这张卡在灵摆区域被破坏的场合，以自己墓地1只「文具电子人」怪兽为对象才能发动。那只怪兽特殊召唤。
function c10117149.initial_effect(c)
	-- 为灵摆怪兽添加灵摆属性，使其可以作为灵摆卡发动和进行灵摆召唤
	aux.EnablePendulumAttribute(c)
	-- ①：自己不是「文具电子人」怪兽不能灵摆召唤。这个效果不会被无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c10117149.splimit)
	c:RegisterEffect(e2)
	-- ①：这张卡召唤·特殊召唤成功的场合，以场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetTarget(c10117149.destg)
	e3:SetOperation(c10117149.desop)
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
	e5:SetValue(c10117149.atkval)
	c:RegisterEffect(e5)
	-- ③：这张卡在灵摆区域被破坏的场合，以自己墓地1只「文具电子人」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e6=Effect.CreateEffect(c)
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_DESTROYED)
	e6:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e6:SetCountLimit(1,10117149)
	e6:SetCondition(c10117149.spcon)
	e6:SetTarget(c10117149.sptg)
	e6:SetOperation(c10117149.spop)
	c:RegisterEffect(e6)
end
-- 限制非「文具电子人」怪兽进行灵摆召唤的判断逻辑
function c10117149.splimit(e,c,tp,sumtp,sumpos)
	return not c:IsSetCard(0xab) and bit.band(sumtp,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
-- 定义破坏目标的筛选条件：必须是魔法或陷阱卡
function c10117149.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 处理召唤成功时选取场上一张魔法或陷阱卡作为破坏目标的流程
function c10117149.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c10117149.desfilter(chkc) end
	-- 检查是否存在满足条件的魔法或陷阱卡可被选为破坏目标
	if chk==0 then return Duel.IsExistingTarget(c10117149.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的目标卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	-- 让玩家从场上选择一张符合条件的魔法或陷阱卡作为破坏目标
	local g=Duel.SelectTarget(tp,c10117149.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置当前连锁的操作信息为破坏1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行破坏所选目标卡的效果操作
function c10117149.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果选定的第一个目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因破坏目标卡
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 定义攻击力提升计算中使用的筛选条件：必须是表侧表示的「文具电子人」怪兽
function c10117149.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xab)
end
-- 计算攻击力提升值的函数
function c10117149.atkval(e,c)
	-- 统计额外卡组中符合条件的「文具电子人」怪兽数量，并乘以500作为攻击力提升值
	return Duel.GetMatchingGroupCount(c10117149.cfilter,c:GetControler(),LOCATION_EXTRA,0,nil)*500
end
-- 判断此卡是否从灵摆区域被破坏的条件函数
function c10117149.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_PZONE)
end
-- 定义墓地特殊召唤目标的筛选条件：必须是可以特殊召唤的「文具电子人」怪兽
function c10117149.spfilter(c,e,tp)
	return c:IsSetCard(0xab) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 处理从墓地特殊召唤一只「文具电子人」怪兽的目标选择流程
function c10117149.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c10117149.spfilter(chkc,e,tp) end
	-- 确认玩家主要怪兽区域是否有空位可供特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否存在满足条件的墓地「文具电子人」怪兽可被选为特殊召唤目标
		and Duel.IsExistingTarget(c10117149.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 让玩家从墓地中选择一只符合条件的「文具电子人」怪兽进行特殊召唤
	local g=Duel.SelectTarget(tp,c10117149.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置当前连锁的操作信息为特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行将选定怪兽从墓地特殊召唤到场上的操作
function c10117149.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果选定的第一个目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧攻击表示特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
