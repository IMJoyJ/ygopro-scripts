--幻想魔獣キマイラ
-- 效果：
-- 「有翼幻兽 奇美拉」＋幻想魔族怪兽1只以上
-- ①：这张卡的卡名只要在场上·墓地存在当作「有翼幻兽 奇美拉」使用。
-- ②：这张卡在同1次的战斗阶段中可以向怪兽作出最多有作为这张卡的融合素材的怪兽数量的攻击。
-- ③：这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏。
-- ④：这张卡和对方怪兽进行战斗的伤害步骤结束时才能发动。那只对方怪兽的攻击力变成0，效果无效化。
local s,id,o=GetID()
-- 初始化卡片效果，设置融合召唤条件、卡号变更、额外攻击、战斗不可破坏和伤害步骤结束时的效果触发条件
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用卡号为4796100的怪兽和满足种族为幻想魔族条件的怪兽作为融合素材
	aux.AddFusionProcCodeFunRep(c,4796100,aux.FilterBoolFunction(Card.IsRace,RACE_ILLUSION),1,127,true,true)
	-- 设置该卡在墓地和场上时视为卡号为4796100的卡（有翼幻兽 奇美拉）
	aux.EnableChangeCode(c,4796100,LOCATION_GRAVE+LOCATION_MZONE)
	-- ②：这张卡在同1次的战斗阶段中可以向怪兽作出最多有作为这张卡的融合素材的怪兽数量的攻击
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e1:SetValue(s.atkct)
	c:RegisterEffect(e1)
	-- ③：这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(s.indtg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ④：这张卡和对方怪兽进行战斗的伤害步骤结束时才能发动。那只对方怪兽的攻击力变成0，效果无效化
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DAMAGE_STEP_END)
	-- 效果发动条件为该卡参与战斗且战斗阶段结束时
	e3:SetCondition(aux.dsercon)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
end
-- 判断目标是否为自身或自身战斗中的对手怪兽
function s.indtg(e,c)
	local tc=e:GetHandler()
	return c==tc or c==tc:GetBattleTarget()
end
-- 计算该卡融合召唤时的额外攻击次数
function s.atkct(e,c)
	return c:IsSummonType(SUMMON_TYPE_FUSION) and c:GetMaterialCount()-1 or 0
end
-- 设置效果目标为战斗中的对方怪兽，检查其是否有效且可被处理
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetHandler():GetBattleTarget()
	-- 判断目标怪兽是否参与战斗且攻击力不为0或可被无效化
	if chk==0 then return bc and bc:IsRelateToBattle() and (aux.nzatk(bc) or aux.NegateMonsterFilter(bc)) end
	-- 设置连锁操作信息，标记将要使目标怪兽效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,bc,1,0,0)
end
-- 执行效果操作，将目标怪兽攻击力设为0并使其效果无效
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if bc:IsRelateToBattle() and bc:IsFaceup() then
		-- 将目标怪兽攻击力设为0
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		bc:RegisterEffect(e1)
		-- 使目标怪兽相关的连锁效果无效化
		Duel.NegateRelatedChain(bc,RESET_TURN_SET)
		-- 使目标怪兽效果无效
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
