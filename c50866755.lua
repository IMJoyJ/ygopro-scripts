--鳳凰
-- 效果：
-- 这张卡不能特殊召唤。召唤·反转的回合的结束阶段时回到持有者手卡。这张卡召唤·反转时，对方场上盖放的魔法·陷阱卡全部破坏。
function c50866755.initial_effect(c)
	-- 为凤凰添加灵魂怪兽效果：在召唤·反转的回合的结束阶段时回到持有者手卡。
	aux.EnableSpiritReturn(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件判定为假，即禁止这张卡特殊召唤。
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 这张卡召唤·反转时，对方场上盖放的魔法·陷阱卡全部破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(50866755,1))  --"破坏"
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetTarget(c50866755.destg)
	e4:SetOperation(c50866755.desop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_FLIP)
	c:RegisterEffect(e5)
end
-- 定义筛选条件：选取对方场上里侧表示的魔法·陷阱卡。
function c50866755.filter(c)
	return c:IsFacedown()
end
-- 破坏效果的发动条件成立时，获取对方场上里侧表示的魔法·陷阱卡，并将破坏信息登记到操作信息中。
function c50866755.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取对方场上所有里侧表示的魔法·陷阱卡。
	local g=Duel.GetMatchingGroup(c50866755.filter,tp,0,LOCATION_SZONE,nil)
	-- 登记本次连锁的破坏操作信息：对象为g（对方里侧魔陷），数量为g的数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理时执行破坏：重新获取对方场上里侧表示的魔法·陷阱卡并全部破坏。
function c50866755.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新获取对方场上所有里侧表示的魔法·陷阱卡。
	local g=Duel.GetMatchingGroup(c50866755.filter,tp,0,LOCATION_SZONE,nil)
	-- 以效果原因将这些卡片全部破坏。
	Duel.Destroy(g,REASON_EFFECT)
end
