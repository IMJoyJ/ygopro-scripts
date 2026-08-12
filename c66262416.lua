--D-HERO ドリームガイ
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡在墓地存在，自己的「命运英雄」怪兽进行战斗的伤害计算时才能发动。这张卡从墓地特殊召唤，那只自己怪兽不会被那次战斗破坏，那次战斗发生的对自己的战斗伤害变成0。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c66262416.initial_effect(c)
	-- ①：这张卡在墓地存在，自己的「命运英雄」怪兽进行战斗的伤害计算时才能发动。这张卡从墓地特殊召唤，那只自己怪兽不会被那次战斗破坏，那次战斗发生的对自己的战斗伤害变成0。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(66262416,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,66262416)
	e1:SetCondition(c66262416.spcon)
	e1:SetTarget(c66262416.sptg)
	e1:SetOperation(c66262416.spop)
	c:RegisterEffect(e1)
end
-- 判断发动条件：进行战斗的怪兽是否为自己场上的「命运英雄」怪兽，并记录该怪兽
function c66262416.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前进行攻击的怪兽
	local tc=Duel.GetAttacker()
	-- 如果攻击怪兽是对方的，则将目标怪兽切换为被攻击的怪兽（即自己场上的怪兽）
	if tc:IsControler(1-tp) then tc=Duel.GetAttackTarget() end
	e:SetLabelObject(tc)
	return tc and tc:IsControler(tp) and tc:IsSetCard(0xc008)
end
-- 判断效果发动的可行性，并设置操作信息
function c66262416.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查阶段，判断自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 向系统宣告此效果包含将自身特殊召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：将自身特殊召唤，并适用不被战破、离场除外以及伤害变0的效果
function c66262416.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	-- 若此卡仍存在于墓地，则将其特殊召唤，并判断是否特殊召唤成功
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		if tc:IsRelateToBattle() then
			-- 那只自己怪兽不会被那次战斗破坏
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
			tc:RegisterEffect(e1)
		end
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e2:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e2,true)
		-- 那次战斗发生的对自己的战斗伤害变成0
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
		e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e3:SetTargetRange(1,0)
		e3:SetReset(RESET_PHASE+PHASE_DAMAGE)
		-- 将使战斗伤害变成0的效果注册给当前玩家
		Duel.RegisterEffect(e3,tp)
	end
end
