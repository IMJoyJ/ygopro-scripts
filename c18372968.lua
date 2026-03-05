--カミソーリトカゲ
-- 效果：
-- 只要自己场上有这张卡以外的爬虫类族怪兽表侧表示存在，这张卡攻击里侧守备表示怪兽的场合，不进行伤害计算以里侧守备表示的状态把那只怪兽破坏。
function c18372968.initial_effect(c)
	-- 诱发必发效果，战斗阶段开始时发动
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
-- 检查场上是否存在表侧表示的爬虫类族怪兽
function c18372968.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_REPTILE)
end
-- 效果发动条件：自己场上存在其他爬虫类族怪兽且攻击对方里侧守备表示怪兽
function c18372968.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取攻击战斗中被攻击的怪兽
	local d=Duel.GetAttackTarget()
	-- 确认攻击怪兽为自身且被攻击怪兽为里侧守备表示
	return e:GetHandler()==Duel.GetAttacker() and d and d:IsPosition(POS_FACEDOWN_DEFENSE)
		-- 确认自己场上有其他爬虫类族怪兽存在
		and Duel.IsExistingMatchingCard(c18372968.cfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
-- 设置效果处理时的破坏目标
function c18372968.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息为破坏效果
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,Duel.GetAttackTarget(),1,0,0)
end
-- 效果处理函数：若满足条件则破坏对方里侧守备表示怪兽
function c18372968.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取攻击战斗中被攻击的怪兽
	local d=Duel.GetAttackTarget()
	if d:IsRelateToBattle() and d:IsPosition(POS_FACEDOWN_DEFENSE)
		-- 再次确认自己场上有其他爬虫类族怪兽存在
		and Duel.IsExistingMatchingCard(c18372968.cfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) then
		-- 以效果原因破坏目标怪兽
		Duel.Destroy(d,REASON_EFFECT)
	end
end
