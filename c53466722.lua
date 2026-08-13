--始祖の竜王
-- 效果：
-- 通常怪兽×3
-- 这张卡不用融合召唤不能特殊召唤。这个卡名的③的效果1回合只能使用1次。
-- ①：「始祖之龙王」在自己场上只能有1张表侧表示存在。
-- ②：这张卡只要在怪兽区域存在，不会被战斗破坏，不受其他怪兽的效果影响。
-- ③：只在这张卡表侧表示存在才有1次，魔法·陷阱卡的效果发动时才能发动。场上的魔法·陷阱卡全部破坏。
local s,id,o=GetID()
-- 始祖之龙王的初始效果注册函数：为它添加以3只通常怪兽为素材的融合召唤手续、苏生限制、场上唯一性限制，并依次注册“只能通过融合召唤”、“不会被战斗破坏”、“不受其他怪兽效果影响”、“破坏场上全部魔法·陷阱卡”四个效果。
function s.initial_effect(c)
	-- 为始祖之龙王添加融合召唤手续，素材为3只满足s.ffilter条件的怪兽（这里是通常怪兽），insf为true表示允许作为融合素材的卡在场上或其他位置也能作为素材。
	aux.AddFusionProcFunRep(c,s.ffilter,3,true)
	c:EnableReviveLimit()
	c:SetUniqueOnField(1,0,id)
	-- 为这张卡添加特殊召唤条件效果：只有用融合召唤才能特殊召唤，对应效果原文“这张卡不用融合召唤不能特殊召唤。”
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 将特殊召唤条件判定值设为aux.fuslimit，即检查召唤类型是否为融合召唤，只有融合召唤才被允许。
	e0:SetValue(aux.fuslimit)
	c:RegisterEffect(e0)
	-- 为这张卡添加永续效果：只要在怪兽区域存在，不会被战斗破坏，对应效果原文“不会被战斗破坏”。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 为这张卡添加永续效果：只要在怪兽区域存在，不受其他怪兽的效果影响，对应效果原文“不受其他怪兽的效果影响”。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.immval)
	c:RegisterEffect(e2)
	-- 为这张卡添加诱发即时效果：在本卡表侧表示存在且魔法·陷阱卡效果发动时才能发动，发动后破坏场上全部魔法·陷阱卡，对应效果原文“③：只在这张卡表侧表示存在才有1次，魔法·陷阱卡的效果发动时才能发动。场上的魔法·陷阱卡全部破坏。”
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e3:SetCountLimit(1,id)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.descon)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
-- 定义融合素材筛选函数：素材必须是通常怪兽（作为融合素材时按原本类型判断）。
function s.ffilter(c)
	return c:IsFusionType(TYPE_NORMAL)
end
-- 定义免疫判定函数：只有其他怪兽发动的效果（且不是这张卡自身发动的效果）才会被免疫，本卡自身效果不免疫。
function s.immval(e,te)
	return te:GetOwner()~=e:GetHandler() and te:IsActiveType(TYPE_MONSTER)
end
-- 定义③效果的发动条件：这张卡未被战斗破坏确定，且当前连锁中发动的效果是魔法·陷阱卡的效果。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
-- 定义要破坏的卡牌筛选条件：场上的魔法·陷阱卡。
function s.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- ③效果的发动目标和操作信息设置：检测场上是否存在魔法·陷阱卡，存在则给自身标记“已发动过效果”的提示，并取场上全部魔法·陷阱卡设置为本次破坏的对象。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时合法性检查：在效果发动前确认场上至少有1张魔法·陷阱卡可供破坏。
	if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	e:GetHandler():RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))  --"已发动过效果"
	-- 获取当前场上所有魔法·陷阱卡作为集合，供后续设定破坏对象和数量。
	local sg=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置连锁处理信息：宣告本次效果将破坏上述集合中的所有魔法·陷阱卡，并记录数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- ③效果的实际处理函数：处理时再次获取场上所有魔法·陷阱卡并全部破坏。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时获取当前场上所有魔法·陷阱卡的集合。
	local sg=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 以效果破坏的原因将集合中的所有魔法·陷阱卡破坏。
	Duel.Destroy(sg,REASON_EFFECT)
end
