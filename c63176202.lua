--大将軍 紫炎
-- 效果：
-- 自己场上有名字带有「六武众」的怪兽2只以上存在的场合，这张卡可以从手卡特殊召唤。只要这张卡在场上表侧表示存在，对方1回合只能有1次把魔法·陷阱卡发动。此外，场上表侧表示存在的这张卡被破坏的场合，可以作为代替把自己场上表侧表示存在的1只名字带有「六武众」的怪兽破坏。
function c63176202.initial_effect(c)
	-- 自己场上有名字带有「六武众」的怪兽2只以上存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c63176202.spcon)
	c:RegisterEffect(e1)
	-- 此外，场上表侧表示存在的这张卡被破坏的场合，可以作为代替把自己场上表侧表示存在的1只名字带有「六武众」的怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c63176202.desreptg)
	e2:SetOperation(c63176202.desrepop)
	c:RegisterEffect(e2)
	-- 只要这张卡在场上表侧表示存在，对方1回合只能有1次把魔法·陷阱卡发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetOperation(c63176202.count)
	c:RegisterEffect(e3)
	-- 只要这张卡在场上表侧表示存在，对方1回合只能有1次把魔法·陷阱卡发动。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e4:SetCode(EVENT_CHAIN_NEGATED)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetOperation(c63176202.rst)
	c:RegisterEffect(e4)
	-- 只要这张卡在场上表侧表示存在，对方1回合只能有1次把魔法·陷阱卡发动。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CANNOT_ACTIVATE)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(0,1)
	e5:SetCondition(c63176202.econ)
	e5:SetValue(c63176202.elimit)
	c:RegisterEffect(e5)
end
-- 过滤条件：自己场上表侧表示的「六武众」怪兽
function c63176202.spfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x103d)
end
-- 特殊召唤规则的条件：怪兽区域有空位，且自己场上存在至少2只表侧表示的「六武众」怪兽
function c63176202.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否有可用的怪兽区域空格
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己场上是否存在2只以上满足过滤条件（表侧表示「六武众」）的怪兽
		and Duel.IsExistingMatchingCard(c63176202.spfilter,tp,LOCATION_MZONE,0,2,nil)
end
-- 过滤条件：场上表侧表示、可以被效果破坏、且未确定被破坏的「六武众」怪兽
function c63176202.repfilter(c,e)
	return c:IsFaceup() and c:IsSetCard(0x103d)
		and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED+STATUS_BATTLE_DESTROYED)
end
-- 代替破坏效果的靶向/条件检查：自身因非代替原因被破坏，且场上有可代替破坏的「六武众」怪兽
function c63176202.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsReason(REASON_REPLACE) and c:IsOnField() and c:IsFaceup()
		-- 检查自己场上是否存在至少1只可以代替破坏的「六武众」怪兽（不包括自身）
		and Duel.IsExistingMatchingCard(c63176202.repfilter,tp,LOCATION_MZONE,0,1,c,e) end
	-- 询问玩家是否发动代替破坏的效果
	if Duel.SelectEffectYesNo(tp,c,96) then
		-- 给玩家发送提示信息：“请选择要代替破坏的卡”
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
		-- 玩家选择1只用于代替破坏的「六武众」怪兽
		local g=Duel.SelectMatchingCard(tp,c63176202.repfilter,tp,LOCATION_MZONE,0,1,1,c,e)
		e:SetLabelObject(g:GetFirst())
		g:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	else return false end
end
-- 代替破坏效果的执行：将选中的代替卡片破坏，从而使自身免于被破坏
function c63176202.desrepop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	tc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	-- 破坏选中的代替卡片，破坏原因为效果代替破坏
	Duel.Destroy(tc,REASON_EFFECT+REASON_REPLACE)
end
-- 对方发动魔法·陷阱卡时，给自身注册一个表示“本回合对方已发动过魔陷”的Flag，该Flag在回合结束或离场时重置
function c63176202.count(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp or not re:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	e:GetHandler():RegisterFlagEffect(63176202,RESET_EVENT+0x3ff0000+RESET_PHASE+PHASE_END,0,1)
end
-- 若对方发动的魔法·陷阱卡的发动被无效，则重置（清除）该Flag，不计入发动次数限制
function c63176202.rst(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp or not re:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	e:GetHandler():ResetFlagEffect(63176202)
end
-- 限制发动效果的启用条件：自身带有“对方已发动过魔陷”的Flag
function c63176202.econ(e)
	return e:GetHandler():GetFlagEffect(63176202)~=0
end
-- 限制发动的卡片类型：魔法·陷阱卡的发动（EFFECT_TYPE_ACTIVATE）
function c63176202.elimit(e,te,tp)
	return te:IsHasType(EFFECT_TYPE_ACTIVATE)
end
