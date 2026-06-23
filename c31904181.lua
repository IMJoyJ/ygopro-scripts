--六武衆－ニサシ
-- 效果：
-- 自己场上有「六武众-二藏」以外的名字带有「六武众」的怪兽存在的场合，这张卡在同1次的战斗阶段中可以作2次攻击。此外，场上表侧表示存在的这张卡被破坏的场合，可以作为代替把这张卡以外的自己场上表侧表示存在的1只名字带有「六武众」的怪兽破坏。
function c31904181.initial_effect(c)
	-- 自己场上有「六武众-二藏」以外的名字带有「六武众」的怪兽存在的场合，这张卡在同1次的战斗阶段中可以作2次攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetCondition(c31904181.dircon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 场上表侧表示存在的这张卡被破坏的场合，可以作为代替把这张卡以外的自己场上表侧表示存在的1只名字带有「六武众」的怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c31904181.desreptg)
	e2:SetOperation(c31904181.desrepop)
	c:RegisterEffect(e2)
end
-- 过滤函数，检查场上是否存在满足条件的「六武众」怪兽（不包括二藏）
function c31904181.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x103d) and not c:IsCode(31904181)
end
-- 判断条件函数，检查自己场上是否存在除二藏外的「六武众」怪兽
function c31904181.dircon(e)
	-- 检查自己场上是否存在至少1张除二藏外的「六武众」怪兽
	return Duel.IsExistingMatchingCard(c31904181.cfilter,e:GetHandler():GetControler(),LOCATION_MZONE,0,1,nil)
end
-- 过滤函数，检查场上是否存在可以被破坏的「六武众」怪兽（包括二藏）
function c31904181.repfilter(c,e)
	return c:IsFaceup() and c:IsSetCard(0x103d)
		and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED+STATUS_BATTLE_DESTROYED)
end
-- 判断是否可以发动代替破坏效果，检查是否满足发动条件
function c31904181.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsReason(REASON_REPLACE) and c:IsOnField() and c:IsFaceup()
		-- 检查自己场上是否存在至少1张可以被代替破坏的「六武众」怪兽
		and Duel.IsExistingMatchingCard(c31904181.repfilter,tp,LOCATION_MZONE,0,1,c,e) end
	-- 询问玩家是否发动代替破坏效果
	if Duel.SelectEffectYesNo(tp,c,96) then
		-- 提示玩家选择要代替破坏的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
		-- 选择1只满足条件的「六武众」怪兽作为代替破坏对象
		local g=Duel.SelectMatchingCard(tp,c31904181.repfilter,tp,LOCATION_MZONE,0,1,1,c,e)
		e:SetLabelObject(g:GetFirst())
		g:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	else return false end
end
-- 代替破坏效果的处理函数，将选中的怪兽从场上破坏
function c31904181.desrepop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	tc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	-- 将选中的怪兽以效果破坏的方式从场上破坏
	Duel.Destroy(tc,REASON_EFFECT+REASON_REPLACE)
end
