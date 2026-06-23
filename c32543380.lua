--ヴォルカニック・デビル
-- 效果：
-- 这张卡不能通常召唤。把自己场上1张表侧表示的「烈焰加农炮-三叉戟式」送去墓地的场合可以特殊召唤。
-- ①：对方战斗阶段中，可以攻击的对方的攻击表示怪兽必须向这张卡作出攻击。
-- ②：这张卡战斗破坏怪兽送去墓地的场合发动。对方场上的怪兽全部破坏，给与对方破坏数量×500伤害。
function c32543380.initial_effect(c)
	c:EnableReviveLimit()
	-- 特殊召唤条件：把自己场上1张表侧表示的「烈焰加农炮-三叉戟式」送去墓地的场合可以特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c32543380.spcon)
	e1:SetTarget(c32543380.sptg)
	e1:SetOperation(c32543380.spop)
	c:RegisterEffect(e1)
	-- 对方战斗阶段中，可以攻击的对方的攻击表示怪兽必须向这张卡作出攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_MUST_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c32543380.bpcon)
	e2:SetTargetRange(0,LOCATION_MZONE)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_MUST_ATTACK_MONSTER)
	e3:SetValue(c32543380.atklimit)
	c:RegisterEffect(e3)
	-- 这张卡战斗破坏怪兽送去墓地的场合发动。对方场上的怪兽全部破坏，给与对方破坏数量×500伤害。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(32543380,0))  --"对方场上的怪兽全部破坏"
	e5:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_BATTLE_DESTROYING)
	e5:SetCondition(c32543380.descon)
	e5:SetTarget(c32543380.destg)
	e5:SetOperation(c32543380.desop)
	c:RegisterEffect(e5)
end
-- 过滤函数：检查场上是否存在表侧表示的「烈焰加农炮-三叉戟式」且能送去墓地的卡。
function c32543380.spfilter(c)
	return c:IsFaceup() and c:IsCode(21420702) and c:IsAbleToGraveAsCost()
end
-- 特殊召唤条件函数：判断是否满足特殊召唤条件，包括是否有足够的怪兽区域和场上是否有符合条件的卡。
function c32543380.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判断玩家是否有足够的怪兽区域用于特殊召唤。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断玩家场上是否存在至少1张符合条件的「烈焰加农炮-三叉戟式」。
		and Duel.IsExistingMatchingCard(c32543380.spfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 特殊召唤目标选择函数：选择一张符合条件的卡送去墓地作为特殊召唤的代价。
function c32543380.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取满足条件的卡组，用于选择送去墓地的卡。
	local g=Duel.GetMatchingGroup(c32543380.spfilter,tp,LOCATION_ONFIELD,0,nil)
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤执行函数：将选择的卡送去墓地。
function c32543380.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将目标卡送去墓地，原因是为了特殊召唤。
	Duel.SendtoGrave(g,REASON_SPSUMMON)
end
-- 必须攻击条件函数：判断是否处于对方的战斗阶段。
function c32543380.bpcon(e)
	-- 判断是否处于对方的战斗阶段。
	return Duel.IsTurnPlayer(1-e:GetHandlerPlayer()) and Duel.IsBattlePhase()
end
-- 攻击限制函数：只有这张卡本身才能被强制攻击。
function c32543380.atklimit(e,c)
	return c==e:GetHandler()
end
-- 破坏效果发动条件函数：判断是否满足发动条件，包括战斗中破坏的怪兽是否在墓地且为怪兽卡。
function c32543380.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取此次战斗的攻击怪兽。
	local a=Duel.GetAttacker()
	-- 获取此次战斗的攻击目标。
	local d=Duel.GetAttackTarget()
	if a~=c then d=a end
	return c:IsRelateToBattle() and c:IsFaceup()
		and d and d:IsLocation(LOCATION_GRAVE) and d:IsType(TYPE_MONSTER)
end
-- 破坏效果目标设定函数：设定要破坏的对方场上所有怪兽和造成的伤害。
function c32543380.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取对方场上所有怪兽的卡组。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 设置连锁操作信息：设定要破坏的怪兽数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 设置连锁操作信息：设定要给予对方的伤害值。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:GetCount()*500)
end
-- 破坏效果执行函数：破坏对方场上所有怪兽并造成伤害。
function c32543380.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有怪兽的卡组。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 破坏对方场上所有怪兽，返回实际破坏的数量。
	local ct=Duel.Destroy(g,REASON_EFFECT)
	if ct>0 then
		-- 给与对方破坏数量×500的伤害。
		Duel.Damage(1-tp,ct*500,REASON_EFFECT)
	end
end
