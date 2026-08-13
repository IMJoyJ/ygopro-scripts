--ダイナレスラー・マーシャルアンガ
-- 效果：
-- ①：自己的「恐龙摔跤手」怪兽和持有那个攻击力以上的攻击力的怪兽进行战斗的伤害计算时，把这张卡从手卡送去墓地才能发动。那只自己怪兽不会被那次战斗破坏，那次伤害步骤结束后战斗阶段结束。
-- ②：这张卡为这张卡的效果发动而被送去墓地的回合的结束阶段，对方场上的怪兽数量比自己场上的怪兽多的场合才能发动。这张卡特殊召唤。
function c11755663.initial_effect(c)
	-- ①：自己的「恐龙摔跤手」怪兽和持有那个攻击力以上的攻击力的怪兽进行战斗的伤害计算时，把这张卡从手卡送去墓地才能发动。那只自己怪兽不会被那次战斗破坏，那次伤害步骤结束后战斗阶段结束。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(11755663,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c11755663.atkcon)
	e1:SetCost(c11755663.atkcost)
	e1:SetOperation(c11755663.atkop)
	c:RegisterEffect(e1)
	-- ②：这张卡为这张卡的效果发动而被送去墓地的回合的结束阶段，对方场上的怪兽数量比自己场上的怪兽多的场合才能发动。这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(11755663,1))
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1)
	e2:SetCondition(c11755663.sumcon)
	e2:SetTarget(c11755663.sumtg)
	e2:SetOperation(c11755663.sumop)
	c:RegisterEffect(e2)
end
-- ①效果发动条件判定：在伤害计算时确定己方存在「恐龙摔跤手」怪兽（从攻击者或攻击目标中取得），且其战斗对象的攻击力不低于该怪兽的攻击力；成立后将己方怪兽存入效果标签供处理阶段使用。
function c11755663.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前战斗的发动攻击的怪兽作为候选判定对象。
	local tc=Duel.GetAttacker()
	-- 若攻击者由对方控制，则改用被攻击的己方怪兽作为判定对象。
	if tc:IsControler(1-tp) then tc=Duel.GetAttackTarget() end
	if not tc then return false end
	e:SetLabelObject(tc)
	local bc=tc:GetBattleTarget()
	return bc and tc:IsSetCard(0x11a) and bc:IsAttackAbove(tc:GetAttack())
end
-- ①效果发动代价：确认此卡在手卡且可作为代价送墓，若满足则将其送入墓地，并给此卡打上标记以备②效果回合结束阶段判断。
function c11755663.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() end
	-- 以发动代价的形式将这张卡从手卡送入墓地。
	Duel.SendtoGrave(c,REASON_COST)
	c:RegisterFlagEffect(11755663,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- ①效果处理：若记录的己方怪兽仍处于战斗相关状态，则赋予其不会被那次战斗破坏的效果，并注册一个在伤害步骤结束时跳过战斗阶段的持续效果。
function c11755663.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	if tc:IsRelateToBattle() then
		-- 那只自己怪兽不会被那次战斗破坏。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		tc:RegisterEffect(e1)
		-- 那次伤害步骤结束后战斗阶段结束。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_DAMAGE_STEP_END)
		e2:SetOperation(c11755663.skipop)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		-- 把伤害步骤结束时跳过战斗阶段的持续效果注册到当前玩家场上，使其在该时点生效。
		Duel.RegisterEffect(e2,tp)
	end
end
-- 持续效果的操作函数：在伤害步骤结束时触发，使当前回合玩家的战斗阶段被跳过。
function c11755663.skipop(e,tp,eg,ep,ev,re,r,rp)
	-- 跳过当前回合玩家的战斗阶段，并在战斗步骤结束时重置该跳过效果（相当于让战斗阶段结束）。
	Duel.SkipPhase(Duel.GetTurnPlayer(),PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
end
-- ②效果发动条件判定：这张卡带有因①效果发动而送墓的标记，并且结束阶段时对方场上的怪兽数量多于己方场上的怪兽数量。
function c11755663.sumcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetFlagEffect(11755663)>0
		-- 比较双方主要怪兽区的怪兽数量：己方数量少于对方数量（即对方场上的怪兽数量比自己场上的多）。
		and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)<Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
end
-- ②效果发动目标检查：确认此卡本身可以被特殊召唤，并且己方主要怪兽区有空位可用。
function c11755663.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动时确认自己场上存在可用的主要怪兽区空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息为特殊召唤这张卡，数量为1，供相关卡片的连锁检测与发动判定使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ②效果处理：此卡仍与该效果有关联时，将其特殊召唤到自己场上。
function c11755663.sumop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己场上（不检查召唤条件与苏生限制）。
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
