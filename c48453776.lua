--天魔神 ノーレラス
-- 效果：
-- 这张卡不能通常召唤。从自己墓地把1只天使族·光属性怪兽和3只恶魔族·暗属性怪兽除外的场合才能特殊召唤。
-- ①：支付1000基本分才能发动。双方的手卡·场上的卡全部送去墓地，自己从卡组抽1张。
function c48453776.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该卡无法被特殊召唤，强制返回假值以阻止通常召唤。
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- ①：支付1000基本分才能发动。双方的手卡·场上的卡全部送去墓地，自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c48453776.spcon)
	e2:SetTarget(c48453776.sptg)
	e2:SetOperation(c48453776.spop)
	c:RegisterEffect(e2)
	-- 从自己墓地把1只天使族·光属性怪兽和3只恶魔族·暗属性怪兽除外的场合才能特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(48453776,0))  --"送墓"
	e3:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c48453776.sgcost)
	e3:SetTarget(c48453776.sgtg)
	e3:SetOperation(c48453776.sgop)
	c:RegisterEffect(e3)
end
-- 筛选满足条件的天使族·光属性怪兽的过滤函数。
function c48453776.spfilter1(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_FAIRY)
end
-- 筛选满足条件的恶魔族·暗属性怪兽的过滤函数。
function c48453776.spfilter2(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_FIEND)
end
c48453776.spchecks={c48453776.spfilter1,c48453776.spfilter2,c48453776.spfilter2,c48453776.spfilter2}
-- 综合筛选墓地中的天使族·光属性或恶魔族·暗属性怪兽，且可作为除外费用的过滤函数。
function c48453776.spfilter(c)
	return ((c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_LIGHT)) or (c:IsRace(RACE_FIEND) and c:IsAttribute(ATTRIBUTE_DARK)))
		and c:IsAbleToRemoveAsCost()
end
-- 判断是否满足特殊召唤条件：场上存在空位并能从墓地中选出符合条件的卡组。
function c48453776.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取满足特殊召唤条件的卡组。
	local g=Duel.GetMatchingGroup(c48453776.spfilter,tp,LOCATION_GRAVE,0,nil)
	-- 检查玩家是否有足够的怪兽区域进行特殊召唤。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and g:CheckSubGroupEach(c48453776.spchecks)
end
-- 设置特殊召唤时选择要除外的卡组，并将选中的卡组保存到效果标签中。
function c48453776.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取满足特殊召唤条件的卡组。
	local g=Duel.GetMatchingGroup(c48453776.spfilter,tp,LOCATION_GRAVE,0,nil)
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:SelectSubGroupEach(tp,c48453776.spchecks,true)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 执行特殊召唤操作，将选中的卡除外。
function c48453776.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的卡以除外形式移除。
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 支付1000基本分作为效果发动费用。
function c48453776.sgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付1000基本分。
	if chk==0 then return Duel.CheckLPCost(tp,1000)
	-- 若满足条件则支付1000基本分。
	else Duel.PayLPCost(tp,1000) end
end
-- 设置效果目标：双方手卡和场上的卡全部送去墓地，自己抽一张卡。
function c48453776.sgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽一张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 获取双方手卡和场上的所有卡。
	local g=Duel.GetFieldGroup(tp,0xe,0xe)
	-- 设置操作信息：将场上及手牌的卡送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount(),0,0)
	-- 设置操作信息：自己从卡组抽一张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,0,0,tp,1)
end
-- 执行效果处理：将场上及手牌的卡送去墓地，然后自己抽一张卡。
function c48453776.sgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方手卡和场上的所有卡。
	local g=Duel.GetFieldGroup(tp,0xe,0xe)
	-- 将这些卡以效果原因送去墓地。
	Duel.SendtoGrave(g,REASON_EFFECT)
	-- 让玩家从卡组抽一张卡。
	Duel.Draw(tp,1,REASON_EFFECT)
end
