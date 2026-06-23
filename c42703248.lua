--ハリケーン
-- 效果：
-- 场上的魔法·陷阱卡全部回到持有者手卡。
function c42703248.initial_effect(c)
	-- 卡片效果初始化，设置为发动时点、回手牌效果、自由连锁
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c42703248.target)
	e1:SetOperation(c42703248.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选魔法·陷阱卡且可以送入手卡的卡片
function c42703248.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果的发动时点处理函数，检查场上是否存在满足条件的卡片并设置操作信息
function c42703248.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断是否满足发动条件，检查场上是否存在至少一张魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c42703248.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
	-- 获取场上所有满足条件的魔法·陷阱卡组成的组
	local sg=Duel.GetMatchingGroup(c42703248.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
	-- 设置连锁操作信息，指定将这些卡送入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,sg:GetCount(),0,0)
end
-- 效果发动时的处理函数，执行将符合条件的卡送入手卡的操作
function c42703248.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有满足条件的魔法·陷阱卡组成的组，排除自身
	local sg=Duel.GetMatchingGroup(c42703248.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	-- 将这些卡以效果原因送入持有者手卡
	Duel.SendtoHand(sg,nil,REASON_EFFECT)
end
