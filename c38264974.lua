--幻想魔獣キマイラ
-- 效果：
-- 「有翼幻兽 奇美拉」＋幻想魔族怪兽1只以上
-- ①：这张卡的卡名只要在场上·墓地存在当作「有翼幻兽 奇美拉」使用。
-- ②：这张卡在同1次的战斗阶段中可以向怪兽作出最多有作为这张卡的融合素材的怪兽数量的攻击。
-- ③：这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏。
-- ④：这张卡和对方怪兽进行战斗的伤害步骤结束时才能发动。那只对方怪兽的攻击力变成0，效果无效化。
local s,id,o=GetID()
-- 定义初始化函数，为这张卡启用苏生限制、注册融合素材条件（有翼幻兽奇美拉+幻想魔族怪兽）、场上·墓地卡名变成「有翼幻兽 奇美拉」的效果，以及②额外攻击、③战斗破坏抗性、④伤害步骤结束时降攻无效的触发效果。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 注册融合召唤手续：以卡号4796100的「有翼幻兽 奇美拉」1只，加上1～127只幻想魔族怪兽作为融合素材。
	aux.AddFusionProcCodeFunRep(c,4796100,aux.FilterBoolFunction(Card.IsRace,RACE_ILLUSION),1,127,true,true)
	-- 使这张卡在场上·墓地存在时卡名当作「有翼幻兽 奇美拉」使用，即①的卡名变更效果。
	aux.EnableChangeCode(c,4796100,LOCATION_GRAVE+LOCATION_MZONE)
	-- 这张卡在同1次的战斗阶段中可以向怪兽作出最多有作为这张卡的融合素材的怪兽数量的攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e1:SetValue(s.atkct)
	c:RegisterEffect(e1)
	-- 这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(s.indtg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 这张卡和对方怪兽进行战斗的伤害步骤结束时才能发动。那只对方怪兽的攻击力变成0，效果无效化。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DAMAGE_STEP_END)
	-- 设置④的发动条件为“伤害步骤结束时，且此卡仍与战斗相关（未离场或处于被战斗破坏状态）”。
	e3:SetCondition(aux.dsercon)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
end
-- 定义③的效果适用对象过滤：只让这张卡自身以及和它进行战斗的那只怪兽受到“不会被战斗破坏”的影响。
function s.indtg(e,c)
	local tc=e:GetHandler()
	return c==tc or c==tc:GetBattleTarget()
end
-- 计算②的额外攻击次数：若这张卡是融合召唤，则额外攻击次数为融合素材数量减1（本身已有1次常规攻击），否则为0。
function s.atkct(e,c)
	return c:IsSummonType(SUMMON_TYPE_FUSION) and c:GetMaterialCount()-1 or 0
end
-- ④的发动对象选择：取得这张卡的战斗对象，确认其仍与战斗相关且可被降攻或无效，然后将其设为无效化操作的对象。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetHandler():GetBattleTarget()
	-- 发动条件判定：仅当战斗对象仍与本次战斗相关，并且它满足攻击力大于0（可降为0）或为可被无效的效果怪兽时，④可以发动。
	if chk==0 then return bc and bc:IsRelateToBattle() and (aux.nzatk(bc) or aux.NegateMonsterFilter(bc)) end
	-- 设置操作信息：将战斗对象标记为CATEGORY_DISABLE要无效化的对象，以便后续连锁检测和效果处理。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,bc,1,0,0)
end
-- ④的效果处理：若战斗对象仍与战斗相关且表侧表示，则将其攻击力变成0，使其效果无效（EFFECT_DISABLE和EFFECT_DISABLE_EFFECT），并无效化该对象相关的连锁。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if bc:IsRelateToBattle() and bc:IsFaceup() then
		-- 那只对方怪兽的攻击力变成0
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		bc:RegisterEffect(e1)
		-- 使与该战斗对象怪兽相关的连锁全部无效化，并以该怪兽变里侧表示作为无效状态的重置时机（RESET_TURN_SET）。
		Duel.NegateRelatedChain(bc,RESET_TURN_SET)
		-- 效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		bc:RegisterEffect(e2)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetValue(RESET_TURN_SET)
		bc:RegisterEffect(e3)
	end
end
