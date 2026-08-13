--古代の機械究極巨人
-- 效果：
-- 「古代的机械巨人」＋「古代的机械」怪兽×2
-- 这张卡不用融合召唤不能特殊召唤。
-- ①：这张卡攻击的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
-- ②：这张卡向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
-- ③：这张卡被破坏的场合，以自己墓地1只「古代的机械巨人」为对象才能发动。那只怪兽无视召唤条件特殊召唤。
function c12652643.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡设定融合素材：1只「古代的机械巨人」（卡号83104731）＋2只「古代的机械」字段怪兽（字段0x7）的融合召唤手续。
	aux.AddFusionProcCodeFun(c,83104731,aux.FilterBoolFunction(Card.IsFusionSetCard,0x7),2,true,true)
	-- 这张卡不用融合召唤不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 将特殊召唤条件的效果值设为aux.fuslimit，使此卡只能用融合召唤方式特殊召唤。
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	-- ②：这张卡向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e2)
	-- ①：这张卡攻击的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,1)
	e3:SetValue(c12652643.aclimit)
	e3:SetCondition(c12652643.actcon)
	c:RegisterEffect(e3)
	-- ③：这张卡被破坏的场合，以自己墓地1只「古代的机械巨人」为对象才能发动。那只怪兽无视召唤条件特殊召唤。
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
-- 过滤函数：判定对方发动的效果是否为魔法·陷阱卡的发动（EFFECT_TYPE_ACTIVATE），若是则被禁止。
function c12652643.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 效果发动条件：当前进行攻击的怪兽正是这张卡本身时，限制对方发动魔陷的效果才适用。
function c12652643.actcon(e)
	-- 判断当前攻击怪兽是否就是效果持有者此卡。
	return Duel.GetAttacker()==e:GetHandler()
end
-- 筛选墓地中符合条件的对象：必须是「古代的机械巨人」，并且可以被特殊召唤（此效果无视召唤条件）。
function c12652643.spfilter(c,e,tp)
	return c:IsCode(83104731) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 特殊召唤效果的发动条件和取对象：需要自己主要怪兽区有空位，且墓地存在1只满足条件的「古代的机械巨人」才能发动；发动时从墓地选择1只作为对象。
function c12652643.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c12652643.spfilter(chkc,e,tp) end
	-- 检查己方主要怪兽区域是否有可用的空格（用于特殊召唤）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在1只满足spfilter条件的「古代的机械巨人」可以作为对象。
		and Duel.IsExistingTarget(c12652643.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 弹出选择提示，提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只满足条件的「古代的机械巨人」，并将其设为效果对象。
	local g=Duel.SelectTarget(tp,c12652643.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：本次效果将进行1只怪兽的特殊召唤，用于连锁与效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：将选中的「古代的机械巨人」无视召唤条件地特殊召唤到自己场上。
function c12652643.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时选择的墓地对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以表侧表示将那只对象怪兽特殊召唤到自己场上（无视召唤条件）。
		Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
	end
end
