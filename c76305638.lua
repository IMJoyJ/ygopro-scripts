--岩の精霊 タイタン
-- 效果：
-- 这张卡不能通常召唤。自己墓地1只地属性怪兽从游戏中除外特殊召唤上场。这只怪兽在对方的战斗阶段攻击力上升300。
function c76305638.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。自己墓地1只地属性怪兽从游戏中除外特殊召唤上场。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c76305638.spcon)
	e1:SetTarget(c76305638.sptg)
	e1:SetOperation(c76305638.spop)
	c:RegisterEffect(e1)
	-- 这只怪兽在对方的战斗阶段攻击力上升300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetCondition(c76305638.atkcon)
	e2:SetValue(300)
	c:RegisterEffect(e2)
end
-- 判断当前是否为对方回合的战斗阶段
function c76305638.atkcon(e)
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	-- 获取当前的回合玩家
	local tp=Duel.GetTurnPlayer()
	return tp~=e:GetHandler():GetControler() and ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
-- 过滤自己墓地中可以作为特殊召唤Cost除外的地属性怪兽
function c76305638.spfilter(c)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsAbleToRemoveAsCost()
end
-- 判断特殊召唤的条件是否满足（怪兽区域有空位且墓地存在至少1只地属性怪兽）
function c76305638.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上的主要怪兽区域是否有空位
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只满足过滤条件的地属性怪兽
		and Duel.IsExistingMatchingCard(c76305638.spfilter,tp,LOCATION_GRAVE,0,1,nil)
end
-- 特殊召唤的准备阶段，让玩家选择1只墓地的地属性怪兽作为特殊召唤的Cost
function c76305638.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己墓地中所有满足过滤条件的地属性怪兽
	local g=Duel.GetMatchingGroup(c76305638.spfilter,tp,LOCATION_GRAVE,0,nil)
	-- 给玩家发送“请选择要除外的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 执行特殊召唤的操作，将选中的怪兽除外
function c76305638.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的怪兽以特殊召唤的Cost表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
end
