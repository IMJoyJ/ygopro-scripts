--バージェストマ・ピカイア
-- 效果：
-- ①：从手卡丢弃1张「伯吉斯异兽」卡。那之后，自己从卡组抽2张。
-- ②：陷阱卡发动时，连锁那个发动才能把这个效果在墓地发动。这张卡变成通常怪兽（水族·水·2星·攻1200/守0）在怪兽区域特殊召唤（不当作陷阱卡使用）。这个效果特殊召唤的这张卡不受怪兽的效果影响，从场上离开的场合除外。
function c24903843.initial_effect(c)
	-- 效果①：从手卡丢弃1张「伯吉斯异兽」卡。那之后，自己从卡组抽2张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c24903843.target)
	e1:SetOperation(c24903843.activate)
	c:RegisterEffect(e1)
	-- 效果②：陷阱卡发动时，连锁那个发动才能把这个效果在墓地发动。这张卡变成通常怪兽（水族·水·2星·攻1200/守0）在怪兽区域特殊召唤（不当作陷阱卡使用）。这个效果特殊召唤的这张卡不受怪兽的效果影响，从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e2:SetCondition(c24903843.spcon)
	e2:SetTarget(c24903843.sptg)
	e2:SetOperation(c24903843.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断手卡中是否存在可丢弃的「伯吉斯异兽」卡
function c24903843.filter(c)
	return c:IsSetCard(0xd4) and c:IsDiscardable(REASON_EFFECT)
end
-- 效果①的发动时点处理函数，检查是否满足发动条件
function c24903843.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2)
		-- 检查玩家手卡中是否存在至少1张「伯吉斯异兽」卡
		and Duel.IsExistingMatchingCard(c24903843.filter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 设置效果处理信息，表示将进行抽2张卡的操作
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果①的发动处理函数，执行丢弃卡并抽卡的操作
function c24903843.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 执行丢弃1张「伯吉斯异兽」卡的操作
	if Duel.DiscardHand(tp,c24903843.filter,1,1,REASON_EFFECT+REASON_DISCARD,nil)~=0 then
		-- 中断当前效果处理，使后续效果视为错时处理
		Duel.BreakEffect()
		-- 执行从卡组抽2张卡的操作
		Duel.Draw(tp,2,REASON_EFFECT)
	end
end
-- 效果②发动条件判断函数，判断是否为陷阱卡发动
function c24903843.spcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 效果②的发动时点处理函数，检查是否满足特殊召唤条件
function c24903843.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查玩家场上是否有可用怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否可以特殊召唤此卡为通常怪兽
		and Duel.IsPlayerCanSpecialSummonMonster(tp,24903843,0xd4,TYPES_NORMAL_TRAP_MONSTER,1200,0,2,RACE_AQUA,ATTRIBUTE_WATER) end
	-- 设置效果处理信息，表示将进行特殊召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果②的发动处理函数，执行特殊召唤并设置效果
function c24903843.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有可用怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	-- 检查此卡是否与当前效果相关联且可以特殊召唤
	if c:IsRelateToEffect(e) and Duel.IsPlayerCanSpecialSummonMonster(tp,24903843,0xd4,TYPES_NORMAL_TRAP_MONSTER,1200,0,2,RACE_AQUA,ATTRIBUTE_WATER) then
		c:AddMonsterAttribute(TYPE_NORMAL)
		-- 执行特殊召唤此卡到场上
		Duel.SpecialSummonStep(c,0,tp,tp,true,false,POS_FACEUP)
		-- 设置此卡获得免疫怪兽效果影响的效果
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_IMMUNE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetValue(c24903843.efilter)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2,true)
		-- 设置此卡离开场时被移除的效果
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e3:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e3,true)
		-- 完成特殊召唤流程
		Duel.SpecialSummonComplete()
	end
end
-- 免疫效果过滤函数，使此卡免疫怪兽效果的影响
function c24903843.efilter(e,re)
	return re:IsActiveType(TYPE_MONSTER)
end
