--オッドアイズ・グラビティ・ドラゴン
-- 效果：
-- 「异色眼降临」降临。「异色眼重力龙」的①的效果1回合只能使用1次。
-- ①：这张卡特殊召唤成功时才能发动。对方场上的魔法·陷阱卡全部回到持有者手卡。对方不能对应这个效果的发动把魔法·陷阱·怪兽的效果发动。
-- ②：只要这张卡在怪兽区域存在，对方若不支付500基本分则不能把卡的效果发动。
function c23851033.initial_effect(c)
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
-- 过滤函数，用于筛选场上存在的魔法·陷阱卡
function c23851033.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果处理时的处理函数，用于判断是否满足发动条件并设置连锁信息
function c23851033.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断对方场上是否存在至少一张魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c23851033.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上的所有魔法·陷阱卡
	local sg=Duel.GetMatchingGroup(c23851033.filter,tp,0,LOCATION_ONFIELD,nil)
	-- 设置连锁操作信息为将这些卡送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,sg:GetCount(),0,0)
	-- 设置连锁限制，防止对方在该效果发动时连锁其他效果
	Duel.SetChainLimit(c23851033.chlimit)
end
-- 连锁限制函数，仅允许发动玩家进行连锁
function c23851033.chlimit(e,ep,tp)
	return tp==ep
end
-- 效果处理函数，将符合条件的卡送回手牌
function c23851033.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的所有魔法·陷阱卡
	local sg=Duel.GetMatchingGroup(c23851033.filter,tp,0,LOCATION_ONFIELD,nil)
	-- 将这些卡以效果原因送回手牌
	Duel.SendtoHand(sg,nil,REASON_EFFECT)
end
-- 检查发动玩家是否能支付对应费用
function c23851033.costchk(e,te_or_c,tp)
	-- 获取该玩家已使用的①效果次数
	local ct=Duel.GetFlagEffect(tp,23851033)
	-- 检查玩家是否能支付次数乘以500点LP
	return Duel.CheckLPCost(tp,ct*500)
end
-- 支付LP的处理函数
function c23851033.costop(e,tp,eg,ep,ev,re,r,rp)
	-- 支付500点LP
	Duel.PayLPCost(tp,500)
end
