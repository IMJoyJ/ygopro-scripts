--伝説の爆炎使い
-- 效果：
-- 通过仪式魔法卡「灼热之试练」特殊召唤。特殊召唤时，必须以场上和/或手卡中合计7颗星以上的怪兽作为祭品。自己与对方每发动1次魔法，就在这张卡上放置1个魔力指示物。从这张卡上每除去3个魔力指示物，即可破坏场上除这张卡以外的所有怪兽。
function c60258960.initial_effect(c)
	-- 记录这张卡上记载着仪式魔法卡「灼热之试练」（卡号33031674）的卡名
	aux.AddCodeList(c,33031674)
	c:EnableReviveLimit()
	c:EnableCounterPermit(0x1)
	-- 通过仪式魔法卡「灼热之试练」特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_CHAINING)
	e0:SetRange(LOCATION_MZONE)
	-- 设置在连锁发生时记录这张卡在场上存在，用于后续判断是否放置魔力指示物
	e0:SetOperation(aux.chainreg)
	c:RegisterEffect(e0)
	-- 自己与对方每发动1次魔法，就在这张卡上放置1个魔力指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_CHAIN_SOLVED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(c60258960.acop)
	c:RegisterEffect(e1)
	-- 从这张卡上每除去3个魔力指示物，即可破坏场上除这张卡以外的所有怪兽。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(60258960,0))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c60258960.descost)
	e2:SetTarget(c60258960.destg)
	e2:SetOperation(c60258960.desop)
	c:RegisterEffect(e2)
end
c60258960.mentioned_counter={
	[0x1]=true,
}
-- 连锁处理结束时，若发动的是魔法卡的发动且这张卡在连锁发生时就已在场上，则在这张卡上放置1个魔力指示物
function c60258960.acop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0 then
		e:GetHandler():AddCounter(0x1,1)
	end
end
-- 发动代价：检查并作为代价从这张卡上除去3个魔力指示物
function c60258960.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x1,3,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x1,3,REASON_COST)
end
-- 破坏效果的对象设定：确认场上存在这张卡以外的怪兽，并把破坏分类的操作信息设置为这些怪兽及其数量
function c60258960.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 效果发动条件：检查双方怪兽区域是否存在至少1张这张卡以外的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,c) end
	-- 取得双方怪兽区域除这张卡以外的所有怪兽作为破坏对象组
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,c)
	-- 将破坏分类的操作信息设置为上述怪兽组及其数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 破坏效果的处理：取得场上除这张卡以外的所有怪兽并将它们以效果破坏
function c60258960.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得双方怪兽区域除这张卡以外的所有怪兽
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,aux.ExceptThisCard(e))
	-- 以效果原因破坏这些怪兽并送入墓地
	Duel.Destroy(g,REASON_EFFECT)
end
