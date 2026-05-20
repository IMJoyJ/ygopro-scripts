--爆走特急ロケット・アロー
-- 效果：
-- 这张卡不能通常召唤。自己场上没有卡存在的场合才能特殊召唤。把这张卡特殊召唤的回合，自己不能进行战斗阶段。这张卡的控制者在每次自己准备阶段把手卡全部送去墓地。或者不送去墓地让这张卡破坏。
-- ①：只要这张卡在怪兽区域存在，自己不能把魔法·陷阱·怪兽的效果发动，不能把卡盖放。
function c79850798.initial_effect(c)
	c:EnableReviveLimit()
	-- 自己场上没有卡存在的场合才能特殊召唤。把这张卡特殊召唤的回合，自己不能进行战斗阶段。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c79850798.spcon)
	e1:SetOperation(c79850798.spop)
	c:RegisterEffect(e1)
	-- 这张卡不能通常召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e2)
	-- ①：只要这张卡在怪兽区域存在，自己不能把魔法·陷阱·怪兽的效果发动
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(1,0)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- 不能把卡盖放。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_MSET)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(1,0)
	-- 设置不能盖放的怪兽目标过滤函数（aux.TRUE表示所有怪兽都不能盖放）
	e4:SetTarget(aux.TRUE)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_CANNOT_SSET)
	c:RegisterEffect(e5)
	local e6=e4:Clone()
	e6:SetCode(EFFECT_CANNOT_TURN_SET)
	c:RegisterEffect(e6)
	local e7=e4:Clone()
	e7:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e7:SetTarget(c79850798.sumlimit)
	c:RegisterEffect(e7)
	-- 这张卡的控制者在每次自己准备阶段把手卡全部送去墓地。或者不送去墓地让这张卡破坏。
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e8:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e8:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e8:SetRange(LOCATION_MZONE)
	e8:SetCountLimit(1)
	e8:SetCondition(c79850798.mtcon)
	e8:SetOperation(c79850798.mtop)
	c:RegisterEffect(e8)
end
-- 特殊召唤规则的条件：本回合未进入过战斗阶段、自己场上没有卡存在且有可用的怪兽区域
function c79850798.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查本回合是否未进入过战斗阶段
	return Duel.GetActivityCount(tp,ACTIVITY_BATTLE_PHASE)==0
		-- 检查自己场上是否存在卡片（必须为0）
		and Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)==0
		-- 检查自己场上是否有可用的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
-- 特殊召唤规则的操作：给玩家注册“本回合不能进行战斗阶段”的效果
function c79850798.spop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 把这张卡特殊召唤的回合，自己不能进行战斗阶段。不能把卡盖放。这张卡的控制者在每次自己准备阶段把手卡全部送去墓地。或者不送去墓地让这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 给玩家注册“不能进行战斗阶段”的效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制不能以里侧表示特殊召唤怪兽（对应“不能把卡盖放”中不能里侧特召的部分）
function c79850798.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return bit.band(sumpos,POS_FACEDOWN)~=0
end
-- 维持效果的条件：当前是自己的回合
function c79850798.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 维持效果的操作：在准备阶段选择将手卡全部送去墓地，或者将此卡破坏
function c79850798.mtop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果手牌不为空，且玩家选择将手牌全部送去墓地
	if Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)~=0 and Duel.SelectYesNo(tp,aux.Stringid(79850798,1)) then  --"是否要把手卡全部送去墓地？"
		-- 作为维持代价，将自己所有的手牌送去墓地
		Duel.SendtoGrave(Duel.GetFieldGroup(tp,LOCATION_HAND,0),REASON_COST)
	else
		-- 作为代替，将这张卡破坏
		Duel.Destroy(e:GetHandler(),REASON_COST)
	end
end
