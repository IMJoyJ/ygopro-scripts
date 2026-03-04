--ダイナレスラー・マーシャルアンガ
-- 效果：
-- ①：自己的「恐龙摔跤手」怪兽和持有那个攻击力以上的攻击力的怪兽进行战斗的伤害计算时，把这张卡从手卡送去墓地才能发动。那只自己怪兽不会被那次战斗破坏，那次伤害步骤结束后战斗阶段结束。
-- ②：这张卡为这张卡的效果发动而被送去墓地的回合的结束阶段，对方场上的怪兽数量比自己场上的怪兽多的场合才能发动。这张卡特殊召唤。
function c11755663.initial_effect(c)
	-- 效果原文：①：自己的「恐龙摔跤手」怪兽和持有那个攻击力以上的攻击力的怪兽进行战斗的伤害计算时，把这张卡从手卡送去墓地才能发动。那只自己怪兽不会被那次战斗破坏，那次伤害步骤结束后战斗阶段结束。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(11755663,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c11755663.atkcon)
	e1:SetCost(c11755663.atkcost)
	e1:SetOperation(c11755663.atkop)
	c:RegisterEffect(e1)
	-- 效果原文：②：这张卡为这张卡的效果发动而被送去墓地的回合的结束阶段，对方场上的怪兽数量比自己场上的怪兽多的场合才能发动。这张卡特殊召唤。
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
-- 判断是否满足效果①的发动条件，即是否为己方恐龙摔跤手怪兽与攻击力高于或等于其的怪兽战斗时
function c11755663.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前战斗中的攻击怪兽
	local tc=Duel.GetAttacker()
	-- 若攻击怪兽不是自己，则获取防守怪兽作为目标怪兽
	if tc:IsControler(1-tp) then tc=Duel.GetAttackTarget() end
	if not tc then return false end
	e:SetLabelObject(tc)
	local bc=tc:GetBattleTarget()
	return bc and tc:IsSetCard(0x11a) and bc:IsAttackAbove(tc:GetAttack())
end
-- 设置效果①的发动费用处理函数
function c11755663.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() end
	-- 将自身从手牌送去墓地作为发动费用
	Duel.SendtoGrave(c,REASON_COST)
	c:RegisterFlagEffect(11755663,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 设置效果①的发动效果处理函数
function c11755663.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	if tc:IsRelateToBattle() then
		-- 使目标怪兽在此次战斗中不会被战斗破坏
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		tc:RegisterEffect(e1)
		-- 在伤害步骤结束后跳过战斗阶段
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_DAMAGE_STEP_END)
		e2:SetOperation(c11755663.skipop)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		-- 将战斗阶段结束效果注册到游戏环境
		Duel.RegisterEffect(e2,tp)
	end
end
-- 定义战斗阶段结束时的处理函数
function c11755663.skipop(e,tp,eg,ep,ev,re,r,rp)
	-- 跳过当前回合玩家的战斗阶段
	Duel.SkipPhase(Duel.GetTurnPlayer(),PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
end
-- 判断是否满足效果②的发动条件，即是否为该卡因效果①被送去墓地且对方怪兽数量多于己方
function c11755663.sumcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetFlagEffect(11755663)>0
		-- 比较对方场上的怪兽数量是否大于己方场上的怪兽数量
		and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)<Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
end
-- 设置效果②的发动目标处理函数
function c11755663.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否有足够的特殊召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 设置效果②的发动效果处理函数
function c11755663.sumop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将自身从墓地特殊召唤到场上
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
