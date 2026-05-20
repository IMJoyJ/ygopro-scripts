--ファイアウォール・ガーディアン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡作为电子界族连接怪兽的连接素材送去墓地的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
-- ②：自己和对方的连接怪兽之间进行战斗的攻击宣言时把墓地的这张卡除外才能发动。那次攻击无效，那只对方怪兽直到回合结束时原本攻击力变成0，不受自身以外的卡的效果影响。
function c86605184.initial_effect(c)
	-- ①：这张卡作为电子界族连接怪兽的连接素材送去墓地的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(86605184,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetCountLimit(1,86605184)
	e1:SetCondition(c86605184.spcon)
	e1:SetTarget(c86605184.sptg)
	e1:SetOperation(c86605184.spop)
	c:RegisterEffect(e1)
	-- ②：自己和对方的连接怪兽之间进行战斗的攻击宣言时把墓地的这张卡除外才能发动。那次攻击无效，那只对方怪兽直到回合结束时原本攻击力变成0，不受自身以外的卡的效果影响。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(86605184,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,86605185)
	e2:SetCondition(c86605184.discon)
	-- 把墓地的这张卡除外作为发动的代价。
	e2:SetCost(aux.bfgcost)
	e2:SetOperation(c86605184.disop)
	c:RegisterEffect(e2)
end
-- 检查这张卡是否作为电子界族连接怪兽的连接素材送去墓地。
function c86605184.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and r==REASON_LINK and c:GetReasonCard():IsRace(RACE_CYBERSE)
end
-- 效果①的发动准备，检查自身是否可以特殊召唤并设置特殊召唤的操作信息。
function c86605184.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，表示将特殊召唤1张卡（自身）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果①的处理，将自身特殊召唤，并添加离场时除外的效果。
function c86605184.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自身是否仍与效果相关，并尝试将自身以表侧表示特殊召唤。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。自己和对方的连接怪兽之间进行战斗的攻击宣言时把墓地的这张卡除外才能发动。那次攻击无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
-- 检查进行战斗的双方怪兽是否均为连接怪兽。
function c86605184.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗的攻击怪兽。
	local a=Duel.GetAttacker()
	-- 获取本次战斗的被攻击怪兽（攻击目标）。
	local d=Duel.GetAttackTarget()
	return a~=nil and d~=nil and a:IsType(TYPE_LINK) and d:IsType(TYPE_LINK)
end
-- 效果②的处理，使该次攻击无效，并使那只对方怪兽直到回合结束时原本攻击力变成0，且不受自身以外的卡的效果影响。
function c86605184.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取攻击怪兽。
	local tc=Duel.GetAttacker()
	-- 如果攻击怪兽是己方的，则将目标怪兽指向对方的被攻击怪兽；否则目标怪兽为对方的攻击怪兽（即确定对方怪兽）。
	if tc:IsControler(tp) then tc=Duel.GetAttackTarget() end
	-- 尝试无效该次攻击，若成功则继续处理后续效果。
	if Duel.NegateAttack() then
		-- 那只对方怪兽直到回合结束时原本攻击力变成0
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_BASE_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 不受自身以外的卡的效果影响
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_IMMUNE_EFFECT)
		e2:SetValue(c86605184.efilter)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
-- 免疫效果过滤器，使该怪兽不受此卡（防火守护者）以外的卡片效果影响。
function c86605184.efilter(e,re)
	return e:GetHandler()~=re:GetOwner()
end
