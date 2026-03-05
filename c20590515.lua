--黄金郷のコンキスタドール
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡发动后变成通常怪兽（不死族·光·5星·攻500/守1800）在怪兽区域特殊召唤（也当作陷阱卡使用）。自己场上有「黄金卿 黄金国巫妖」存在的场合，可以再把场上1张表侧表示卡破坏。
-- ②：自己·对方的结束阶段，把墓地的这张卡除外才能发动。从卡组把1张「黄金国永生药」魔法·陷阱卡在自己场上盖放。
function c20590515.initial_effect(c)
	-- ①：这张卡发动后变成通常怪兽（不死族·光·5星·攻500/守1800）在怪兽区域特殊召唤（也当作陷阱卡使用）。自己场上有「黄金卿 黄金国巫妖」存在的场合，可以再把场上1张表侧表示卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20590515,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,20590515)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c20590515.target)
	e1:SetOperation(c20590515.activate)
	c:RegisterEffect(e1)
	-- ②：自己·对方的结束阶段，把墓地的这张卡除外才能发动。从卡组把1张「黄金国永生药」魔法·陷阱卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(20590515,1))
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c20590515.setcon)
	e2:SetCountLimit(1,20590515)
	e2:SetHintTiming(TIMING_END_PHASE)
	-- 将这张卡除外作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c20590515.settg)
	e2:SetOperation(c20590515.setop)
	c:RegisterEffect(e2)
end
-- 效果发动时的check条件，检查是否满足特殊召唤的条件
function c20590515.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查玩家场上是否有足够的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否可以特殊召唤此卡为通常陷阱怪兽
		and Duel.IsPlayerCanSpecialSummonMonster(tp,20590515,0,TYPES_NORMAL_TRAP_MONSTER,500,1800,5,RACE_ZOMBIE,ATTRIBUTE_LIGHT) end
	-- 设置效果处理时要特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 过滤函数，用于判断场上是否存在「黄金卿 黄金国巫妖」
function c20590515.filter(c)
	return c:IsFaceup() and c:IsCode(95440946)
end
-- 效果处理函数，将此卡特殊召唤为通常陷阱怪兽，并在满足条件时选择破坏一张场上表侧表示卡
function c20590515.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查玩家是否可以特殊召唤此卡为通常陷阱怪兽
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,20590515,0,TYPES_NORMAL_TRAP_MONSTER,500,1800,5,RACE_ZOMBIE,ATTRIBUTE_LIGHT) then return end
	c:AddMonsterAttribute(TYPE_NORMAL+TYPE_TRAP)
	-- 将此卡特殊召唤到场上
	if Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)~=0
		-- 检查玩家场上是否存在「黄金卿 黄金国巫妖」
		and Duel.IsExistingMatchingCard(c20590515.filter,tp,LOCATION_ONFIELD,0,1,nil)
		-- 检查玩家场上是否存在至少一张表侧表示的怪兽
		and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
		-- 询问玩家是否选择破坏一张场上表侧表示卡
		and Duel.SelectYesNo(tp,aux.Stringid(20590515,2)) then  --"是否选卡破坏？"
		-- 中断当前效果处理，使后续效果视为不同时处理
		Duel.BreakEffect()
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择场上一张表侧表示的卡作为破坏对象
		local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		-- 显示选卡破坏的动画效果
		Duel.HintSelection(g)
		local tc=g:GetFirst()
		if tc then
			-- 将选中的卡破坏
			Duel.Destroy(tc,REASON_EFFECT)
		end
	end
end
-- 过滤函数，用于选择卡组中可盖放的「黄金国永生药」魔法·陷阱卡
function c20590515.setfilter(c)
	return c:IsSetCard(0x2142) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- 效果发动条件，判断是否处于结束阶段
function c20590515.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否为结束阶段
	return Duel.GetCurrentPhase()==PHASE_END
end
-- 效果发动时的check条件，检查卡组中是否存在满足条件的卡
function c20590515.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少一张可盖放的「黄金国永生药」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c20590515.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 效果处理函数，从卡组选择一张「黄金国永生药」魔法·陷阱卡盖放
function c20590515.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从卡组选择一张满足条件的卡作为盖放对象
	local g=Duel.SelectMatchingCard(tp,c20590515.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡盖放到场上
		Duel.SSet(tp,g)
	end
end
