--古の森
-- 效果：
-- 这张卡的发动时，场上有守备表示怪兽存在的场合，那些怪兽全部变成表侧攻击表示。这个时候，反转效果怪兽的效果不发动。此外，怪兽进行攻击的场合，进行攻击的怪兽在战斗阶段结束时破坏。
function c87624166.initial_effect(c)
	-- 这张卡的发动时，场上有守备表示怪兽存在的场合，那些怪兽全部变成表侧攻击表示。这个时候，反转效果怪兽的效果不发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c87624166.target)
	e1:SetOperation(c87624166.activate)
	c:RegisterEffect(e1)
	-- 此外，怪兽进行攻击的场合，进行攻击的怪兽在战斗阶段结束时破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(87624166,0))  --"攻击怪兽破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e2:SetTarget(c87624166.destg)
	e2:SetOperation(c87624166.desop)
	c:RegisterEffect(e2)
end
-- 卡片发动时的效果目标确认，检查并收集场上的守备表示怪兽，设置改变表示形式的操作信息
function c87624166.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取双方场上所有的守备表示怪兽
	local g=Duel.GetMatchingGroup(Card.IsDefensePos,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置当前连锁的操作信息为改变表示形式，对象为获取到的守备表示怪兽
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 卡片发动时的效果处理，将场上所有的守备表示怪兽全部变成表侧攻击表示，且不触发反转效果
function c87624166.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方场上所有的守备表示怪兽
	local g=Duel.GetMatchingGroup(Card.IsDefensePos,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 将目标怪兽全部变成表侧攻击表示，并设置不触发反转效果
		Duel.ChangePosition(g,0,0,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,true)
	end
end
-- 过滤函数：过滤出本回合进行过攻击的怪兽
function c87624166.desfilter(c)
	return c:GetAttackedCount()>0
end
-- 战斗阶段结束时强制发动的效果目标确认，检查并收集本回合进行过攻击的怪兽，设置破坏的操作信息
function c87624166.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查双方场上是否存在至少1只本回合进行过攻击的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c87624166.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取双方场上所有本回合进行过攻击的怪兽
	local g=Duel.GetMatchingGroup(c87624166.desfilter,Duel.GetTurnPlayer(),LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置当前连锁的操作信息为破坏，对象为这些进行过攻击的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 战斗阶段结束时强制发动的效果处理，破坏所有本回合进行过攻击的怪兽
function c87624166.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方场上所有本回合进行过攻击的怪兽
	local g=Duel.GetMatchingGroup(c87624166.desfilter,Duel.GetTurnPlayer(),LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 因效果破坏这些进行过攻击的怪兽
	Duel.Destroy(g,REASON_EFFECT)
end
