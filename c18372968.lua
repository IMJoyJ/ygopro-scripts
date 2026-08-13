--カミソーリトカゲ
-- 效果：
-- 只要自己场上有这张卡以外的爬虫类族怪兽表侧表示存在，这张卡攻击里侧守备表示怪兽的场合，不进行伤害计算以里侧守备表示的状态把那只怪兽破坏。
function c18372968.initial_effect(c)
	-- 只要自己场上有这张卡以外的爬虫类族怪兽表侧表示存在，这张卡攻击里侧守备表示怪兽的场合，不进行伤害计算以里侧守备表示的状态把那只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(18372968,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetCondition(c18372968.descon)
	e1:SetTarget(c18372968.destg)
	e1:SetOperation(c18372968.desop)
	c:RegisterEffect(e1)
end
-- 过滤条件：卡为表侧表示且种族为爬虫类族的怪兽，用于查找符合条件的怪兽。
function c18372968.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_REPTILE)
end
-- 伤害步骤开始时，若攻击者是这张卡、攻击对象是里侧守备表示怪兽，且己方场上存在这张卡以外的表侧爬虫类族怪兽，则满足效果发动条件。
function c18372968.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗的攻击目标怪兽。
	local d=Duel.GetAttackTarget()
	-- 判定这张卡自身是攻击者，且攻击对象存在并处于里侧守备表示。
	return e:GetHandler()==Duel.GetAttacker() and d and d:IsPosition(POS_FACEDOWN_DEFENSE)
		-- 检查己方场上是否存在至少一张这张卡以外的表侧爬虫类族怪兽，以满足效果的前提条件。
		and Duel.IsExistingMatchingCard(c18372968.cfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
-- 效果发动时不取对象，直接通过合法性检查，并登记将攻击目标破坏的操作信息。
function c18372968.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向连锁登记破坏攻击目标的操作信息，类别为破坏，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,Duel.GetAttackTarget(),1,0,0)
end
-- 效果处理时，若攻击目标仍与本次战斗关联且仍为里侧守备表示，并且己方场上仍有其他表侧爬虫类族怪兽，则将其破坏。
function c18372968.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前攻击目标怪兽，用于效果处理时的判定与破坏。
	local d=Duel.GetAttackTarget()
	if d:IsRelateToBattle() and d:IsPosition(POS_FACEDOWN_DEFENSE)
		-- 效果处理时再次确认己方场上仍存在这张卡以外的表侧爬虫类族怪兽，满足条件才执行破坏。
		and Duel.IsExistingMatchingCard(c18372968.cfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) then
		-- 以效果为破坏原因，将攻击对象怪兽破坏。
		Duel.Destroy(d,REASON_EFFECT)
	end
end
