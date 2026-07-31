--伝説の爆炎使い
-- 效果：
-- 通过仪式魔法卡「灼热之试练」特殊召唤。特殊召唤时，必须以场上和/或手卡中合计7颗星以上的怪兽作为祭品。自己与对方每发动1次魔法，就在这张卡上放置1个魔力指示物。从这张卡上每除去3个魔力指示物，即可破坏场上除这张卡以外的所有怪兽。
function c60258960.initial_effect(c)
	-- 注册关联卡片代码（灼热之试炼）
	aux.AddCodeList(c,33031674)
	c:EnableReviveLimit()
	c:EnableCounterPermit(0x1)
	-- 注册连锁标记注册效果，用于检测魔法卡发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_CHAINING)
	e0:SetRange(LOCATION_MZONE)
	-- 连锁处理：注册连锁标记
	e0:SetOperation(aux.chainreg)
	c:RegisterEffect(e0)
	-- 双方每次发动魔法卡，给这张卡放置1个魔力指示物
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_CHAIN_SOLVED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(c60258960.acop)
	c:RegisterEffect(e1)
	-- 从这张卡去除3个魔力指示物才能发动。破坏场上这张卡以外的所有怪兽。
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
-- 放置魔力指示物处理：在魔法卡连锁处理完毕后放置1个魔力指示物
function c60258960.acop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0 then
		e:GetHandler():AddCounter(0x1,1)
	end
end
-- 效果Cost：去除这张卡3个魔力指示物
function c60258960.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x1,3,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x1,3,REASON_COST)
end
-- 效果发动准备：设置破坏场上这张卡以外所有怪兽的操作信息
function c60258960.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动条件检查：场上是否存在这张卡以外的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,c) end
	-- 获取场上除了这张卡以外的所有怪兽
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,c)
	-- 设置连锁操作信息：破坏这些怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理：破坏场上这张卡以外的所有怪兽
function c60258960.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上除了这张卡以外的所有怪兽
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,aux.ExceptThisCard(e))
	-- 将选中的怪兽破坏
	Duel.Destroy(g,REASON_EFFECT)
end
