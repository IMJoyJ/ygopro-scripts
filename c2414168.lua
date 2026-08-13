--インタラプト・レジスタンス
-- 效果：
-- ①：自己受到战斗伤害时才能发动。这张卡从手卡特殊召唤。这个效果特殊召唤的这张卡的攻击力上升受到的伤害的数值。
-- ②：1回合1次，这张卡以外的自己的守备表示怪兽被对方怪兽攻击的伤害计算时才能发动。那只自己怪兽只在那次伤害计算时变成和这张卡相同守备力，不会被那次战斗破坏。
function c2414168.initial_effect(c)
	-- ①：自己受到战斗伤害时才能发动。这张卡从手卡特殊召唤。这个效果特殊召唤的这张卡的攻击力上升受到的伤害的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2414168,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c2414168.spcon)
	e1:SetTarget(c2414168.sptg)
	e1:SetOperation(c2414168.spop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，这张卡以外的自己的守备表示怪兽被对方怪兽攻击的伤害计算时才能发动。那只自己怪兽只在那次伤害计算时变成和这张卡相同守备力，不会被那次战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(2414168,1))
	e2:SetCategory(CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c2414168.defcon)
	e2:SetOperation(c2414168.defop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件：判断本次战斗伤害的承受方是我方，即自己受到战斗伤害时才能发动。
function c2414168.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end
-- 效果①发动时进行合法性判定：检查我方主要怪兽区域是否有空位，并且这张手卡中的这张卡是否可以被特殊召唤。
function c2414168.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动判定阶段（chk==0），确认我方主要怪兽区域存在可用的空格，作为特殊召唤的前置条件。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 向系统登记本次连锁将进行特殊召唤这张卡的操作，数量为1，供后续时点检测与效果发动判定使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①处理时：若这张卡仍与效果关联，则将其以表侧表示特殊召唤到我的场上；成功召唤后，给它附加攻击力上升本次所受战斗伤害数值的永续效果，最后完成特殊召唤处理。
function c2414168.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判定这张卡在效果处理后仍与效果关联，并尝试以表侧表示进行特殊召唤步骤；只有该步骤成功时才继续执行后续的攻击力提升效果。
	if c:IsRelateToEffect(e) and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的这张卡的攻击力上升受到的伤害的数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ev)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
	-- 完成特殊召唤处理，将此前通过SpecialSummonStep累积的所有特殊召唤正式生效。
	Duel.SpecialSummonComplete()
end
-- 效果②的发动条件判定：获取当前攻击怪兽及其战斗对象，将战斗对象存储为效果标签；要求攻击者为对方怪兽，战斗对象存在且是我方守备表示怪兽，并且不是这张卡自身。
function c2414168.defcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前伤害计算步骤中正在进行攻击的怪兽。
	local a=Duel.GetAttacker()
	local d=a:GetBattleTarget()
	e:SetLabelObject(d)
	return a:IsControler(1-tp) and d and d:IsDefensePos() and d:IsControler(tp) and d~=e:GetHandler()
end
-- 效果②处理时：若被保护怪兽仍与本次战斗关联且表侧表示，且这张卡也仍与效果关联并表侧表示，则将被保护怪兽的守备力改为这张卡的当前守备力，并赋予其不会被那次战斗破坏的效果，这些效果持续到伤害步骤结束。
function c2414168.defop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	if tc:IsRelateToBattle() and tc:IsFaceup() and c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 那只自己怪兽只在那次伤害计算时变成和这张卡相同守备力
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e1:SetValue(c:GetDefense())
		e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
		tc:RegisterEffect(e1)
		-- 不会被那次战斗破坏
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e2:SetValue(1)
		e2:SetReset(RESET_PHASE+PHASE_DAMAGE)
		tc:RegisterEffect(e2)
	end
end
