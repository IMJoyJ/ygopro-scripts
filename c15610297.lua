--方界胤ヴィジャム
-- 效果：
-- ①：这张卡不会被战斗破坏。
-- ②：这张卡和对方怪兽进行战斗的伤害步骤结束时才能发动。怪兽区域的这张卡当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置，给那只对方怪兽放置1个方界指示物。有方界指示物放置的怪兽不能攻击，效果无效化。
-- ③：这张卡的效果让这张卡当作永续魔法卡使用的场合，自己主要阶段才能发动。魔法与陷阱区域的这张卡特殊召唤。
function c15610297.initial_effect(c)
	-- ①：这张卡不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ②：这张卡和对方怪兽进行战斗的伤害步骤结束时才能发动。怪兽区域的这张卡当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置，给那只对方怪兽放置1个方界指示物。有方界指示物放置的怪兽不能攻击，效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(15610297,0))
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DAMAGE_STEP_END)
	e2:SetTarget(c15610297.distg)
	e2:SetOperation(c15610297.disop)
	c:RegisterEffect(e2)
	-- ③：这张卡的效果让这张卡当作永续魔法卡使用的场合，自己主要阶段才能发动。魔法与陷阱区域的这张卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(15610297,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c15610297.spcon)
	e3:SetTarget(c15610297.sptg)
	e3:SetOperation(c15610297.spop)
	c:RegisterEffect(e3)
end
-- 检索满足条件的对方怪兽并确认其是否为表侧表示、是否参与战斗、是否能放置方界指示物，同时确认自身是否在怪兽区域且参与战斗，以及玩家魔法与陷阱区域是否有空位。
function c15610297.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if chk==0 then return bc and bc:IsFaceup() and bc:IsRelateToBattle() and bc:IsCanAddCounter(0x1038,1)
		and c:IsLocation(LOCATION_MZONE) and c:IsRelateToBattle()
		-- 确认玩家魔法与陷阱区域是否有空位。
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
end
-- 处理效果发动时的条件判断和执行流程，包括将自身移至魔法与陷阱区域、改变卡片类型为魔法卡、设置标志位、给对方怪兽放置方界指示物并使其不能攻击和效果无效。
function c15610297.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsImmuneToEffect(e) or not c:IsLocation(LOCATION_MZONE) then return end
	-- 尝试将自身移动到玩家的魔法与陷阱区域。
	if not Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then return end
	-- 将自身卡片类型更改为魔法卡+永续类型。
	local e1=Effect.CreateEffect(c)
	e1:SetCode(EFFECT_CHANGE_TYPE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
	e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
	c:RegisterEffect(e1)
	c:RegisterFlagEffect(15610297,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET,0,1)
	local bc=c:GetBattleTarget()
	if bc:IsRelateToBattle() and bc:IsFaceup() then
		bc:AddCounter(0x1038,1)
		-- 使放置了方界指示物的对方怪兽不能攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetCondition(c15610297.condition)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		bc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE)
		bc:RegisterEffect(e2)
	end
end
-- 判断对方怪兽是否拥有方界指示物。
function c15610297.condition(e)
	return e:GetHandler():GetCounter(0x1038)>0
end
-- 判断是否已通过效果将自身当作魔法卡使用。
function c15610297.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(15610297)~=0
end
-- 检索满足条件的特殊召唤目标，确认玩家场上是否有空位及自身是否可特殊召唤。
function c15610297.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认玩家场上是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，表示即将特殊召唤此卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作，将自身以正面表示形式特殊召唤到玩家场上。
function c15610297.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将自身以正面表示形式特殊召唤到玩家场上。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
