--古代の機械究極巨人
-- 效果：
-- 「古代的机械巨人」＋「古代的机械」怪兽×2
-- 这张卡不用融合召唤不能特殊召唤。
-- ①：这张卡攻击的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
-- ②：这张卡向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
-- ③：这张卡被破坏的场合，以自己墓地1只「古代的机械巨人」为对象才能发动。那只怪兽无视召唤条件特殊召唤。
function c12652643.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用卡号为83104731的怪兽和2个满足融合种族为古代的机械的怪兽作为融合素材
	aux.AddFusionProcCodeFun(c,83104731,aux.FilterBoolFunction(Card.IsFusionSetCard,0x7),2,true,true)
	-- 这张卡不用融合召唤不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该卡的特殊召唤方式必须为融合召唤
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	-- ①：这张卡攻击的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e2)
	-- ③：这张卡被破坏的场合，以自己墓地1只「古代的机械巨人」为对象才能发动。那只怪兽无视召唤条件特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,1)
	e3:SetValue(c12652643.aclimit)
	e3:SetCondition(c12652643.actcon)
	c:RegisterEffect(e3)
	-- ②：这张卡向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(12652643,0))  --"特殊召唤"
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetTarget(c12652643.sptg)
	e4:SetOperation(c12652643.spop)
	c:RegisterEffect(e4)
end
-- 限制对方发动魔法·陷阱卡的函数，只对发动的卡类型为发动的卡有效
function c12652643.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 判断是否为攻击状态的函数，用于触发效果的条件判断
function c12652643.actcon(e)
	-- 判断当前攻击的卡是否为该卡本身
	return Duel.GetAttacker()==e:GetHandler()
end
-- 筛选墓地中的古代的机械巨人怪兽，用于特殊召唤的过滤函数
function c12652643.spfilter(c,e,tp)
	return c:IsCode(83104731) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 设置特殊召唤效果的目标选择函数
function c12652643.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c12652643.spfilter(chkc,e,tp) end
	-- 检查是否满足特殊召唤的条件，包括场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否在墓地中存在满足条件的古代的机械巨人怪兽
		and Duel.IsExistingTarget(c12652643.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 选择目标墓地中的古代的机械巨人怪兽
	local g=Duel.SelectTarget(tp,c12652643.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁操作信息，确定特殊召唤的怪兽数量和目标
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 设置特殊召唤效果的处理函数
function c12652643.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽无视召唤条件特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
	end
end
