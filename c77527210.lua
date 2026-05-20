--神聖なる魂
-- 效果：
-- 这张卡不能通常召唤。从自己墓地把2只光属性怪兽除外的场合可以特殊召唤。
-- ①：只要这张卡在怪兽区域存在，对方场上的怪兽的攻击力在对方战斗阶段内下降300。
function c77527210.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。从自己墓地把2只光属性怪兽除外的场合可以特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c77527210.spcon)
	e1:SetTarget(c77527210.sptg)
	e1:SetOperation(c77527210.spop)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在怪兽区域存在，对方场上的怪兽的攻击力在对方战斗阶段内下降300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetCondition(c77527210.atkcon)
	e2:SetValue(-300)
	c:RegisterEffect(e2)
end
-- 判断当前是否为对方回合的战斗阶段
function c77527210.atkcon(e)
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	-- 获取当前的回合玩家
	local tp=Duel.GetTurnPlayer()
	return tp~=e:GetHandler():GetControler() and ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
-- 过滤自己墓地中可以作为特殊召唤Cost除外的光属性怪兽
function c77527210.spfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToRemoveAsCost()
end
-- 特殊召唤规则的条件：怪兽区域有空位且自己墓地存在至少2只光属性怪兽
function c77527210.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否有可用的怪兽区域空格
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少2只满足过滤条件的光属性怪兽
		and Duel.IsExistingMatchingCard(c77527210.spfilter,tp,LOCATION_GRAVE,0,2,nil)
end
-- 特殊召唤规则的目标：选择自己墓地2只光属性怪兽作为除外的Cost
function c77527210.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己墓地中所有满足过滤条件的光属性怪兽
	local g=Duel.GetMatchingGroup(c77527210.spfilter,tp,LOCATION_GRAVE,0,nil)
	-- 向玩家发送提示信息，要求选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:CancelableSelect(tp,2,2,nil)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤规则的操作：将选中的怪兽除外
function c77527210.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的怪兽以表侧表示除外，作为特殊召唤的Cost
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
