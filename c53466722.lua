--始祖の竜王
-- 效果：
-- 通常怪兽×3
-- 这张卡不用融合召唤不能特殊召唤。这个卡名的③的效果1回合只能使用1次。
-- ①：「始祖之龙王」在自己场上只能有1张表侧表示存在。
-- ②：这张卡只要在怪兽区域存在，不会被战斗破坏，不受其他怪兽的效果影响。
-- ③：只在这张卡表侧表示存在才有1次，魔法·陷阱卡的效果发动时才能发动。场上的魔法·陷阱卡全部破坏。
local s,id,o=GetID()
-- 初始化效果函数，注册所有效果
function s.initial_effect(c)
	-- 添加融合召唤手续，需要3个通常怪兽作为融合素材
	aux.AddFusionProcFunRep(c,s.ffilter,3,true)
	c:EnableReviveLimit()
	c:SetUniqueOnField(1,0,id)
	-- 这个卡名的③的效果1回合只能使用1次。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该卡必须通过融合召唤特殊召唤
	e0:SetValue(aux.fuslimit)
	c:RegisterEffect(e0)
	-- 这张卡只要在怪兽区域存在，不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 这张卡只要在怪兽区域存在，不受其他怪兽的效果影响。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.immval)
	c:RegisterEffect(e2)
	-- 只在这张卡表侧表示存在才有1次，魔法·陷阱卡的效果发动时才能发动。场上的魔法·陷阱卡全部破坏。
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
-- 融合素材过滤函数，筛选通常怪兽类型
function s.ffilter(c)
	return c:IsFusionType(TYPE_NORMAL)
end
-- 效果免疫值判断函数，免疫非怪兽类型的对方效果
function s.immval(e,te)
	return te:GetOwner()~=e:GetHandler() and te:IsActiveType(TYPE_MONSTER)
end
-- 效果发动条件判断函数，确保在魔法或陷阱卡发动时且自身未被战斗破坏
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
-- 破坏目标过滤函数，筛选场上魔法或陷阱卡
function s.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 设置连锁处理的目标和信息，检查是否有魔法/陷阱卡存在并准备破坏
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件，即场上是否存在魔法或陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	e:GetHandler():RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))  --"已发动过效果"
	-- 获取场上所有魔法或陷阱卡组成的组
	local sg=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置连锁操作信息，指定将要破坏的卡组和数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 效果处理函数，执行破坏操作
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有魔法或陷阱卡组成的组
	local sg=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 以效果原因破坏指定卡组
	Duel.Destroy(sg,REASON_EFFECT)
end
