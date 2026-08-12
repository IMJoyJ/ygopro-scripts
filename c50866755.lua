--鳳凰
-- 效果：
-- 这张卡不能特殊召唤。召唤·反转的回合的结束阶段时回到持有者手卡。这张卡召唤·反转时，对方场上盖放的魔法·陷阱卡全部破坏。
function c50866755.initial_effect(c)
	-- 为卡片添加在召唤或反转时回到手卡的效果
	aux.EnableSpiritReturn(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该效果使卡片无法被特殊召唤
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
-- 过滤函数，用于判断目标卡片是否为里侧表示
function c50866755.filter(c)
	return c:IsFacedown()
end
-- 设定连锁处理的目标为对方场上的里侧表示魔法·陷阱卡，并设置破坏分类
function c50866755.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取对方场上所有里侧表示的魔法·陷阱卡
	local g=Duel.GetMatchingGroup(c50866755.filter,tp,0,LOCATION_SZONE,nil)
	-- 设置当前连锁操作信息为破坏效果，目标为上一步获取的卡片组
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 执行破坏效果，将目标卡片全部破坏
function c50866755.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 再次获取对方场上所有里侧表示的魔法·陷阱卡
	local g=Duel.GetMatchingGroup(c50866755.filter,tp,0,LOCATION_SZONE,nil)
	-- 调用Duel.Destroy函数，以效果原因破坏目标卡片
	Duel.Destroy(g,REASON_EFFECT)
end
