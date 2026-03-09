--ギガンテス
-- 效果：
-- 这张卡不能通常召唤。从自己墓地把1只地属性怪兽除外的场合可以特殊召唤。
-- ①：这张卡被战斗破坏送去墓地的场合发动。场上的魔法·陷阱卡全部破坏。
function c47606319.initial_effect(c)
	c:EnableReviveLimit()
	-- 从自己墓地把1只地属性怪兽除外的场合可以特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c47606319.spcon)
	e1:SetTarget(c47606319.sptg)
	e1:SetOperation(c47606319.spop)
	c:RegisterEffect(e1)
	-- 这张卡被战斗破坏送去墓地的场合发动。场上的魔法·陷阱卡全部破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(47606319,0))  --"魔法·陷阱卡全部破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetCondition(c47606319.condition)
	e2:SetTarget(c47606319.target)
	e2:SetOperation(c47606319.operation)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于筛选满足条件的地属性怪兽
function c47606319.spfilter(c)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsAbleToRemoveAsCost()
end
-- 判断是否满足特殊召唤条件
function c47606319.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查玩家场上是否有可用怪兽区域
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家墓地是否存在至少1只地属性怪兽
		and Duel.IsExistingMatchingCard(c47606319.spfilter,tp,LOCATION_GRAVE,0,1,nil)
end
-- 设置特殊召唤时的选择目标
function c47606319.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取满足条件的墓地中的地属性怪兽组
	local g=Duel.GetMatchingGroup(c47606319.spfilter,tp,LOCATION_GRAVE,0,nil)
	-- 向玩家发送提示信息，提示选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 执行特殊召唤的操作
function c47606319.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将指定卡片以特殊召唤理由除外
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
end
-- 判断该卡是否因战斗破坏而进入墓地
function c47606319.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 过滤函数，用于筛选魔法·陷阱卡
function c47606319.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 设置发动效果时的目标
function c47606319.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取场上的魔法·陷阱卡组
	local g=Duel.GetMatchingGroup(c47606319.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置当前处理的连锁的操作信息为破坏效果
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 执行破坏效果
function c47606319.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上的魔法·陷阱卡组
	local g=Duel.GetMatchingGroup(c47606319.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 以效果原因破坏指定卡片
	Duel.Destroy(g,REASON_EFFECT)
end
