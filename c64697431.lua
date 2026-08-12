--局所的ハリケーン
-- 效果：
-- ①：场上盖放的魔法·陷阱卡全部回到持有者手卡。
function c64697431.initial_effect(c)
	-- ①：场上盖放的魔法·陷阱卡全部回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c64697431.target)
	e1:SetOperation(c64697431.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：筛选场上里侧表示、属于魔法或陷阱卡且可以加入手卡的卡片
function c64697431.filter(c)
	return c:IsFacedown() and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果发动的目标检测与信息注册函数
function c64697431.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在发动检测时，检查场上是否存在至少1张满足过滤条件且非本卡自身的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c64697431.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
	-- 获取场上所有满足过滤条件且非本卡自身的卡片组
	local sg=Duel.GetMatchingGroup(c64697431.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
	-- 设置操作信息：将上述卡片组中的所有卡片送回手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,sg:GetCount(),0,0)
end
-- 效果处理的执行函数
function c64697431.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前场上所有满足过滤条件且不包括这张卡本身的卡片组
	local sg=Duel.GetMatchingGroup(c64697431.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	-- 将符合条件的卡片全部送回持有者的手卡
	Duel.SendtoHand(sg,nil,REASON_EFFECT)
end
