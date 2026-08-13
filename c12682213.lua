--鉄騎の雷鎚
-- 效果：
-- ①：场上的怪兽的效果·魔法·陷阱卡发动时，把基本分支付一半才能发动。那个发动无效并破坏。那之后，和破坏的卡存在过的区域相同纵列的怪兽区域·魔法与陷阱区域有卡存在的场合，那些卡全部破坏。
local s,id,o=GetID()
-- 定义初始效果函数：为本卡创建并注册两个效果，e1对应“场上怪兽的效果发动时”的无效并破坏及同纵列清扫，e2对应“魔法·陷阱卡发动时”的相同处理，二者共用代价、目标与处理函数。
function s.initial_effect(c)
	-- ①：场上的怪兽的效果发动时，把基本分支付一半才能发动。那个发动无效并破坏。那之后，和破坏的卡存在过的区域相同纵列的怪兽区域·魔法与陷阱区域有卡存在的场合，那些卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.moncon)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ①：魔法·陷阱卡发动时，把基本分支付一半才能发动。那个发动无效并破坏。那之后，和破坏的卡存在过的区域相同纵列的怪兽区域·魔法与陷阱区域有卡存在的场合，那些卡全部破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCondition(s.accon)
	e2:SetCost(s.cost)
	e2:SetTarget(s.target)
	e2:SetOperation(s.activate)
	c:RegisterEffect(e2)
end
-- 代价函数：chk==0时表示询问是否满足代价条件，这里直接返回true以表示可支付；实际发动时支付当前LP的一半（向下取整）作为代价。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 支付当前LP的一半（向下取整）作为发动代价。
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
-- 怪兽效果发动时的发动条件：获取连锁的发动位置，要求是怪兽区域发动的怪兽效果，且该连锁可以被无效。
function s.moncon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的发动位置（例如怪兽区域、魔法陷阱区域）。
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	-- 判断是否为场上怪兽区域发动的怪兽效果，且该发动可以被无效。
	return loc==LOCATION_MZONE and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end
-- 魔法·陷阱卡发动时的发动条件：要求被连锁的效果是魔法·陷阱卡的发动，且该连锁可以被无效。
function s.accon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断被连锁的效果是否为魔法·陷阱卡的发动，并且该发动可以被无效。
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
-- 目标/操作信息设置函数：发动时无需选择对象；将连锁中的卡标记为无效对象，若该卡可被破坏且仍与连锁关联，则同时标记为破坏对象。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设定本次效果处理要无效的对象为当前连锁中的那张卡（数量为1）。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 若被无效的卡能够被效果破坏且与连锁仍然关联，则追加设定将其破坏的操作信息。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理：取得被无效的卡rc及与其同纵列的所有卡dg；再取得本卡c，若c仍与该效果关联则从dg中排除本卡；接着尝试无效该连锁并破坏被无效的卡，成功后若dg中仍有卡，则错开时点将这些卡全部破坏。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	local dg=rc:GetColumnGroup()
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then dg:RemoveCard(c) end
	-- 尝试无效该连锁，并检查被无效的卡是否仍与其效果关联（防止对象消失后无法破坏）。
	if Duel.NegateActivation(ev) and rc:IsRelateToEffect(re)
		-- 同时要求实际破坏被无效的那张卡成功，且同纵列还存在其他卡，才继续后续的纵列全体破坏。
		and Duel.Destroy(eg,REASON_EFFECT)~=0 and dg:GetCount()>0 then
		-- 中断效果处理，使后续的纵列破坏视为另一次效果处理（对应原文“那之后”的错时点）。
		Duel.BreakEffect()
		-- 破坏与之前被破坏的卡同纵列的所有剩余卡片。
		Duel.Destroy(dg,REASON_EFFECT)
	end
end
