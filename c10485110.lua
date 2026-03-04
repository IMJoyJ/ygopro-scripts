--海竜神－ネオダイダロス
-- 效果：
-- 这张卡不能通常召唤。把自己场上存在的1只「海龙-泰达路斯」解放的场合才能特殊召唤。可以通过把自己场上存在的「海」送去墓地，这张卡以外的双方的手卡·场上的卡全部送去墓地。
function c10485110.initial_effect(c)
	-- 为卡片注册与「海龙-泰达路斯」相关的代码列表，用于后续效果判断
	aux.AddCodeList(c,22702055)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该卡无法通过任何方式特殊召唤（即不能通常召唤）
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 把自己场上存在的1只「海龙-泰达路斯」解放的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c10485110.spcon)
	e2:SetTarget(c10485110.sptg)
	e2:SetOperation(c10485110.spop)
	c:RegisterEffect(e2)
	-- 可以通过把自己场上存在的「海」送去墓地，这张卡以外的双方的手卡·场上的卡全部送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(10485110,0))  --"送墓"
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c10485110.cost)
	e3:SetTarget(c10485110.target)
	e3:SetOperation(c10485110.operation)
	c:RegisterEffect(e3)
end
-- 定义用于判断是否可以解放的过滤函数，检查场上是否存在满足条件的「海龙-泰达路斯」
function c10485110.spfilter(c,tp)
	-- 检查目标卡片是否为表侧表示、卡片代码为「海龙-泰达路斯」且当前玩家场上存在可用怪兽区
	return c:IsFaceup() and c:IsCode(37721209) and Duel.GetMZoneCount(tp,c)>0
end
-- 定义特殊召唤条件函数，用于判断是否满足特殊召唤的条件
function c10485110.spcon(e,c)
	if c==nil then return true end
	-- 检查当前玩家场上是否存在至少一张满足spfilter条件的可解放卡片
	return Duel.CheckReleaseGroupEx(c:GetControler(),c10485110.spfilter,1,REASON_SPSUMMON,false,nil,c:GetControler())
end
-- 定义特殊召唤目标选择函数，用于选择要解放的卡片
function c10485110.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取当前玩家可解放的卡片组，并从中筛选出符合条件的「海龙-泰达路斯」
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c10485110.spfilter,nil,tp)
	-- 向玩家发送提示信息，提示其选择要解放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 定义特殊召唤执行函数，用于执行实际的解放操作
function c10485110.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将指定的卡片组进行解放操作
	Duel.Release(g,REASON_SPSUMMON)
end
-- 定义用于判断是否可以作为cost送入墓地的过滤函数，检查场上是否存在满足条件的「海」
function c10485110.cfilter(c)
	return c:IsFaceup() and c:IsCode(22702055) and c:IsAbleToGraveAsCost()
end
-- 定义效果发动时的费用支付函数
function c10485110.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查当前玩家场上是否存在至少一张满足cfilter条件的可送入墓地的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c10485110.cfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 向玩家发送提示信息，提示其选择要送入墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	-- 选择满足条件的1张卡片作为送入墓地的费用
	local g=Duel.SelectMatchingCard(tp,c10485110.cfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 将选中的卡片送入墓地作为费用
	Duel.SendtoGrave(g,REASON_COST)
end
-- 定义效果的目标选择函数
function c10485110.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查当前玩家是否至少存在一张满足任意条件的卡片（用于判断效果是否可以发动）
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0xe,0xe,1,e:GetHandler()) end
	-- 获取双方手卡和场上的所有卡片
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0xe,0xe,e:GetHandler())
	-- 设置效果发动时的操作信息，指定将要处理的卡片数量和类型
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount(),0,0)
end
-- 定义效果的执行函数
function c10485110.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方手卡和场上的所有卡片（排除自身）
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0xe,0xe,aux.ExceptThisCard(e))
	-- 将符合条件的卡片全部送入墓地
	Duel.SendtoGrave(g,REASON_EFFECT)
end
