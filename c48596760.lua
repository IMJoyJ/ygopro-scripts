--闇の精霊 ルーナ
-- 效果：
-- 这张卡不能通常召唤。从自己墓地把1只暗属性怪兽除外的场合可以特殊召唤。
-- ①：自己准备阶段发动。给与对方500伤害。
function c48596760.initial_effect(c)
	c:EnableReviveLimit()
	-- 从自己墓地把1只暗属性怪兽除外的场合可以特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c48596760.spcon)
	e1:SetTarget(c48596760.sptg)
	e1:SetOperation(c48596760.spop)
	c:RegisterEffect(e1)
	-- 自己准备阶段发动。给与对方500伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c48596760.damcon)
	e2:SetTarget(c48596760.damtg)
	e2:SetOperation(c48596760.damop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断墓地是否存在暗属性且可作为除外费用的怪兽。
function c48596760.spfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToRemoveAsCost()
end
-- 特殊召唤的条件函数，检查是否满足特殊召唤所需条件。
function c48596760.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查当前玩家场上是否有可用的怪兽区域。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查当前玩家墓地中是否存在至少1只暗属性怪兽。
		and Duel.IsExistingMatchingCard(c48596760.spfilter,tp,LOCATION_GRAVE,0,1,nil)
end
-- 特殊召唤的目标选择函数，用于选择要除外的暗属性怪兽。
function c48596760.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取满足条件的暗属性怪兽组作为除外对象。
	local g=Duel.GetMatchingGroup(c48596760.spfilter,tp,LOCATION_GRAVE,0,nil)
	-- 向玩家发送提示信息“请选择要除外的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤的操作函数，将选定的怪兽除外。
function c48596760.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将指定的怪兽以正面表示的形式从游戏中除外。
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
end
-- 伤害效果的发动条件函数，判断是否为自己的准备阶段。
function c48596760.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己。
	return Duel.GetTurnPlayer()==tp
end
-- 伤害效果的目标设定函数，设置受到伤害的玩家和伤害值。
function c48596760.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理中目标玩家为对方。
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁处理中的目标参数为500点伤害。
	Duel.SetTargetParam(500)
	-- 设置本次连锁操作的信息为造成500点伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 伤害效果的执行函数，对指定玩家造成伤害。
function c48596760.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家和目标参数（即伤害值）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对指定玩家造成相应数值的伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
