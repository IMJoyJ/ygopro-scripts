--黄金郷のガーディアン
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡发动后变成通常怪兽（不死族·光·8星·攻800/守2500）在怪兽区域特殊召唤。这张卡也当作陷阱卡使用。自己场上有「黄金卿 黄金国巫妖」存在的场合，可以再选场上1只表侧表示怪兽把攻击力变成0。
-- ②：自己·对方的结束阶段把墓地的这张卡除外才能发动。从卡组选1张「黄金国永生药」魔法·陷阱卡在自己场上盖放。
function c67007102.initial_effect(c)
	-- ①：这张卡发动后变成通常怪兽（不死族·光·8星·攻800/守2500）在怪兽区域特殊召唤。这张卡也当作陷阱卡使用。自己场上有「黄金卿 黄金国巫妖」存在的场合，可以再选场上1只表侧表示怪兽把攻击力变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(67007102,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,67007102)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c67007102.target)
	e1:SetOperation(c67007102.activate)
	c:RegisterEffect(e1)
	-- ②：自己·对方的结束阶段把墓地的这张卡除外才能发动。从卡组选1张「黄金国永生药」魔法·陷阱卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(67007102,1))
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c67007102.setcon)
	e2:SetCountLimit(1,67007102)
	e2:SetHintTiming(TIMING_END_PHASE)
	-- 把墓地的这张卡除外作为发动的cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c67007102.settg)
	e2:SetOperation(c67007102.setop)
	c:RegisterEffect(e2)
end
-- 过滤场上表侧表示且攻击力大于0的怪兽
function c67007102.atkfilter(c)
	return c:IsFaceup() and c:GetAttack()>0
end
-- ①号效果（发动并特殊召唤）的发动准备与合法性检测
function c67007102.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查自己场上是否有空余的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否能将该卡作为特定属性、种族、攻守的怪兽特殊召唤
		and Duel.IsPlayerCanSpecialSummonMonster(tp,67007102,0,TYPES_NORMAL_TRAP_MONSTER,800,2500,8,RACE_ZOMBIE,ATTRIBUTE_LIGHT) end
	-- 设置连锁处理中的操作信息为特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 过滤场上表侧表示的「黄金卿 黄金国巫妖」
function c67007102.filter(c)
	return c:IsFaceup() and c:IsCode(95440946)
end
-- ①号效果的发动处理（特殊召唤并尝试将1只怪兽攻击力变成0）
function c67007102.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果处理时，再次检查是否能将该卡作为怪兽特殊召唤，不能则结束处理
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,67007102,0,TYPES_NORMAL_TRAP_MONSTER,800,2500,8,RACE_ZOMBIE,ATTRIBUTE_LIGHT) then return end
	c:AddMonsterAttribute(TYPE_NORMAL+TYPE_TRAP)
	-- 尝试将这张卡在自己场上表侧表示特殊召唤，并判断是否成功
	if Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)~=0
		-- 检查自己场上是否存在「黄金卿 黄金国巫妖」
		and Duel.IsExistingMatchingCard(c67007102.filter,tp,LOCATION_ONFIELD,0,1,nil)
		-- 检查场上是否存在可以改变攻击力的表侧表示怪兽
		and Duel.IsExistingMatchingCard(c67007102.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		-- 询问玩家是否选择将场上1只表侧表示怪兽的攻击力变成0
		and Duel.SelectYesNo(tp,aux.Stringid(67007102,2)) then  --"是否选卡攻击力变成0？"
		-- 中断当前效果处理，使后续的攻击力变为0处理与特殊召唤不视为同时进行
		Duel.BreakEffect()
		-- 玩家选择场上1只表侧表示且攻击力大于0的怪兽
		local g=Duel.SelectMatchingCard(tp,c67007102.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
		-- 选中卡片时在场上闪烁提示
		Duel.HintSelection(g)
		local tc=g:GetFirst()
		if tc then
			-- 把攻击力变成0
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetValue(0)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
end
-- 过滤卡组中可以盖放的「黄金国永生药」魔法·陷阱卡
function c67007102.setfilter(c)
	return c:IsSetCard(0x2142) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- ②号效果的发动条件判定（自己或对方的结束阶段）
function c67007102.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为结束阶段
	return Duel.GetCurrentPhase()==PHASE_END
end
-- ②号效果的发动准备与合法性检测
function c67007102.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可盖放的「黄金国永生药」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c67007102.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- ②号效果的发动处理（从卡组选1张「黄金国永生药」魔陷在场上盖放）
function c67007102.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 玩家从卡组选择1张满足条件的「黄金国永生药」卡片
	local g=Duel.SelectMatchingCard(tp,c67007102.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡片在自己场上盖放
		Duel.SSet(tp,g)
	end
end
