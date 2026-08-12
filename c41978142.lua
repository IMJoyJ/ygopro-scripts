--霞の谷の執行者
-- 效果：
-- 这张卡召唤成功时，场上表侧表示存在的魔法·陷阱卡全部回到持有者手卡。
function c41978142.initial_effect(c)
	-- 这张卡召唤成功时，场上表侧表示存在的魔法·陷阱卡全部回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41978142,0))  --"返回手牌"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c41978142.thtg)
	e1:SetOperation(c41978142.thop)
	c:RegisterEffect(e1)
end
-- 过滤函数，返回满足条件的魔法·陷阱卡：表侧表示、类型为魔法或陷阱、可以送去手卡
function c41978142.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果处理时的目标设定函数，用于确定要送回手卡的魔法·陷阱卡组
function c41978142.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 检索满足条件的魔法·陷阱卡组，位置为场上
	local g=Duel.GetMatchingGroup(c41978142.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置连锁操作信息，指定效果分类为回手牌，目标卡组为场上符合条件的魔法·陷阱卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果处理函数，将符合条件的魔法·陷阱卡送回手牌
function c41978142.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 检索满足条件的魔法·陷阱卡组，位置为场上
	local g=Duel.GetMatchingGroup(c41978142.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 将卡组中的魔法·陷阱卡以效果原因送回手牌
	Duel.SendtoHand(g,nil,REASON_EFFECT)
end
