--シルフィード
-- 效果：
-- 这张卡不能进行通常召唤。从自己墓地里除外1只风属性怪兽进行特殊召唤。这张卡被战斗破坏送去墓地时，对方随机丢弃1张手卡。
function c73001017.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能进行通常召唤。从自己墓地里除外1只风属性怪兽进行特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c73001017.spcon)
	e1:SetTarget(c73001017.sptg)
	e1:SetOperation(c73001017.spop)
	c:RegisterEffect(e1)
	-- 这张卡被战斗破坏送去墓地时，对方随机丢弃1张手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(73001017,0))
	e2:SetCategory(CATEGORY_HANDES_OPPO)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetCondition(c73001017.condition)
	e2:SetTarget(c73001017.target)
	e2:SetOperation(c73001017.operation)
	c:RegisterEffect(e2)
end
-- 过滤自己墓地中可以作为特殊召唤Cost除外的风属性怪兽
function c73001017.spfilter(c)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsAbleToRemoveAsCost()
end
-- 特殊召唤规则的条件判定函数
function c73001017.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否有可用的怪兽区域
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只满足过滤条件的风属性怪兽
		and Duel.IsExistingMatchingCard(c73001017.spfilter,tp,LOCATION_GRAVE,0,1,nil)
end
-- 特殊召唤规则的目标选择函数，用于选择作为特殊召唤Cost除外的怪兽
function c73001017.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己墓地中所有满足过滤条件的风属性怪兽
	local g=Duel.GetMatchingGroup(c73001017.spfilter,tp,LOCATION_GRAVE,0,nil)
	-- 给玩家发送“请选择要除外的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤规则的执行操作函数
function c73001017.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的怪兽表侧表示除外，作为特殊召唤的Cost
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
end
-- 判定此卡是否在墓地且是因为战斗破坏而送去墓地
function c73001017.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 效果发动的目标确认与操作信息设置函数
function c73001017.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_HANDES_OPPO,nil,0,1-tp,1)
end
-- 效果的具体处理函数，执行对方随机丢弃手卡的操作
function c73001017.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方的所有手卡
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if g:GetCount()==0 then return end
	local sg=g:RandomSelect(1-tp,1)
	-- 将选中的手卡以效果丢弃的方式送去墓地
	Duel.SendtoGrave(sg,REASON_DISCARD+REASON_EFFECT)
end
