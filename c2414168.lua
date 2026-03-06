--インタラプト・レジスタンス
-- 效果：
-- ①：自己受到战斗伤害时才能发动。这张卡从手卡特殊召唤。这个效果特殊召唤的这张卡的攻击力上升受到的伤害的数值。
-- ②：1回合1次，这张卡以外的自己的守备表示怪兽被对方怪兽攻击的伤害计算时才能发动。那只自己怪兽只在那次伤害计算时变成和这张卡相同守备力，不会被那次战斗破坏。
function c2414168.initial_effect(c)
	-- 效果原文内容：①：自己受到战斗伤害时才能发动。这张卡从手卡特殊召唤。这个效果特殊召唤的这张卡的攻击力上升受到的伤害的数值。
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
	-- 效果原文内容：②：1回合1次，这张卡以外的自己的守备表示怪兽被对方怪兽攻击的伤害计算时才能发动。那只自己怪兽只在那次伤害计算时变成和这张卡相同守备力，不会被那次战斗破坏。
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
-- 规则层面作用：判断是否为自己的战斗伤害
function c2414168.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end
-- 规则层面作用：判断是否满足特殊召唤条件
function c2414168.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：判断场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 规则层面作用：设置连锁操作信息，表示将要特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 规则层面作用：处理特殊召唤效果的执行流程
function c2414168.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 规则层面作用：判断此卡是否能参与特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		-- 效果原文内容：这个效果特殊召唤的这张卡的攻击力上升受到的伤害的数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ev)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
	-- 规则层面作用：完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
-- 规则层面作用：判断是否满足守备力变更效果的发动条件
function c2414168.defcon(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：获取此次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	local d=a:GetBattleTarget()
	e:SetLabelObject(d)
	return a:IsControler(1-tp) and d and d:IsDefensePos() and d:IsControler(tp) and d~=e:GetHandler()
end
-- 规则层面作用：处理守备力变更和战斗破坏免疫效果的执行流程
function c2414168.defop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	if tc:IsRelateToBattle() and tc:IsFaceup() and c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 效果原文内容：那只自己怪兽只在那次伤害计算时变成和这张卡相同守备力。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e1:SetValue(c:GetDefense())
		e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
		tc:RegisterEffect(e1)
		-- 效果原文内容：不会被那次战斗破坏。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e2:SetValue(1)
		e2:SetReset(RESET_PHASE+PHASE_DAMAGE)
		tc:RegisterEffect(e2)
	end
end
