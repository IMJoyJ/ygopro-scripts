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
	-- 此外，场上表侧表示存在的这张卡被破坏的场合，可以作为代替把这张卡以外的自己场上表侧表示存在的1只名字带有「六武众」的怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c31904181.desreptg)
	e2:SetOperation(c31904181.desrepop)
	c:RegisterEffect(e2)
end
-- 过滤表侧表示、卡名属于「六武众」字段且不是本卡（六武众-二藏）的怪兽，用于判断场上是否存在其他六武众。
function c31904181.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x103d) and not c:IsCode(31904181)
end
-- 额外攻击效果的发动/适用条件：检查本卡控制者场上是否存在1只以上满足cfilter（即其他表侧表示的六武众）的怪兽。
function c31904181.dircon(e)
	-- 以控制者视角检索其怪兽区域中是否存在至少1只满足cfilter的怪兽，存在则返回真，作为额外攻击的条件判定结果。
	return Duel.IsExistingMatchingCard(c31904181.cfilter,e:GetHandler():GetControler(),LOCATION_MZONE,0,1,nil)
end
-- 过滤可作为代替破坏对象的怪兽：要求表侧表示、属于「六武众」字段、能够被效果破坏，且不处于预定破坏或战斗破坏确定的状态。
function c31904181.repfilter(c,e)
	return c:IsFaceup() and c:IsSetCard(0x103d)
		and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED+STATUS_BATTLE_DESTROYED)
end
-- 代破效果的发动条件判定：当chk==0时，检查本卡不是因代替破坏而破坏、仍表侧表示在场，并且场上存在可代替破坏的其他六武众，满足则返回真。
function c31904181.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsReason(REASON_REPLACE) and c:IsOnField() and c:IsFaceup()
		-- 并且确认场上存在至少1只满足repfilter的六武众怪兽可作为代破对象，存在则代破效果可以发动。
		and Duel.IsExistingMatchingCard(c31904181.repfilter,tp,LOCATION_MZONE,0,1,c,e) end
	-- 询问本卡控制者是否要发动代替破坏效果，选择“是”则继续处理代破。
	if Duel.SelectEffectYesNo(tp,c,96) then
		-- 显示选择代替破坏卡的提示消息，引导玩家选择要代替破坏的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
		-- 让控制者从自己怪兽区域选择1只满足repfilter的六武众怪兽，作为代替这张卡破坏的对象。
		local g=Duel.SelectMatchingCard(tp,c31904181.repfilter,tp,LOCATION_MZONE,0,1,1,c,e)
		e:SetLabelObject(g:GetFirst())
		g:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	else return false end
end
-- 代破效果的实际处理：取出之前选择的代替破坏怪兽，清除其预定破坏状态，然后用效果破坏原因将其破坏，以代替原卡的破坏。
function c31904181.desrepop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	tc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	-- 以效果破坏的方式（携带REASON_REPLACE代替破坏原因）破坏选定的代替怪兽，完成代破。
	Duel.Destroy(tc,REASON_EFFECT+REASON_REPLACE)
end
