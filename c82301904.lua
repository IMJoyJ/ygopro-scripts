--混沌帝龍 －終焉の使者－
-- 效果：
-- 这张卡不能通常召唤。从自己墓地把光·暗属性怪兽各1只除外的场合才能特殊召唤。这张卡的效果发动的回合，自己不能把其他的效果发动。
-- ①：1回合1次，支付1000基本分才能发动。双方的手卡·场上的卡全部送去墓地。那之后，给与对方这个效果送去对方墓地的卡数量×300伤害。
function c82301904.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 从自己墓地把光·暗属性怪兽各1只除外的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(82301904,0))  --"特殊召唤"
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c82301904.spcon)
	e2:SetTarget(c82301904.sptg)
	e2:SetOperation(c82301904.spop)
	c:RegisterEffect(e2)
	-- ①：1回合1次，支付1000基本分才能发动。双方的手卡·场上的卡全部送去墓地。那之后，给与对方这个效果送去对方墓地的卡数量×300伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(82301904,1))  --"送墓"
	e3:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(c82301904.sgcost)
	e3:SetTarget(c82301904.sgtg)
	e3:SetOperation(c82301904.sgop)
	c:RegisterEffect(e3)
	-- 注册一个自定义活动计数器，用于记录玩家发动效果的次数（过滤函数为aux.FALSE表示记录所有效果的发动）。
	Duel.AddCustomActivityCounter(82301904,ACTIVITY_CHAIN,aux.FALSE)
end
-- 特殊召唤所需除外怪兽的过滤条件：可以作为Cost除外，且是光属性或暗属性。
function c82301904.spcostfilter(c)
	return c:IsAbleToRemoveAsCost() and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)
end
-- 特殊召唤规则的条件判定函数：检查怪兽区域空位以及墓地是否存在光·暗属性怪兽各1只。
function c82301904.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否有可用的怪兽区域。
	if Duel.GetMZoneCount(tp)<=0 then return false end
	-- 获取自己墓地中满足除外条件的光·暗属性怪兽。
	local g=Duel.GetMatchingGroup(c82301904.spcostfilter,tp,LOCATION_GRAVE,0,nil)
	-- 检查墓地中是否存在光属性和暗属性怪兽各1只的组合。
	return g:CheckSubGroup(aux.gfcheck,2,2,Card.IsAttribute,ATTRIBUTE_LIGHT,ATTRIBUTE_DARK)
end
-- 特殊召唤规则的素材选择函数：让玩家从墓地选择光属性和暗属性怪兽各1只。
function c82301904.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己墓地中满足除外条件的光·暗属性怪兽。
	local g=Duel.GetMatchingGroup(c82301904.spcostfilter,tp,LOCATION_GRAVE,0,nil)
	-- 提示玩家选择要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家必须选择光属性和暗属性怪兽各1只。
	local sg=g:SelectSubGroup(tp,aux.gfcheck,true,2,2,Card.IsAttribute,ATTRIBUTE_LIGHT,ATTRIBUTE_DARK)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤规则的执行函数：将选中的怪兽除外并完成特殊召唤。
function c82301904.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local sg=e:GetLabelObject()
	-- 将选中的怪兽以特殊召唤的素材原因表侧表示除外。
	Duel.Remove(sg,POS_FACEUP,REASON_SPSUMMON)
	sg:DeleteGroup()
end
-- 效果发动的Cost与限制条件：支付1000基本分，且本回合不能发动其他效果。
function c82301904.sgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否能支付1000基本分，且本回合在此之前没有发动过其他效果。
	if chk==0 then return Duel.CheckLPCost(tp,1000) and Duel.GetCustomActivityCount(82301904,tp,ACTIVITY_CHAIN)==0 end
	-- 支付1000基本分。
	Duel.PayLPCost(tp,1000)
	-- 这张卡的效果发动的回合，自己不能把其他的效果发动。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	-- 设置不能发动任何效果（始终返回true，即所有效果都不能发动）。
	e1:SetValue(aux.TRUE)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 给玩家注册该回合内不能发动其他效果的限制。
	Duel.RegisterEffect(e1,tp)
end
-- 伤害计算过滤条件：卡片的原本持有者为指定玩家，且该卡可以送去墓地。
function c82301904.damfilter(c,p)
	return c:GetOwner()==p and c:IsAbleToGrave()
end
-- 效果发动的目标确认与操作信息设置：获取双方手牌和场上的所有卡，并预估送墓和伤害数值。
function c82301904.sgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取双方手牌和场上的所有卡片。
	local g=Duel.GetFieldGroup(tp,0xe,0xe)
	local dc=g:FilterCount(c82301904.damfilter,nil,1-tp)
	-- 设置送去墓地的操作信息，包含双方手牌和场上的所有卡。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount(),0,0)
	-- 设置伤害的操作信息，预估给与对方的伤害数值（对方送去墓地的卡数量×300）。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,1-tp,dc*300)
end
-- 实际送墓卡片的过滤条件：卡片当前在墓地，且控制者为指定玩家。
function c82301904.sgfilter(c,p)
	return c:IsLocation(LOCATION_GRAVE) and c:IsControler(p)
end
-- 效果处理的执行函数：将双方手牌和场上的卡全部送去墓地，并根据送去对方墓地的卡片数量给与对方伤害。
function c82301904.sgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方手牌和场上的所有卡片。
	local g=Duel.GetFieldGroup(tp,0xe,0xe)
	-- 因效果将双方手牌和场上的所有卡片送去墓地。
	Duel.SendtoGrave(g,REASON_EFFECT)
	-- 获取本次送去墓地操作实际影响的卡片组。
	local og=Duel.GetOperatedGroup()
	local ct=og:FilterCount(c82301904.sgfilter,nil,1-tp)
	if ct>0 then
		-- 中断当前效果，使后续的伤害处理与送墓不视为同时处理。
		Duel.BreakEffect()
		-- 给与对方送去对方墓地的卡数量×300的伤害。
		Duel.Damage(1-tp,ct*300,REASON_EFFECT)
	end
end
