--No.40 ギミック・パペット－ヘブンズ・ストリングス
-- 效果：
-- 8星怪兽×2
-- ①：1回合1次，把这张卡1个超量素材取除才能发动。给这张卡以外的场上的表侧表示怪兽全部各放置1个线指示物。
-- ②：这张卡的①的效果把线指示物放置的场合，下次的对方结束阶段发动。有线指示物放置的怪兽全部破坏，给与对方破坏数量×500伤害。
function c75433814.initial_effect(c)
	-- 注册超量召唤手续：8星怪兽×2
	aux.AddXyzProcedure(c,nil,8,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除才能发动。给这张卡以外的场上的表侧表示怪兽全部各放置1个线指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(75433814,0))  --"放置指示物"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c75433814.ctcost)
	e1:SetTarget(c75433814.cttg)
	e1:SetOperation(c75433814.ctop)
	c:RegisterEffect(e1)
	-- ②：这张卡的①的效果把线指示物放置的场合，下次的对方结束阶段发动。有线指示物放置的怪兽全部破坏，给与对方破坏数量×500伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(75433814,1))  --"破坏并伤害"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c75433814.descon)
	e2:SetTarget(c75433814.destg)
	e2:SetOperation(c75433814.desop)
	c:RegisterEffect(e2)
end
-- 标记此卡为No.40
aux.xyz_number[75433814]=40
c75433814.mentioned_counter={
	[0x1024]=true,
}
-- 把这张卡1个超量素材取除才能发动
function c75433814.ctcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 检查场上是否至少存在1只此卡以外可以放置线指示物的表侧表示怪兽
function c75433814.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否至少存在1只此卡以外可以放置线指示物的表侧表示怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCanAddCounter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler(),0x1024,1) end
end
-- 给这张卡以外的场上的表侧表示怪兽全部各放置1个线指示物
function c75433814.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上除了此卡以外所有可以放置线指示物的表侧表示怪兽
	local g=Duel.GetMatchingGroup(Card.IsCanAddCounter,tp,LOCATION_MZONE,LOCATION_MZONE,aux.ExceptThisCard(e),0x1024,1)
	local tc=g:GetFirst()
	while tc do
		tc:AddCounter(0x1024,1)
		tc=g:GetNext()
	end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		c:RegisterFlagEffect(75433814,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN,0,1)
	end
end
-- 检查此卡是否因为效果①放置了线指示物，并且当前回合是对方的回合
function c75433814.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查此卡是否因为效果①放置了线指示物，并且当前回合是对方的回合
	return e:GetHandler():GetFlagEffect(75433814)~=0 and Duel.GetTurnPlayer()~=tp
end
-- 检查怪兽是否放置有线指示物
function c75433814.desfilter(c)
	return c:GetCounter(0x1024)~=0
end
-- 检查场上是否有放置了线指示物的怪兽，并设定破坏及伤害的操作信息
function c75433814.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否至少存在1只放置了线指示物的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c75433814.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取场上所有放置了线指示物的怪兽
	local g=Duel.GetMatchingGroup(c75433814.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置操作信息：预计破坏所有放置了线指示物的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 设置操作信息：预计给与对方伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:GetCount()*500)
end
-- 有线指示物放置的怪兽全部破坏，给与对方破坏数量×500伤害效果处理
function c75433814.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有放置了线指示物的怪兽
	local g=Duel.GetMatchingGroup(c75433814.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 将这些怪兽全部破坏
	local ct=Duel.Destroy(g,REASON_EFFECT)
	-- 给与对方破坏数量×500伤害
	Duel.Damage(1-tp,ct*500,REASON_EFFECT)
end
