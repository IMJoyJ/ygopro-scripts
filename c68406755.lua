--トラミッド・スフィンクス
-- 效果：
-- 这张卡不能通常召唤，用「三形金字塔」卡的效果才能特殊召唤。
-- ①：「三形金字塔的斯芬克斯」以外的自己场上的表侧表示的「三形金字塔」卡被战斗·效果破坏的场合才能发动。这张卡从手卡特殊召唤。
-- ②：自己场上有其他的「三形金字塔」卡存在的场合，这张卡的攻击力·守备力上升自己墓地的场地魔法卡种类×500，对方怪兽只能向「三形金字塔的斯芬克斯」攻击。
function c68406755.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤，用「三形金字塔」卡的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c68406755.splimit)
	c:RegisterEffect(e1)
	-- ①：「三形金字塔的斯芬克斯」以外的自己场上的表侧表示的「三形金字塔」卡被战斗·效果破坏的场合才能发动。这张卡从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(68406755,0))  --"这张卡特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_HAND)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(c68406755.spcon)
	e2:SetTarget(c68406755.sptg)
	e2:SetOperation(c68406755.spop)
	c:RegisterEffect(e2)
	-- 自己场上有其他的「三形金字塔」卡存在的场合，这张卡的攻击力·守备力上升自己墓地的场地魔法卡种类×500
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetCondition(c68406755.efcon)
	e3:SetValue(c68406755.atkval)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4)
	-- 对方怪兽只能向「三形金字塔的斯芬克斯」攻击。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(0,LOCATION_MZONE)
	e5:SetCondition(c68406755.efcon)
	e5:SetValue(c68406755.atklimit)
	c:RegisterEffect(e5)
	-- 对方怪兽只能向「三形金字塔的斯芬克斯」攻击。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e6:SetRange(LOCATION_MZONE)
	e6:SetTargetRange(0,LOCATION_MZONE)
	e6:SetCondition(c68406755.efcon)
	c:RegisterEffect(e6)
end
-- 特殊召唤限制：只能通过「三形金字塔」卡的效果特殊召唤
function c68406755.splimit(e,se,sp,st)
	return se:GetHandler():IsSetCard(0xe2)
end
-- 过滤条件：自己场上表侧表示的「三形金字塔的斯芬克斯」以外的「三形金字塔」卡因战斗或效果被破坏
function c68406755.spfilter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT)
		and c:IsSetCard(0xe2) and not c:IsCode(68406755)
		and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP)
end
-- 触发条件：检查被破坏的卡中是否存在满足过滤条件的卡
function c68406755.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c68406755.spfilter,1,nil,tp)
end
-- 效果发动目标：检查怪兽区域空位及自身是否能特殊召唤，并设置特殊召唤的操作信息
function c68406755.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查发动时自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,true) end
	-- 设置特殊召唤的操作信息，表示准备将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：将手牌中的这张卡特殊召唤，并完成正规召唤程序
function c68406755.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 尝试将自身以表侧表示特殊召唤（无视苏生限制）
	if Duel.SpecialSummon(c,0,tp,tp,false,true,POS_FACEUP)~=0 then
		c:CompleteProcedure()
	end
end
-- 过滤条件：场上表侧表示的「三形金字塔」卡
function c68406755.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xe2)
end
-- 效果适用条件：自己场上存在自身以外的其他「三形金字塔」卡
function c68406755.efcon(e)
	-- 检查自己场上是否存在至少1张自身以外的表侧表示「三形金字塔」卡
	return Duel.IsExistingMatchingCard(c68406755.cfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,e:GetHandler())
end
-- 数值计算：自己墓地的场地魔法卡种类数量×500
function c68406755.atkval(e,c)
	-- 获取自己墓地的所有场地魔法卡
	local g=Duel.GetMatchingGroup(Card.IsType,c:GetControler(),LOCATION_GRAVE,0,nil,TYPE_FIELD)
	return g:GetClassCount(Card.GetCode)*500
end
-- 攻击限制过滤：除「三形金字塔的斯芬克斯」以外的怪兽不能被选择为攻击对象
function c68406755.atklimit(e,c)
	return not c:IsCode(68406755)
end
