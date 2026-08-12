--古代の機械要塞
-- 效果：
-- ①：这个回合召唤·特殊召唤的自己场上的「古代的机械」怪兽不会被对方的效果破坏，对方不能把那些作为效果的对象。
-- ②：对方不能对应「古代的机械」卡的效果的发动把魔法·陷阱·怪兽的效果发动。
-- ③：魔法与陷阱区域的这张卡被破坏的场合才能发动。从自己的手卡·墓地把1只「古代的机械」怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是「古代的机械」怪兽不能特殊召唤。
function c70147689.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：这个回合召唤·特殊召唤的自己场上的「古代的机械」怪兽不会被对方的效果破坏
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c70147689.target)
	-- 设置不会被对方的效果破坏
	e2:SetValue(aux.indoval)
	c:RegisterEffect(e2)
	-- 对方不能把那些作为效果的对象。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(c70147689.target)
	-- 设置不能成为对方的效果对象
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	-- ②：对方不能对应「古代的机械」卡的效果的发动把魔法·陷阱·怪兽的效果发动。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_SZONE)
	e4:SetOperation(c70147689.chainop)
	c:RegisterEffect(e4)
	-- ③：魔法与陷阱区域的这张卡被破坏的场合才能发动。从自己的手卡·墓地把1只「古代的机械」怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是「古代的机械」怪兽不能特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetDescription(aux.Stringid(70147689,0))
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetCondition(c70147689.spcon)
	e5:SetTarget(c70147689.sptg)
	e5:SetOperation(c70147689.spop)
	c:RegisterEffect(e5)
end
-- 过滤本回合召唤·特殊召唤的自己场上的「古代的机械」怪兽
function c70147689.target(e,c)
	return c:IsSetCard(0x7) and c:IsStatus(STATUS_SUMMON_TURN+STATUS_SPSUMMON_TURN)
end
-- 在「古代的机械」卡的效果发动时，限制对方连锁发动效果
function c70147689.chainop(e,tp,eg,ep,ev,re,r,rp)
	if re:GetHandler():IsSetCard(0x7) then
		-- 设置连锁限制函数
		Duel.SetChainLimit(c70147689.chainlm)
	end
end
-- 限制只有发动效果的玩家可以继续连锁
function c70147689.chainlm(e,rp,tp)
	return tp==rp
end
-- 检查这张卡被破坏前是否在魔法与陷阱区域
function c70147689.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_SZONE)
end
-- 过滤手卡·墓地可以特殊召唤的「古代的机械」怪兽
function c70147689.filter(c,e,tp)
	return c:IsSetCard(0x7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果③发动的目标检查，确认怪兽区域有空位且手卡·墓地存在可特殊召唤的「古代的机械」怪兽，并设置操作信息
function c70147689.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡·墓地是否存在至少1只满足特殊召唤条件的「古代的机械」怪兽
		and Duel.IsExistingMatchingCard(c70147689.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息（从手卡·墓地特殊召唤1只怪兽）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果③的效果处理：从手卡·墓地特殊召唤1只「古代的机械」怪兽，并注册直到回合结束时自己不能特殊召唤「古代的机械」以外怪兽的限制
function c70147689.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡·墓地选择1只不受「王家之谷」影响的「古代的机械」怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c70147689.filter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 这个效果的发动后，直到回合结束时自己不是「古代的机械」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c70147689.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 给玩家注册特殊召唤限制的全局效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制不能特殊召唤「古代的机械」以外的怪兽
function c70147689.splimit(e,c)
	return not c:IsSetCard(0x7)
end
