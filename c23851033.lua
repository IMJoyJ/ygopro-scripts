--オッドアイズ・グラビティ・ドラゴン
-- 效果：
-- 「异色眼降临」降临。「异色眼重力龙」的①的效果1回合只能使用1次。
-- ①：这张卡特殊召唤成功时才能发动。对方场上的魔法·陷阱卡全部回到持有者手卡。对方不能对应这个效果的发动把魔法·陷阱·怪兽的效果发动。
-- ②：只要这张卡在怪兽区域存在，对方若不支付500基本分则不能把卡的效果发动。
function c23851033.initial_effect(c)
	-- 在卡片的关联卡片列表中注册「异色眼降临」，以便进行相关卡名检测。
	aux.AddCodeList(c,16494704)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤成功时才能发动。对方场上的魔法·陷阱卡全部回到持有者手卡。对方不能对应这个效果的发动把魔法·陷阱·怪兽的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(23851033,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,23851033)
	e1:SetTarget(c23851033.target)
	e1:SetOperation(c23851033.operation)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，对方若不支付500基本分则不能把卡的效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_ACTIVATE_COST)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(0,1)
	e2:SetCost(c23851033.costchk)
	e2:SetOperation(c23851033.costop)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在怪兽区域存在，对方若不支付500基本分则不能把卡的效果发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_FLAG_EFFECT+23851033)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(0,1)
	c:RegisterEffect(e3)
end
-- 过滤对方场上的魔法·陷阱卡，且可以回到手卡。
function c23851033.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- ①效果的发动准备与合法性检查，确认对方场上是否存在可以回到手卡的魔法或陷阱卡，设置回到手卡的操作信息，并限制对方不能对应发动卡的效果。
function c23851033.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断对方场上是否存在至少1张魔法或陷阱卡，作为效果发动的可行性检查。
	if chk==0 then return Duel.IsExistingMatchingCard(c23851033.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上所有可以回到手卡的魔法和陷阱卡片组。
	local sg=Duel.GetMatchingGroup(c23851033.filter,tp,0,LOCATION_ONFIELD,nil)
	-- 设置当前连锁的操作信息，标记该效果包含将对方场上的卡送回手卡的效果分类。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,sg:GetCount(),0,0)
	-- 锁定连锁：限制对方玩家无法对应此效果的发动来连锁发动任何魔法、陷阱或怪兽的效果。
	Duel.SetChainLimit(c23851033.chlimit)
end
-- 限制连锁的条件：只允许发动该效果的玩家进行连锁（即对方玩家不能连锁）。
function c23851033.chlimit(e,ep,tp)
	return tp==ep
end
-- ①效果的实效处理：将对方场上的魔法和陷阱卡全部送回持有者的手卡。
function c23851033.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时，重新获取对方场上所有可以回到手卡的魔法和陷阱卡片组。
	local sg=Duel.GetMatchingGroup(c23851033.filter,tp,0,LOCATION_ONFIELD,nil)
	-- 通过卡片效果将选中的全部魔法和陷阱卡送回持有者的手卡。
	Duel.SendtoHand(sg,nil,REASON_EFFECT)
end
-- ②效果的规则限制检查，确认对方玩家是否拥有足够的基本分以支付发动卡的效果所需的LP代价。
function c23851033.costchk(e,te_or_c,tp)
	-- 获取对方玩家本连锁中已发动的效果次数对应的标记数量，用于计算需要支付的LP总量。
	local ct=Duel.GetFlagEffect(tp,23851033)
	-- 检查对方玩家当前的基本分是否大于或等于需要支付的LP值。
	return Duel.CheckLPCost(tp,ct*500)
end
-- ②效果的规则限制执行：强制对方玩家为本次效果发动支付500点基本分。
function c23851033.costop(e,tp,eg,ep,ev,re,r,rp)
	-- 扣除发动效果的对方玩家500点基本分作为发动的基本分消耗。
	Duel.PayLPCost(tp,500)
end
