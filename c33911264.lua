--太陽風帆船
-- 效果：
-- 自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。这个方法特殊召唤的这张卡的原本的攻击力·守备力变成一半。此外，每次自己的准备阶段这张卡的等级上升1星。「太阳风帆船」在场上只能有1只表侧表示存在。
function c33911264.initial_effect(c)
	c:SetUniqueOnField(1,1,33911264)
	-- 自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。这个方法特殊召唤的这张卡的原本的攻击力·守备力变成一半。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c33911264.spcon)
	e1:SetOperation(c33911264.spop)
	c:RegisterEffect(e1)
	-- 此外，每次自己的准备阶段这张卡的等级上升1星。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(33911264,0))  --"等级上升"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCondition(c33911264.lvcon)
	e2:SetOperation(c33911264.lvop)
	c:RegisterEffect(e2)
end
-- 此卡从手卡进行规则特殊召唤的条件判定：要求自己场上没有怪兽且主要怪兽区有空位。
function c33911264.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上（主要怪兽区）的怪兽数量必须为0，即自己场上没有怪兽。
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
		-- 并且自己的主要怪兽区存在可用的空格，确保能够特殊召唤。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
-- 特殊召唤成功的处理：为此卡注册原本攻击力变为400、原本守备力变为1200的效果，使原本攻击力·守备力变成一半。
function c33911264.spop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 这个方法特殊召唤的这张卡的原本的攻击力·守备力变成一半。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetValue(400)
	e1:SetReset(RESET_EVENT+0xff0000)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_BASE_DEFENSE)
	e2:SetValue(1200)
	c:RegisterEffect(e2)
end
-- 等级上升效果的发动条件：当前回合玩家是此卡的控制者，即仅在自己的准备阶段满足。
function c33911264.lvcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否等于此卡的控制者，用于确认是否为“自己的准备阶段”。
	return Duel.GetTurnPlayer()==tp
end
-- 等级上升效果的处理：若此卡仍在本方场上且表侧表示存在，则给它附加一个等级上升1星的持续效果，并在满足标准重置条件时失效。
function c33911264.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 每次自己的准备阶段这张卡的等级上升1星。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
end
