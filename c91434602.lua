--マジェスティ・ヒュペリオン
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次。
-- ①：这张卡可以把自己的手卡·场上·墓地1只「代行者」怪兽除外，从手卡·墓地特殊召唤。
-- ②：自己的天使族怪兽的战斗发生的对自己的战斗伤害让对方也承受。
-- ③：1回合1次，从自己的手卡·墓地把1只天使族怪兽除外，以自己或者对方的墓地1张卡为对象才能发动。那张卡除外。场上或者墓地有「天空的圣域」存在的场合，这个效果1回合可以使用最多2次。
function c91434602.initial_effect(c)
	-- 注册卡片关联密码（天空的圣域），用于卡片效果文本中提及该卡名的相关检测
	aux.AddCodeList(c,56433456)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：这张卡可以把自己的手卡·场上·墓地1只「代行者」怪兽除外，从手卡·墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,91434602+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c91434602.hspcon)
	e1:SetTarget(c91434602.hsptg)
	e1:SetOperation(c91434602.hspop)
	c:RegisterEffect(e1)
	-- ②：自己的天使族怪兽的战斗发生的对自己的战斗伤害让对方也承受。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_ALSO_BATTLE_DAMAGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 设置效果影响的对象为天使族怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_FAIRY))
	c:RegisterEffect(e2)
	-- ③：1回合1次，从自己的手卡·墓地把1只天使族怪兽除外，以自己或者对方的墓地1张卡为对象才能发动。那张卡除外。场上或者墓地有「天空的圣域」存在的场合，这个效果1回合可以使用最多2次。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(91434602,0))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c91434602.rmcon)
	e3:SetCost(c91434602.rmcost)
	e3:SetTarget(c91434602.rmtg)
	e3:SetOperation(c91434602.rmop)
	c:RegisterEffect(e3)
end
-- 特殊召唤规则所需要的除外卡片的过滤条件（「代行者」怪兽）
function c91434602.spcfilter(c,tp)
	return c:IsSetCard(0x44) and (not c:IsLocation(LOCATION_MZONE) or c:IsFaceup())
		-- 检查卡片是否能作为Cost除外，且除外该卡后是否有可用的怪兽区域用于特殊召唤
		and c:IsAbleToRemoveAsCost() and Duel.GetMZoneCount(tp,c)>0
end
-- 特殊召唤规则的条件判定函数
function c91434602.hspcon(e,c)
	if c==nil then return true end
	if c:IsHasEffect(EFFECT_NECRO_VALLEY) then return false end
	local tp=c:GetControler()
	-- 检查自己的手卡、场上、墓地是否存在至少1只满足特殊召唤条件的「代行者」怪兽
	return Duel.IsExistingMatchingCard(c91434602.spcfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,tp)
end
-- 特殊召唤规则的目标选择函数
function c91434602.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己手卡、场上、墓地所有满足特殊召唤条件的「代行者」怪兽
	local g=Duel.GetMatchingGroup(c91434602.spcfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,nil,tp)
	-- 给玩家发送提示信息，提示选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤规则的具体执行操作函数
function c91434602.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选择的怪兽表侧表示除外，作为特殊召唤的代价
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
end
-- 效果③的发动条件判定函数（根据「天空的圣域」是否存在来决定每回合可发动的次数上限）
function c91434602.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上或双方墓地是否存在「天空的圣域」
	local check=Duel.IsEnvironment(56433456,PLAYER_ALL,LOCATION_ONFIELD+LOCATION_GRAVE)
	if check then return e:GetHandler():GetFlagEffect(91434602)<2
	else return e:GetHandler():GetFlagEffect(91434602)<1 end
end
-- 效果③发动代价（Cost）所需要的除外卡片的过滤条件（天使族怪兽）
function c91434602.costfilter(c,tp)
	return c:IsRace(RACE_FAIRY) and c:IsAbleToRemoveAsCost()
		-- 检查除外该Cost卡后，双方墓地是否仍有至少1张可以被除外的卡作为效果对象
		and Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,c)
end
-- 效果③的发动代价（Cost）处理函数
function c91434602.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手卡或墓地是否存在可作为Cost除外的天使族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c91434602.costfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,tp) end
	-- 给玩家发送提示信息，提示选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家选择自己手卡或墓地1只天使族怪兽
	local g=Duel.SelectMatchingCard(tp,c91434602.costfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,tp)
	-- 将选择的天使族怪兽表侧表示除外，作为发动的代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果③的目标选择与发动准备函数
function c91434602.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsAbleToRemove() end
	-- 检查双方墓地是否存在至少1张可以除外的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	-- 给玩家发送提示信息，提示选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择自己或对方墓地1张可以除外的卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	-- 设置效果处理信息，表示该效果将除外1张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	e:GetHandler():RegisterFlagEffect(91434602,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 效果③的效果处理（Operation）函数
function c91434602.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择为效果对象的卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将作为对象的卡表侧表示除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
