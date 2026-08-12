--マスター・ヒュペリオン
-- 效果：
-- ①：这张卡可以把自己的手卡·场上·墓地1只「代行者」怪兽除外，从手卡特殊召唤。
-- ②：1回合1次，从自己墓地把1只天使族·光属性怪兽除外，以场上1张卡为对象才能发动。那张卡破坏。场上有「天空的圣域」存在的场合，这个效果1回合可以使用最多2次。
function c55794644.initial_effect(c)
	-- 注册卡片记有「天空的圣域」卡名的信息
	aux.AddCodeList(c,56433456)
	-- ①：这张卡可以把自己的手卡·场上·墓地1只「代行者」怪兽除外，从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c55794644.hspcon)
	e1:SetTarget(c55794644.hsptg)
	e1:SetOperation(c55794644.hspop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，从自己墓地把1只天使族·光属性怪兽除外，以场上1张卡为对象才能发动。那张卡破坏。场上有「天空的圣域」存在的场合，这个效果1回合可以使用最多2次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(55794644,0))  --"场上存在的1张卡破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c55794644.condition)
	e2:SetCost(c55794644.cost)
	e2:SetTarget(c55794644.target)
	e2:SetOperation(c55794644.operation)
	c:RegisterEffect(e2)
end
-- 过滤自身特殊召唤所需除外的「代行者」怪兽的条件：手卡、场上、墓地的「代行者」怪兽，且除外后自身能特殊召唤到怪兽区域
function c55794644.spfilter(c,tp)
	return c:IsSetCard(0x44) and c:IsAbleToRemoveAsCost() and (not c:IsLocation(LOCATION_MZONE) or c:IsFaceup())
		-- 检查将该卡除外后，是否有可用的怪兽区域用于特殊召唤
		and Duel.GetMZoneCount(tp,c)>0
end
-- 特殊召唤规则的条件函数：检查自己手卡、场上、墓地是否存在至少1只满足条件的「代行者」怪兽
function c55794644.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查手卡、场上、墓地是否存在至少1只满足条件的「代行者」怪兽
	return Duel.IsExistingMatchingCard(c55794644.spfilter,tp,0x16,0,1,nil,tp)
end
-- 特殊召唤规则的选择目标步骤：让玩家选择1只用于除外的「代行者」怪兽
function c55794644.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取手卡、场上、墓地所有满足条件的「代行者」怪兽
	local g=Duel.GetMatchingGroup(c55794644.spfilter,tp,0x16,0,nil,tp)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤规则的执行步骤：将选中的「代行者」怪兽除外
function c55794644.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的怪兽表侧表示除外（作为特殊召唤的手续）
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
end
-- 效果②的发动条件：根据场上是否存在「天空的圣域」来判断本回合已发动的次数是否小于限制（存在时最多2次，否则最多1次）
function c55794644.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 若场上有「天空的圣域」存在，则检查本回合该效果发动次数是否小于2次
	if Duel.IsEnvironment(56433456) then return e:GetHandler():GetFlagEffect(55794644)<2
	else return e:GetHandler():GetFlagEffect(55794644)<1 end
end
-- 过滤效果②所需除外的怪兽条件：自己墓地的天使族·光属性怪兽
function c55794644.costfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_FAIRY) and c:IsAbleToRemoveAsCost()
end
-- 效果②的发动代价：从自己墓地把1只天使族·光属性怪兽除外
function c55794644.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少1只天使族·光属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c55794644.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家选择自己墓地1只天使族·光属性怪兽
	local g=Duel.SelectMatchingCard(tp,c55794644.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的怪兽表侧表示除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果②的发动准备：选择场上1张卡作为对象，并注册本回合的发动次数标记
function c55794644.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 检查场上是否存在可以作为对象的卡
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择场上1张卡作为效果对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息为破坏选中的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	e:GetHandler():RegisterFlagEffect(55794644,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 效果②的效果处理：将作为对象的卡破坏
function c55794644.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将该卡因效果破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
