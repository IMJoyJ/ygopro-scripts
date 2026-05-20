--神炎皇ウリア
-- 效果：
-- 这张卡不能通常召唤。把自己场上3张表侧表示的陷阱卡送去墓地的场合才能特殊召唤。
-- ①：这张卡的攻击力上升自己墓地的永续陷阱卡数量×1000。
-- ②：1回合1次，以对方场上1张里侧表示的魔法·陷阱卡为对象才能发动（不能对应这个发动让魔法·陷阱卡发动）。那张里侧表示卡破坏。
function c6007213.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤限制，使这张卡不能被通常规则特殊召唤。
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 把自己场上3张表侧表示的陷阱卡送去墓地的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c6007213.spcon)
	e2:SetTarget(c6007213.sptg)
	e2:SetOperation(c6007213.spop)
	c:RegisterEffect(e2)
	-- ①：这张卡的攻击力上升自己墓地的永续陷阱卡数量×1000。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(c6007213.atkval)
	c:RegisterEffect(e3)
	-- ②：1回合1次，以对方场上1张里侧表示的魔法·陷阱卡为对象才能发动（不能对应这个发动让魔法·陷阱卡发动）。那张里侧表示卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(6007213,0))  --"魔陷破坏"
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetTarget(c6007213.destg)
	e4:SetOperation(c6007213.desop)
	c:RegisterEffect(e4)
end
-- 过滤场上可以作为特殊召唤Cost送去墓地的陷阱卡（若受特定卡片效果影响，也可以包括里侧表示的卡）。
function c6007213.spfilter(c,check)
	return c:IsAbleToGraveAsCost() and c:IsType(TYPE_TRAP)
		and (c:IsFaceup() or check and c:IsFacedown())
end
-- 特殊召唤规则的条件判定函数，检查场上是否存在满足送墓条件的3张陷阱卡，且能满足怪兽区域空位要求。
function c6007213.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查玩家是否受到卡片“陷阱收集者”的效果影响（允许将里侧表示的陷阱卡送去墓地）。
	local check=Duel.IsPlayerAffectedByEffect(tp,16317140)
	-- 获取自己场上所有满足送墓条件的陷阱卡组。
	local g=Duel.GetMatchingGroup(c6007213.spfilter,tp,LOCATION_ONFIELD,0,nil,check)
	-- 检查是否能从过滤出的卡片中选出3张卡，且这3张卡送去墓地后能腾出足够的怪兽区域空位。
	return g:CheckSubGroup(aux.mzctcheck,3,3,tp)
end
-- 特殊召唤规则的准备（选择）函数，让玩家选择3张要送去墓地的陷阱卡并保存。
function c6007213.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 检查玩家是否受到卡片“陷阱收集者”的效果影响。
	local check=Duel.IsPlayerAffectedByEffect(tp,16317140)
	-- 获取自己场上所有满足送墓条件的陷阱卡组。
	local g=Duel.GetMatchingGroup(c6007213.spfilter,tp,LOCATION_ONFIELD,0,nil,check)
	-- 给玩家发送提示信息，要求选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择3张满足怪兽区域空位要求的陷阱卡。
	local sg=g:SelectSubGroup(tp,aux.mzctcheck,true,3,3,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤规则的执行（操作）函数，将选中的卡送去墓地以完成特殊召唤。
function c6007213.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的卡作为特殊召唤的Cost送去墓地。
	Duel.SendtoGrave(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 过滤自己墓地的永续陷阱卡。
function c6007213.atkfilter(c)
	return c:GetType()==TYPE_TRAP+TYPE_CONTINUOUS
end
-- 攻击力上升数值的计算函数。
function c6007213.atkval(e,c)
	-- 计算自己墓地的永续陷阱卡数量并乘以1000，作为攻击力上升的数值。
	return Duel.GetMatchingGroupCount(c6007213.atkfilter,c:GetControler(),LOCATION_GRAVE,0,nil)*1000
end
-- 过滤里侧表示的卡片。
function c6007213.desfilter(c)
	return c:IsFacedown()
end
-- 破坏效果的发动准备（Target）函数，进行取对象、设置操作信息以及限制连锁的处理。
function c6007213.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(1-tp) and c6007213.desfilter(chkc) end
	-- 检查对方场上是否存在可以作为对象的里侧表示魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingTarget(c6007213.desfilter,tp,0,LOCATION_SZONE,1,nil) end
	-- 给玩家发送提示信息，要求选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张里侧表示的魔法·陷阱卡作为效果对象。
	local g=Duel.SelectTarget(tp,c6007213.desfilter,tp,0,LOCATION_SZONE,1,1,nil)
	-- 设置连锁的操作信息，表示该效果的处理为破坏选中的1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设定连锁限制，使得对方不能对应这个效果的发动把魔法·陷阱卡发动。
	Duel.SetChainLimit(c6007213.chainlimit)
end
-- 连锁限制判定函数，限制不能连锁发动魔法·陷阱卡（即EFFECT_TYPE_ACTIVATE类型的效果）。
function c6007213.chainlimit(e,rp,tp)
	return not e:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 破坏效果的执行（Operation）函数，将作为对象的里侧表示卡破坏。
function c6007213.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果处理中被选为对象的卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() and tc:IsRelateToEffect(e) then
		-- 将作为对象的卡片因效果破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
