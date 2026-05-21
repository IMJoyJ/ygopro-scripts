--黄金郷のワッケーロ
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡发动后变成通常怪兽（不死族·光·5星·攻1800/守1500）在怪兽区域特殊召唤（也当作陷阱卡使用）。自己场上有「黄金卿 黄金国巫妖」存在的场合，可以再从自己或对方的墓地把1张卡除外。
-- ②：自己·对方的结束阶段，把墓地的这张卡除外才能发动。从卡组把1张「黄金国永生药」魔法·陷阱卡在自己场上盖放。
function c93191801.initial_effect(c)
	-- ①：这张卡发动后变成通常怪兽（不死族·光·5星·攻1800/守1500）在怪兽区域特殊召唤（也当作陷阱卡使用）。自己场上有「黄金卿 黄金国巫妖」存在的场合，可以再从自己或对方的墓地把1张卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(93191801,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,93191801)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c93191801.target)
	e1:SetOperation(c93191801.activate)
	c:RegisterEffect(e1)
	-- ②：自己·对方的结束阶段，把墓地的这张卡除外才能发动。从卡组把1张「黄金国永生药」魔法·陷阱卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(93191801,1))
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c93191801.setcon)
	e2:SetCountLimit(1,93191801)
	e2:SetHintTiming(TIMING_END_PHASE)
	-- 将墓地的这张卡除外作为发动效果的Cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c93191801.settg)
	e2:SetOperation(c93191801.setop)
	c:RegisterEffect(e2)
end
-- ①效果的发动准备与合法性检测
function c93191801.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查自己场上是否有空余的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否能将该卡作为特定属性、种族、攻防、等级的陷阱怪兽特殊召唤
		and Duel.IsPlayerCanSpecialSummonMonster(tp,93191801,0,TYPES_NORMAL_TRAP_MONSTER,1800,1500,5,RACE_ZOMBIE,ATTRIBUTE_LIGHT) end
	-- 设置连锁处理中的操作信息：特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 设置连锁处理中的操作信息：从双方墓地除外卡片
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,PLAYER_ALL,LOCATION_GRAVE)
end
-- 过滤函数：自己场上表侧表示的「黄金卿 黄金国巫妖」
function c93191801.filter(c)
	return c:IsFaceup() and c:IsCode(95440946)
end
-- ①效果的发动处理：特殊召唤自身为怪兽，若场上有「黄金卿 黄金国巫妖」则可以选双方墓地1张卡除外
function c93191801.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果处理时，再次检查是否能将该卡作为怪兽特殊召唤，不能则流程结束
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,93191801,0,TYPES_NORMAL_TRAP_MONSTER,1800,1500,5,RACE_ZOMBIE,ATTRIBUTE_LIGHT) then return end
	c:AddMonsterAttribute(TYPE_NORMAL+TYPE_TRAP)
	-- 将这张卡特殊召唤，并检查是否特殊召唤成功
	if Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)~=0
		-- 检查自己场上是否存在「黄金卿 黄金国巫妖」
		and Duel.IsExistingMatchingCard(c93191801.filter,tp,LOCATION_ONFIELD,0,1,nil)
		-- 检查双方墓地是否存在可以除外的卡
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil)
		-- 询问玩家是否选择进行除外操作
		and Duel.SelectYesNo(tp,aux.Stringid(93191801,2)) then  --"是否选卡除外？"
		-- 中断当前效果，使后续的除外处理与特殊召唤不视为同时处理
		Duel.BreakEffect()
		-- 提示玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 玩家从双方墓地选择1张可以除外的卡
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			-- 将选中的卡因效果表侧表示除外
			Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
		end
	end
end
-- 过滤函数：卡组中可以盖放的「黄金国永生药」魔法·陷阱卡
function c93191801.setfilter(c)
	return c:IsSetCard(0x2142) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- ②效果的发动条件：自己或对方的结束阶段
function c93191801.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前阶段是否为结束阶段
	return Duel.GetCurrentPhase()==PHASE_END
end
-- ②效果的发动准备与合法性检测
function c93191801.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以盖放的「黄金国永生药」魔陷
	if chk==0 then return Duel.IsExistingMatchingCard(c93191801.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- ②效果的发动处理：从卡组选1张「黄金国永生药」魔陷在自己场上盖放
function c93191801.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 玩家从卡组选择1张满足条件的「黄金国永生药」魔陷
	local g=Duel.SelectMatchingCard(tp,c93191801.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡在自己场上盖放
		Duel.SSet(tp,g)
	end
end
