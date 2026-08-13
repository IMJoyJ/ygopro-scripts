--クリスタル・アバター
-- 效果：
-- ①：对方怪兽的直接攻击宣言时，那只怪兽的攻击力是自己基本分以上的场合才能发动。这张卡发动后变成和自己基本分数值相同攻击力的效果怪兽（战士族·光·4星·攻?/守0）在怪兽区域攻击表示特殊召唤。那之后，攻击对象转移为这张卡。这张卡也当作陷阱卡使用。
-- ②：这张卡的效果特殊召唤的这张卡被战斗破坏的伤害计算后发动。给与对方这张卡的攻击力数值的伤害。
function c20960340.initial_effect(c)
	-- ①：对方怪兽的直接攻击宣言时，那只怪兽的攻击力是自己基本分以上的场合才能发动。这张卡发动后变成和自己基本分数值相同攻击力的效果怪兽（战士族·光·4星·攻?/守0）在怪兽区域攻击表示特殊召唤。那之后，攻击对象转移为这张卡。这张卡也当作陷阱卡使用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c20960340.condition)
	e1:SetTarget(c20960340.target)
	e1:SetOperation(c20960340.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡的效果特殊召唤的这张卡被战斗破坏的伤害计算后发动。给与对方这张卡的攻击力数值的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(20960340,0))
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLED)
	e2:SetCondition(c20960340.damcon)
	e2:SetTarget(c20960340.damtg)
	e2:SetOperation(c20960340.damop)
	c:RegisterEffect(e2)
end
-- 效果发动条件：对方怪兽进行直接攻击宣言，且那只攻击怪兽的攻击力在我方当前基本分以上，满足条件才可发动。
function c20960340.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断攻击者为对方怪兽，且攻击对象为空，即为直接攻击。
	return Duel.GetAttacker():IsControler(1-tp) and Duel.GetAttackTarget()==nil
		-- 判断发动攻击的怪兽攻击力不小于我方当前基本分。
		and Duel.GetAttacker():IsAttackAbove(Duel.GetLP(tp))
end
-- 发动时目标处理：以我方当前基本分作为预定特召怪兽的攻击力，并检查主要怪兽区是否有空位以及能否将本卡作为效果陷阱怪兽特殊召唤，满足则登记特殊召唤操作信息。
function c20960340.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取我方当前基本分，作为之后特殊召唤怪兽的攻击力数值。
	local atk=Duel.GetLP(tp)
	if chk==0 then return e:IsCostChecked()
		-- 检查我方主要怪兽区是否存在可用空位。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查我方能否以表侧攻击表示特殊召唤一只战士族·光·4星·攻击力为atk、守备力为0的效果陷阱怪兽（即本卡）。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,20960340,0,TYPES_EFFECT_TRAP_MONSTER,atk,0,4,RACE_WARRIOR,ATTRIBUTE_LIGHT,POS_FACEUP_ATTACK) end
	-- 设置操作信息：本效果包含将自身特殊召唤，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：把本卡变成陷阱怪兽并特殊召唤，设定其攻击力为当前基本分；特招成功后将攻击对象转移为本卡。
function c20960340.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前基本分，作为本卡特殊召唤后的攻击力。
	local atk=Duel.GetLP(tp)
	-- 若此时仍不能将本卡作为效果陷阱怪兽特殊召唤，则直接不再处理。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,20960340,0,TYPES_EFFECT_TRAP_MONSTER,atk,0,4,RACE_WARRIOR,ATTRIBUTE_LIGHT,POS_FACEUP_ATTACK) then return end
	c:AddMonsterAttribute(TYPE_TRAP+TYPE_EFFECT)
	-- 将本卡以表侧攻击表示特殊召唤，召唤手续为自身效果，不检查召唤条件但保留苏生限制。
	if Duel.SpecialSummonStep(c,SUMMON_VALUE_SELF,tp,tp,true,false,POS_FACEUP_ATTACK) then
		-- 变成和自己基本分数值相同攻击力的效果怪兽
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
	-- 若特殊召唤整体成功数量为0，则中止后续转移攻击对象的处理。
	if Duel.SpecialSummonComplete()==0 then return end
	-- 获取发动直接攻击的那只攻击怪兽。
	local at=Duel.GetAttacker()
	if at and at:IsAttackable() and at:IsFaceup() and not at:IsImmuneToEffect(e) and not at:IsStatus(STATUS_ATTACK_CANCELED) then
		-- 中断当前效果处理，使后续攻击对象转移作为另行处理，避免时点被占用。
		Duel.BreakEffect()
		-- 将攻击对象变更为特殊召唤成功后的这张卡。
		Duel.ChangeAttackTarget(c)
	end
end
-- ②效果发动条件：本卡是通过自身效果特殊召唤的，并且在该次战斗伤害计算后被战斗破坏，满足才可发动。
function c20960340.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsStatus(STATUS_BATTLE_DESTROYED) and c:GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- ②效果发动时目标处理：记录对方玩家为对象玩家，伤害数值为本卡当前攻击力。
function c20960340.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local dam=e:GetHandler():GetAttack()
	-- 设置效果的对象玩家为对方玩家。
	Duel.SetTargetPlayer(1-tp)
	-- 设置效果参数为将要造成的伤害数值（本卡当前攻击力）。
	Duel.SetTargetParam(dam)
	-- 设置操作信息：本效果将造成伤害，对象为对方玩家，伤害值为dam。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- ②效果处理：对记录的对象玩家造成本卡当前攻击力数值的伤害。
function c20960340.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出之前设定的对象玩家。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 以效果原因对对象玩家造成本卡当前攻击力数值的伤害。
	Duel.Damage(p,e:GetHandler():GetAttack(),REASON_EFFECT)
end
