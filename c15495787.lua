--超重武者ココロガマ－A
-- 效果：
-- 自己墓地有魔法·陷阱卡存在的场合，这张卡不能召唤·反转召唤。
-- ①：自己墓地没有魔法·陷阱卡存在，自己受到战斗伤害时才能发动。这张卡从手卡特殊召唤。这个效果特殊召唤的这张卡在这个回合不会被战斗·效果破坏。
function c15495787.initial_effect(c)
	-- 对应效果原文：自己墓地有魔法·陷阱卡存在的场合，这张卡不能召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetCondition(c15495787.sumcon)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	c:RegisterEffect(e2)
	-- 对应效果原文：①：自己墓地没有魔法·陷阱卡存在，自己受到战斗伤害时才能发动。这张卡从手卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(15495787,0))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_HAND)
	e3:SetCode(EVENT_BATTLE_DAMAGE)
	e3:SetCondition(c15495787.spcon)
	e3:SetTarget(c15495787.sptg)
	e3:SetOperation(c15495787.spop)
	c:RegisterEffect(e3)
end
-- 过滤函数：判断卡片是否为魔法卡或陷阱卡，用于检查墓地是否存在魔法·陷阱卡。
function c15495787.sfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 召唤限制条件：以这张卡的控制者为视角，检查其墓地是否存在至少1张魔法·陷阱卡，存在时返回真，使召唤/反转召唤被禁止。
function c15495787.sumcon(e)
	-- 实际判定：检查该玩家墓地中是否存在至少1张满足魔法·陷阱卡过滤条件的卡（无除外对象）。
	return Duel.IsExistingMatchingCard(c15495787.sfilter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil)
end
-- 诱发效果条件：自己受到战斗伤害（ep==tp），且自己墓地没有魔法·陷阱卡时才满足发动条件。
function c15495787.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and not c15495787.sumcon(e)
end
-- 效果发动的合法性检查：若墓地存在魔法·陷阱卡则不能发动；发动时确认自己主要怪兽区有空位，且这张卡可以特殊召唤，成功后设置特殊召唤的操作信息。
function c15495787.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若自己墓地仍存在魔法·陷阱卡，则不允许发动或进行效果处理。
	if Duel.IsExistingMatchingCard(c15495787.sfilter,tp,LOCATION_GRAVE,0,1,nil) then return false end
	-- 发动时（chk==0）检查自己主要怪兽区是否有可用空位，确保能够把这张卡特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：预定将这张卡以特殊召唤类别处理，数量为1；目标玩家与位置未知时填0。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：这张卡仍与效果关联时，将它从手卡表侧表示特殊召唤；若特殊召唤成功，给其赋予本回合内不会被战斗·效果破坏的耐性（不可被无效，并在回合结束或离场等标准重置时失效）。
function c15495787.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 执行特殊召唤；返回实际成功数量不等于0，即特殊召唤成功，才继续赋予后续的破坏耐性。
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 对应效果原文：这个效果特殊召唤的这张卡在这个回合不会被战斗·效果破坏。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		c:RegisterEffect(e2)
	end
end
