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
	-- 启用灵摆卡的发动及灵摆召唤等灵摆怪兽的基本属性
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
-- 限制玩家灵摆召唤非「文具电子人」怪兽的过滤函数
function c10117149.splimit(e,c,tp,sumtp,sumpos)
	return not c:IsSetCard(0xab) and bit.band(sumtp,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
-- 过滤魔法与陷阱卡
function c10117149.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 破坏效果的发动准备与对象选择
function c10117149.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c10117149.desfilter(chkc) end
	-- 在效果发动检查时，检查场上是否存在可以作为破坏对象的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c10117149.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张魔法·陷阱卡作为效果对象
	local g=Duel.SelectTarget(tp,c10117149.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置破坏操作的信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果的效果处理
function c10117149.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为破坏对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 破坏目标卡片
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 过滤表侧表示的「文具电子人」卡片
function c10117149.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xab)
end
-- 计算并更新这张卡攻击力的上升值
function c10117149.atkval(e,c)
	-- 返回自己额外卡组中表侧表示的「文具电子人」怪兽数量乘以500的数值
	return Duel.GetMatchingGroupCount(c10117149.cfilter,c:GetControler(),LOCATION_EXTRA,0,nil)*500
end
-- 检查被破坏的这张卡之前的位置是否在灵摆区域
function c10117149.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_PZONE)
end
-- 过滤自己墓地可特殊召唤的「文具电子人」怪兽
function c10117149.spfilter(c,e,tp)
	return c:IsSetCard(0xab) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的发动准备与对象选择
function c10117149.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c10117149.spfilter(chkc,e,tp) end
	-- 在效果发动检查时，检查主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 在效果发动检查时，检查墓地中是否存在可选择为特殊召唤对象的怪兽
		and Duel.IsExistingTarget(c10117149.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只「文具电子人」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c10117149.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤操作的信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤效果的效果处理
function c10117149.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为特殊召唤对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
