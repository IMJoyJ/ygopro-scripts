--伝説の爆炎使い
-- 效果：
-- 通过仪式魔法卡「灼热之试练」特殊召唤。特殊召唤时，必须以场上和/或手卡中合计7颗星以上的怪兽作为祭品。自己与对方每发动1次魔法，就在这张卡上放置1个魔力指示物。从这张卡上每除去3个魔力指示物，即可破坏场上除这张卡以外的所有怪兽。
function c60258960.initial_effect(c)
	-- 记录此卡记述了「灼热之试练」的卡名事实，以支持相关检索判定
	aux.AddCodeList(c,33031674)
	c:EnableReviveLimit()
	c:EnableCounterPermit(0x1)
	-- 自己与对方每发动1次魔法，就在这张卡上放置1个魔力指示物。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_CHAINING)
	e0:SetRange(LOCATION_MZONE)
	-- 连锁开始时，如果这张卡在怪兽区域表侧表示存在，则为这张卡注册连锁标记以备后续魔力指示物添加判定
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
-- 累计魔力指示物的效果处理：判定若有魔法卡发动且这张卡已注册连锁标记，则在这张卡上放置1个魔力指示物
function c60258960.acop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0 then
		e:GetHandler():AddCounter(0x1,1)
	end
end
-- 破坏所有怪兽效果的Cost支付判定：检查并从这张卡上移去3个魔力指示物
function c60258960.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x1,3,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x1,3,REASON_COST)
end
-- 破坏所有怪兽效果的发动准备：检查场上除自身外是否存在其他怪兽，并设置破坏怪兽的操作信息
function c60258960.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动检查：检查怪兽区是否存在至少1只除此卡以外的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,c) end
	-- 获取场上除了此卡以外的所有其他怪兽组
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,c)
	-- 设置操作信息：破坏除当前卡片以外的所有怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 破坏所有怪兽效果的效果处理：获取场上除了此卡以外的怪兽并将其全部破坏
function c60258960.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取处理时场上除了此卡以外的怪兽组
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,aux.ExceptThisCard(e))
	-- 因效果破坏这些怪兽
	Duel.Destroy(g,REASON_EFFECT)
end
