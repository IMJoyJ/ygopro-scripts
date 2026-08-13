--バージェストマ・エルドニア
-- 效果：
-- ①：以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力·守备力直到回合结束时上升500。
-- ②：陷阱卡发动时，连锁那个发动才能把这个效果在墓地发动。这张卡变成通常怪兽（水族·水·2星·攻1200/守0）在怪兽区域特殊召唤（不当作陷阱卡使用）。这个效果特殊召唤的这张卡不受怪兽的效果影响，从场上离开的场合除外。
function c2376209.initial_effect(c)
	-- ①：以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力·守备力直到回合结束时上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置①效果在伤害步骤中仅能在伤害计算前发动（伤害计算后不能发动）。
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c2376209.target)
	e1:SetOperation(c2376209.operation)
	c:RegisterEffect(e1)
	-- ②：陷阱卡发动时，连锁那个发动才能把这个效果在墓地发动。这张卡变成通常怪兽（水族·水·2星·攻1200/守0）在怪兽区域特殊召唤（不当作陷阱卡使用）。这个效果特殊召唤的这张卡不受怪兽的效果影响，从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(2376209,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e2:SetCondition(c2376209.spcon)
	e2:SetTarget(c2376209.sptg)
	e2:SetOperation(c2376209.spop)
	c:RegisterEffect(e2)
end
-- ①效果的发动时选择对象：从双方场上选择1只表侧表示怪兽作为对象。
function c2376209.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 效果发动合法性检查：确认场上存在至少1只表侧表示怪兽可供选择。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向操作玩家发出选择表侧表示怪兽的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只表侧表示怪兽作为效果对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- ①效果处理：使对象怪兽的攻击力和守备力直到回合结束时上升500。
function c2376209.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只怪兽的攻击力·守备力直到回合结束时上升500。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
	end
end
-- ②效果的发动条件：有陷阱卡发动时，连锁该陷阱卡的发动才可在墓地发动此效果。
function c2376209.spcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- ②效果发动时检查：自己怪兽区域有空位，且自己可以将这张卡作为通常怪兽特殊召唤。
function c2376209.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 效果发动合法性检查：自己主要怪兽区域有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且允许自己特殊召唤这张卡（作为水族·水·2星·攻1200/守0的通常怪兽）。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,2376209,0xd4,TYPES_NORMAL_TRAP_MONSTER,1200,0,2,RACE_AQUA,ATTRIBUTE_WATER) end
	-- 设置操作信息：本次连锁处理包含特殊召唤这张卡（供相关效果查询）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ②效果处理：在满足条件时，将这张卡变成通常怪兽特殊召唤，并附加“不受怪兽效果影响”和“离场除外”。
function c2376209.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时如果自己怪兽区域没有空位，则直接终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	-- 确认这张卡仍与效果关联（没有离场），且自己仍可特殊召唤它。
	if c:IsRelateToEffect(e) and Duel.IsPlayerCanSpecialSummonMonster(tp,2376209,0xd4,TYPES_NORMAL_TRAP_MONSTER,1200,0,2,RACE_AQUA,ATTRIBUTE_WATER) then
		c:AddMonsterAttribute(TYPE_NORMAL)
		-- 将这张卡以表侧表示特殊召唤到自己怪兽区域（分步特殊召唤中的一步）。
		Duel.SpecialSummonStep(c,0,tp,tp,true,false,POS_FACEUP)
		-- 这个效果特殊召唤的这张卡不受怪兽的效果影响。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_IMMUNE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetValue(c2376209.efilter)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2,true)
		-- 从场上离开的场合除外。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e3:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e3,true)
		-- 完成分步特殊召唤，结算特殊召唤成功。
		Duel.SpecialSummonComplete()
	end
end
-- 免疫效果的过滤函数：仅当效果发动者为怪兽时返回真，从而实现“不受怪兽的效果影响”。
function c2376209.efilter(e,re)
	return re:IsActiveType(TYPE_MONSTER)
end
