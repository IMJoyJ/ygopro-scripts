--暗翳の信仰者
-- 效果：
-- ←11 【灵摆】 11→
-- 自己不是灵摆怪兽不能灵摆召唤（这个效果不会被无效化）。
-- 攻击力1000以下的怪兽特殊召唤的场合（伤害步骤除外）：可以让这张卡回到手卡。「无明者 阴暗」的这个效果1回合只能使用1次。
--  【怪兽效果】
-- 自己灵摆区域有卡存在，这张卡在手卡存在的场合：可以把这张卡特殊召唤。
-- 可以支付1000基本分；自己手卡·场上（表侧表示）的1张灵摆怪兽卡破坏，那之后，可以从卡组把1只灵摆怪兽以表侧加入额外卡组。
-- 「无明者 阴暗」的每个怪兽效果1回合各能使用1次。
local s,id,o=GetID()
-- 初始化效果
function s.initial_effect(c)
	-- 添加灵摆怪兽属性
	aux.EnablePendulumAttribute(c)
	-- 自己不是灵摆怪兽不能灵摆召唤（这个效果不会被无效化）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	c:RegisterEffect(e1)
	-- 攻击力1000以下的怪兽特殊召唤的场合（伤害步骤除外）：可以让这张卡回到手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回到手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.pthcon)
	e2:SetTarget(s.pthtg)
	e2:SetOperation(s.pthop)
	c:RegisterEffect(e2)
	-- 自己灵摆区域有卡存在，这张卡在手卡存在的场合：可以把这张卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_HAND)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.hspcon)
	e3:SetTarget(s.hsptg)
	e3:SetOperation(s.hspop)
	c:RegisterEffect(e3)
	-- 可以支付1000基本分；自己手卡·场上（表侧表示）的1张灵摆怪兽卡破坏，那之后，可以从卡组把1只灵摆怪兽以表侧加入额外卡组。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,3))  --"破坏"
	e4:SetCategory(CATEGORY_DESTROY+CATEGORY_TOEXTRA)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id+o*2)
	e4:SetCost(s.descost)
	e4:SetTarget(s.destg)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)
end
-- 限制不能特招非灵摆怪兽
function s.splimit(e,c,tp,sumtp,sumpos)
	if not c then return false end
	return not c:IsType(TYPE_PENDULUM) and bit.band(sumtp,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
-- 用于过滤表侧表示且攻击力1000以下的怪兽
function s.pthfilter(c)
	return c:IsFaceup() and c:IsAttackBelow(1000)
end
-- 检查是否有攻击力1000以下的怪兽特殊召唤
function s.pthcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.pthfilter,1,nil)
end
-- 效果目标（发动时）：检查是否可以回到手卡
function s.pthtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置当前处理的连锁的操作信息为这张卡回到手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果处理：让这张卡回到手卡
function s.pthop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and c:IsAbleToHand() then
		-- 这张卡回到手卡
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
-- 检查自己灵摆区域是否有卡存在
function s.hspcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己灵摆区域是否有卡存在
	return Duel.GetMatchingGroupCount(aux.TRUE,tp,LOCATION_PZONE,0,nil)>0
end
-- 效果目标（发动时）：检查是否有空位可以特招
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否有怪兽区域的空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置当前处理的连锁的操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果处理：把这张卡特殊召唤
function s.hspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 把这张卡特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 发动代价：支付1000基本分
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以支付1000基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 支付1000基本分
	Duel.PayLPCost(tp,1000)
end
-- 用于过滤可以被破坏的灵摆怪兽卡
function s.desfilter(c)
	return c:GetOriginalType()&TYPE_PENDULUM~=0 and c:IsFaceupEx()
end
-- 用于过滤可以加入额外卡组的灵摆怪兽
function s.tedfilter(c)
	return c:IsAllTypes(TYPE_PENDULUM+TYPE_MONSTER) and c:IsAbleToExtra()
end
-- 效果目标（发动时）：检查破坏并加入额外卡组的条件是否满足
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡·场上是否存在可以被破坏的灵摆怪兽卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil) end
	-- 获取手卡·场上可以被破坏的灵摆怪兽卡
	local dg=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,nil)
	-- 如果手卡里有未公开的卡
	if Duel.GetFieldGroup(tp,LOCATION_HAND,0):FilterCount(aux.NOT(Card.IsPublic),nil)>0 then
		-- 设置当前处理的连锁的操作信息为破坏手卡·场上的卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_HAND+LOCATION_ONFIELD)
	else
		if dg:FilterCount(Card.IsLocation,nil,LOCATION_HAND)>0 then
			-- 设置当前处理的连锁的操作信息为破坏手卡·场上的卡
			Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,1,tp,LOCATION_HAND+LOCATION_ONFIELD)
		else
			-- 设置当前处理的连锁的操作信息为破坏场上的卡
			Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,1,tp,LOCATION_ONFIELD)
		end
	end
	-- 设置当前处理的连锁的操作信息为把卡组的灵摆怪兽加入额外卡组
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：破坏1张灵摆怪兽卡，然后从卡组把1只灵摆怪兽以表侧加入额外卡组
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示选择目标，内容为：“请选择要破坏的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择手卡·场上的1张灵摆怪兽卡
	local g=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)
	if g:GetCount()>0 then
		if g:FilterCount(Card.IsLocation,nil,LOCATION_ONFIELD)>0 then
			-- 向玩家提示场上被破坏卡的动画
			Duel.HintSelection(g)
		end
		-- 破坏那张卡
		if Duel.Destroy(g,REASON_EFFECT)>0
			-- 检查卡组是否有可以加入额外卡组的灵摆怪兽
			and Duel.IsExistingMatchingCard(s.tedfilter,tp,LOCATION_DECK,0,1,nil)
			-- 询问玩家是否发动后续效果
			and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then  --"是否把卡加入额外卡组？"
			-- 向玩家提示选择卡片，内容为：“请选择加入额外卡组的卡”
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,5))  --"请选择加入额外卡组的卡"
			-- 从卡组选择1只灵摆怪兽
			local tg=Duel.SelectMatchingCard(tp,s.tedfilter,tp,LOCATION_DECK,0,1,1,nil)
			if tg:GetCount()>0 then
				-- 把那1只灵摆怪兽加入额外卡组
				Duel.SendtoExtraP(tg,tp,REASON_EFFECT)
			end
		end
	end
end
