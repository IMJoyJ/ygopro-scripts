--No.40 ギミック・パペット－ヘブンズ・ストリングス
-- 效果：
-- 8星怪兽×2
-- ①：1回合1次，把这张卡1个超量素材取除才能发动。给这张卡以外的场上的表侧表示怪兽全部各放置1个线指示物。
-- ②：这张卡的①的效果把线指示物放置的场合，下次的对方结束阶段发动。有线指示物放置的怪兽全部破坏，给与对方破坏数量×500伤害。
function c75433814.initial_effect(c)
	-- 设置超量召唤手续：8星怪兽×2
	aux.AddXyzProcedure(c,nil,8,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材去除才能发动。给这张卡以外的场上的表侧表示怪兽全部各放置1个线指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(75433814,0))  --"放置指示物"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c75433814.ctcost)
	e1:SetTarget(c75433814.cttg)
	e1:SetOperation(c75433814.ctop)
	c:RegisterEffect(e1)
	-- ②：这张卡的①的效果把线指示物放置的场合，下次的对方结束阶段发动。有线指示物放置的怪兽全部破坏，给予对方破坏数量×500伤害。
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
-- 注册No.编号：40
aux.xyz_number[75433814]=40
c75433814.mentioned_counter={
	[0x1024]=true,
}
-- ①效果发动Cost：去除1个超量素材
function c75433814.ctcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- ①效果发动准备：检查场上是否存在可以放置线指示物的怪兽
function c75433814.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在除自身外可放置线指示物的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCanAddCounter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler(),0x1024,1) end
end
-- ①效果处理：给场上除自身外所有表侧表示怪兽各放置1个线指示物，并为自身注册延迟生效的Flag标记
function c75433814.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上除自身外所有可放置线指示物的表侧表示怪兽
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
-- ②效果发动条件：处于对方结束阶段且此卡带有放置指示物成功的Flag标记
function c75433814.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为对方回合的结束阶段且存在特定Flag标记
	return e:GetHandler():GetFlagEffect(75433814)~=0 and Duel.GetTurnPlayer()~=tp
end
-- 过滤条件：带有线指示物的卡
function c75433814.desfilter(c)
	return c:GetCounter(0x1024)~=0
end
-- ②效果发动准备：设置破坏所有带线指示物怪兽并给予对方伤害的操作信息
function c75433814.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在带有线指示物的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c75433814.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取场上所有带有线指示物的怪兽
	local g=Duel.GetMatchingGroup(c75433814.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置连锁操作信息：破坏带线指示物的所有怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 设置连锁操作信息：给予对方破坏数量×500的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:GetCount()*500)
end
-- ②效果处理：破坏场上所有带有线指示物的怪兽，并给予对方实际破坏数量×500的伤害
function c75433814.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有带有线指示物的怪兽
	local g=Duel.GetMatchingGroup(c75433814.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 破坏选中的怪兽，并获取成功破坏的数量
	local ct=Duel.Destroy(g,REASON_EFFECT)
	-- 给予对方实际破坏数量×500的伤害
	Duel.Damage(1-tp,ct*500,REASON_EFFECT)
end
