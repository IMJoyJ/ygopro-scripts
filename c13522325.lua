--炎の精霊 イフリート
-- 效果：
-- 这张卡不能通常召唤。从自己墓地把1只炎属性怪兽除外的场合可以特殊召唤。
-- ①：这张卡的攻击力在自己战斗阶段内上升300。
function c13522325.initial_effect(c)
	c:EnableReviveLimit()
	-- 从自己墓地把1只炎属性怪兽除外的场合可以特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c13522325.spcon)
	e1:SetTarget(c13522325.sptg)
	e1:SetOperation(c13522325.spop)
	c:RegisterEffect(e1)
	-- 这张卡的攻击力在自己战斗阶段内上升300
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetCondition(c13522325.atkcon)
	e2:SetValue(300)
	c:RegisterEffect(e2)
end
-- 判断是否处于战斗阶段以决定攻击力是否上升
function c13522325.atkcon(e)
	-- 获取当前游戏阶段
	local ph=Duel.GetCurrentPhase()
	-- 获取当前回合玩家
	local tp=Duel.GetTurnPlayer()
	return tp==e:GetHandler():GetControler() and ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
-- 过滤满足条件的炎属性怪兽
function c13522325.spfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToRemoveAsCost()
end
-- 判断特殊召唤条件是否满足
function c13522325.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查场上是否有空位
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c13522325.spfilter,tp,LOCATION_GRAVE,0,1,nil)
end
-- 设置特殊召唤的目标选择函数
function c13522325.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取满足条件的怪兽组
	local g=Duel.GetMatchingGroup(c13522325.spfilter,tp,LOCATION_GRAVE,0,nil)
	-- 提示选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 设置特殊召唤的处理函数
function c13522325.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将目标怪兽除外
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
end
