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
-- 过滤函数：判定卡片是否为表侧表示、是否为魔法·陷阱卡、以及是否可以被加入手卡。
function c41978142.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 发动目标处理：发动时无条件允许（必发效果无需发动条件），获取场上所有符合条件的魔法·陷阱卡，并设置本连锁将把这些卡加入手卡的操作信息。
function c41978142.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取双方场上所有表侧表示且符合条件的魔法·陷阱卡（用于操作信息统计）。
	local g=Duel.GetMatchingGroup(c41978142.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置操作信息：本效果处理时将把取得的卡全部加入手卡，数量为g中的卡数。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果处理函数：处理时再次取得场上所有符合条件的魔法·陷阱卡，并将它们全部返回持有者手卡。
function c41978142.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方场上所有表侧表示且符合条件的魔法·陷阱卡（用于实际处理）。
	local g=Duel.GetMatchingGroup(c41978142.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 将所有符合条件的卡以效果缘故返回持有者手卡。
	Duel.SendtoHand(g,nil,REASON_EFFECT)
end
