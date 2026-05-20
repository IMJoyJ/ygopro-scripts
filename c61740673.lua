--王宮の勅命
-- 效果：
-- 这张卡的控制者在每次双方的准备阶段支付700基本分。不能支付700基本分的场合这张卡破坏。
-- ①：只要这张卡在魔法与陷阱区域存在，场上的全部魔法卡的效果无效化。
function c61740673.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在魔法与陷阱区域存在，场上的全部魔法卡的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DISABLE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
	e2:SetTarget(c61740673.distarget)
	c:RegisterEffect(e2)
	-- ①：只要这张卡在魔法与陷阱区域存在，场上的全部魔法卡的效果无效化。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetRange(LOCATION_SZONE)
	e3:SetOperation(c61740673.disoperation)
	c:RegisterEffect(e3)
	-- 这张卡的控制者在每次双方的准备阶段支付700基本分。不能支付700基本分的场合这张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1)
	e4:SetOperation(c61740673.mtop)
	c:RegisterEffect(e4)
end
-- 过滤出场上除自身以外的魔法卡作为无效对象
function c61740673.distarget(e,c)
	return c~=e:GetHandler() and c:IsType(TYPE_SPELL)
end
-- 在连锁处理时，无效在魔法与陷阱区域发动的魔法卡的效果
function c61740673.disoperation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前处理的连锁的发动位置
	local tl=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	if bit.band(tl,LOCATION_SZONE)~=0 and re:IsActiveType(TYPE_SPELL) then
		-- 无效该连锁的效果
		Duel.NegateEffect(ev)
	end
end
-- 在准备阶段处理维持代价，尝试支付700基本分，若无法支付则破坏此卡
function c61740673.mtop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前玩家是否能够支付700基本分
	if Duel.CheckLPCost(tp,700) then
		-- 扣除当前玩家700基本分作为维持代价
		Duel.PayLPCost(tp,700)
	else
		-- 因无法支付维持代价而将这张卡破坏
		Duel.Destroy(e:GetHandler(),REASON_COST)
	end
end
