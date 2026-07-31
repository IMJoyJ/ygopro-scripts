--CNo.40 ギミック・パペット－デビルズ・ストリングス
-- 效果：
-- 9星怪兽×3
-- ①：这张卡特殊召唤成功的场合发动。有线指示物放置的怪兽全部破坏，自己从卡组抽1张。那之后，给与对方这个效果破坏送去墓地的怪兽之内原本攻击力最高的怪兽的那个数值的伤害。
-- ②：1回合1次，把这张卡1个超量素材取除才能发动。给对方场上的表侧表示怪兽全部各放置1个线指示物。
function c69170557.initial_effect(c)
	-- 超量召唤手续：9星怪兽×3
	aux.AddXyzProcedure(c,nil,9,3)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤成功的场合发动。有线指示物放置的怪兽全部破坏，自己从卡组抽1张。那之后，给与对方这个效果破坏送去墓地的怪兽之内原本攻击力最高的怪兽的那个数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(69170557,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(c69170557.destg)
	e1:SetOperation(c69170557.desop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，把这张卡1个超量素材取除才能发动。给对方场上的表侧表示怪兽全部各放置1个线指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(69170557,1))  --"放置指示物"
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c69170557.ctcost)
	e2:SetTarget(c69170557.cttg)
	e2:SetOperation(c69170557.ctop)
	c:RegisterEffect(e2)
end
-- 设定网络编号：No.40
aux.xyz_number[69170557]=40
c69170557.mentioned_counter={
	[0x1024]=true,
}
-- 破坏过滤条件：放置有线指示物（0x1024）的卡
function c69170557.desfilter(c)
	return c:GetCounter(0x1024)~=0
end
-- ①效果发动准备：设置破坏场上有线指示物怪兽及抽卡的操作信息
function c69170557.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取双方场上所有放置有线指示物的怪兽
	local g=Duel.GetMatchingGroup(c69170557.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置连锁操作信息：破坏场上有线指示物的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 设置连锁操作信息：自己从卡组抽1张
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ①效果处理：破坏放置有线指示物的怪兽，抽1张卡，并给予对方被破坏送墓怪兽中最高原本攻击力数值的伤害
function c69170557.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方场上所有放置有线指示物的怪兽
	local g=Duel.GetMatchingGroup(c69170557.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 破坏所有选中的怪兽，若未成功破坏则终止效果处理
	if Duel.Destroy(g,REASON_EFFECT)==0 then return end
	-- 筛选因该破坏效果成功送去墓地的怪兽
	local og=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	-- 从卡组抽1张卡，若抽卡成功且有怪兽被破坏送去墓地则继续处理
	if Duel.Draw(tp,1,REASON_EFFECT)~=0 and og:GetCount()>0 then
		-- 连接效果块（分隔抽卡与伤害处理）
		Duel.BreakEffect()
		local mg,matk=og:GetMaxGroup(Card.GetBaseAttack)
		if matk>0 then
			-- 给与对方被破坏送墓怪兽中最高原本攻击力数值的伤害
			Duel.Damage(1-tp,matk,REASON_EFFECT)
		end
	end
end
-- ②效果发动Cost：去除自身1个超量素材
function c69170557.ctcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- ②效果发动条件检查：对方场上是否存在可以放置指示物的表侧表示怪兽
function c69170557.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1只可放置线指示物的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCanAddCounter,tp,0,LOCATION_MZONE,1,nil,0x1024,1) end
end
-- ②效果处理：给对方场上所有表侧表示怪兽各放置1个线指示物
function c69170557.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有可以放置线指示物的怪兽
	local g=Duel.GetMatchingGroup(Card.IsCanAddCounter,tp,0,LOCATION_MZONE,nil,0x1024,1)
	local tc=g:GetFirst()
	while tc do
		tc:AddCounter(0x1024,1)
		tc=g:GetNext()
	end
end
