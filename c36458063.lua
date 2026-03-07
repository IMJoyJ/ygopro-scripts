--魔女の一撃
-- 效果：
-- ①：对方把怪兽的召唤·特殊召唤无效的场合或者对方把魔法·陷阱·怪兽的效果的发动无效的场合才能发动。对方的手卡·场上的卡全部破坏。
function c36458063.initial_effect(c)
	-- 效果原文内容：①：对方把怪兽的召唤·特殊召唤无效的场合或者对方把魔法·陷阱·怪兽的效果的发动无效的场合才能发动。对方的手卡·场上的卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_NEGATED)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(c36458063.condition1)
	e1:SetTarget(c36458063.target)
	e1:SetOperation(c36458063.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_NEGATED)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_CUSTOM+36458063)
	c:RegisterEffect(e3)
	if not c36458063.global_check then
		c36458063.global_check=true
		-- 效果原文内容：①：对方把怪兽的召唤·特殊召唤无效的场合或者对方把魔法·陷阱·怪兽的效果的发动无效的场合才能发动。对方的手卡·场上的卡全部破坏。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAIN_NEGATED)
		ge1:SetOperation(c36458063.checkop)
		-- 将效果注册给全局环境
		Duel.RegisterEffect(ge1,0)
	end
end
-- 时点效果处理函数，用于在连锁被无效时触发自定义事件
function c36458063.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被无效的连锁的玩家
	local dp=Duel.GetChainInfo(ev,CHAININFO_DISABLE_PLAYER)
	-- 触发一个自定义事件，用于通知其他效果响应连锁被无效的情况
	Duel.RaiseEvent(e:GetHandler(),EVENT_CUSTOM+36458063,e,0,dp,0,0)
end
-- 判断连锁是否由对方触发
function c36458063.condition1(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
-- 设置效果的发动目标，检索对方手卡和场上的所有卡
function c36458063.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方手卡和场上的卡是否存在
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_HAND+LOCATION_ONFIELD,1,nil) end
	-- 获取对方手卡和场上的所有卡组成的卡片组
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_HAND+LOCATION_ONFIELD,nil)
	-- 设置效果操作信息，指定要破坏的卡组和数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果发动时执行的操作，将对方手卡和场上的卡全部破坏
function c36458063.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方手卡和场上的所有卡组成的卡片组
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_HAND+LOCATION_ONFIELD,nil)
	-- 以效果原因破坏目标卡组
	Duel.Destroy(g,REASON_EFFECT)
end
