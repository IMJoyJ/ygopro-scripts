--天魔神 ノーレラス
-- 效果：
-- 这张卡不能通常召唤。从自己墓地把1只天使族·光属性怪兽和3只恶魔族·暗属性怪兽除外的场合才能特殊召唤。
-- ①：支付1000基本分才能发动。双方的手卡·场上的卡全部送去墓地，自己从卡组抽1张。
function c48453776.initial_effect(c)
	c:EnableReviveLimit()
	-- 对应效果原文“从自己墓地把1只天使族·光属性怪兽和3只恶魔族·暗属性怪兽除外的场合才能特殊召唤。”中的“才能特殊召唤”限制：将特殊召唤条件设为false，使该卡不能通过其他方式特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 将特殊召唤条件的值设为false，使该卡被其他方式特殊召唤的尝试均判定为不合法。
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 对应效果原文“从自己墓地把1只天使族·光属性怪兽和3只恶魔族·暗属性怪兽除外的场合才能特殊召唤。”：提供这个特殊召唤手续本身，通过除外指定素材来特殊召唤此卡。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c48453776.spcon)
	e2:SetTarget(c48453776.sptg)
	e2:SetOperation(c48453776.spop)
	c:RegisterEffect(e2)
	-- 对应效果原文“①：支付1000基本分才能发动。双方的手卡·场上的卡全部送去墓地，自己从卡组抽1张。”
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
-- 定义素材筛选条件1：检查怪兽是否为光属性天使族，用于选出需要除外的1只天使族·光属性怪兽。
function c48453776.spfilter1(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_FAIRY)
end
-- 定义素材筛选条件2：检查怪兽是否为暗属性恶魔族，用于选出需要除外的3只恶魔族·暗属性怪兽。
function c48453776.spfilter2(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_FIEND)
end
c48453776.spchecks={c48453776.spfilter1,c48453776.spfilter2,c48453776.spfilter2,c48453776.spfilter2}
-- 统合素材筛选函数：选出墓地中属于光属性天使族或暗属性恶魔族，并且能够作为除外代价的怪兽，作为特殊召唤素材的候选集。
function c48453776.spfilter(c)
	return ((c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_LIGHT)) or (c:IsRace(RACE_FIEND) and c:IsAttribute(ATTRIBUTE_DARK)))
		and c:IsAbleToRemoveAsCost()
end
-- 特殊召唤手续的发动条件：自己场上存在空闲的主要怪兽区，且自己墓地存在可组成1只光属性天使族和3只暗属性恶魔族的素材组合。
function c48453776.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取自己墓地中所有可以作为特殊召唤素材的怪兽集合，用于检查是否存在满足条件的组合。
	local g=Duel.GetMatchingGroup(c48453776.spfilter,tp,LOCATION_GRAVE,0,nil)
	-- 判断自己场上是否还有空余的主要怪兽区，以确保特殊召唤时有位置放置这张卡。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and g:CheckSubGroupEach(c48453776.spchecks)
end
-- 特殊召唤手续的素材选择：从符合条件的墓地怪兽中自动选出1只光属性天使族和3只暗属性恶魔族作为除外素材；成功选择则保存素材并允许发动，否则无法发动。
function c48453776.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己墓地中所有可以作为特殊召唤素材的怪兽集合，供自动选择函数使用。
	local g=Duel.GetMatchingGroup(c48453776.spfilter,tp,LOCATION_GRAVE,0,nil)
	-- 显示“请选择要除外的卡”的选择提示，引导玩家进行素材选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:SelectSubGroupEach(tp,c48453776.spchecks,true)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤手续的执行：将之前选择保存的素材（1只光属性天使族和3只暗属性恶魔族）从墓地除外，然后特殊召唤这张卡。
function c48453776.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的素材卡以表侧表示从墓地除外，除外原因记为特殊召唤（REASON_SPSUMMON），作为这次特殊召唤的代价。
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 起动效果的代价处理：检查并支付1000基本分作为卡牌效果的发动费用。
function c48453776.sgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在代价检查阶段（chk==0）判断当前玩家能否支付1000LP，以决定效果能否发动。
	if chk==0 then return Duel.CheckLPCost(tp,1000)
	-- 在效果实际发动时，支付1000LP作为代价。
	else Duel.PayLPCost(tp,1000) end
end
-- 起动效果的目标设定：确认自己可以抽1张卡，并获取双方手牌与场上所有卡作为送墓对象，同时登记送墓与抽卡的操作信息。
function c48453776.sgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查阶段确认当前玩家是否可以抽1张卡，若不能则效果不能发动。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 获取双方手牌及场上的所有卡（手牌、怪兽区、魔陷区），用于后续全部送去墓地。
	local g=Duel.GetFieldGroup(tp,0xe,0xe)
	-- 向系统登记“将上述所有卡送去墓地”的操作信息，数量为这些卡的总数，以支持相关效果判定。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount(),0,0)
	-- 向系统登记“自己抽1张卡”的操作信息，以支持抽卡相关效果判定。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,0,0,tp,1)
end
-- 起动效果的实际处理：将双方手牌和场上的所有卡全部送去墓地，然后自己从卡组抽1张卡。
function c48453776.sgop(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时再次获取双方手牌和场上的所有卡，确保送墓的是处理时实际在场的卡。
	local g=Duel.GetFieldGroup(tp,0xe,0xe)
	-- 将双方手牌和场上的所有卡以效果原因（REASON_EFFECT）全部送去墓地。
	Duel.SendtoGrave(g,REASON_EFFECT)
	-- 自己以效果原因（REASON_EFFECT）从卡组抽1张卡。
	Duel.Draw(tp,1,REASON_EFFECT)
end
