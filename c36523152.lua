--超重武者ビッグワラ－G
-- 效果：
-- ①：自己墓地没有魔法·陷阱卡存在的场合，这张卡可以从手卡特殊召唤。这个方法特殊召唤成功的回合，自己不是「超重武者」怪兽不能特殊召唤。
-- ②：机械族怪兽上级召唤的场合，这张卡可以作为2只的数量解放。
function c36523152.initial_effect(c)
	-- ①：自己墓地没有魔法·陷阱卡存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c36523152.spcon)
	e1:SetOperation(c36523152.spop)
	c:RegisterEffect(e1)
	-- ②：机械族怪兽上级召唤的场合，这张卡可以作为2只的数量解放。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DOUBLE_TRIBUTE)
	e2:SetValue(c36523152.condition)
	c:RegisterEffect(e2)
end
-- 该函数是EFFECT_SPSUMMON_PROC的条件函数：若c为nil则视为可用于规则特召；否则检查我方主要怪兽区有空格且我方墓地不存在魔法·陷阱卡。
function c36523152.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查我方（tp）主要怪兽区是否还有可用的空格（大于0）。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查我方墓地不存在任何魔法·陷阱卡（没有满足Card.IsType为魔法或陷阱的卡），即无魔法·陷阱卡存在。
		and not Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_SPELL+TYPE_TRAP)
end
-- 特殊召唤成功时，生成一个针对我方玩家的誓约性限制效果：本回合内不能特殊召唤「超重武者」以外的怪兽；效果持续到结束阶段。
function c36523152.spop(e,tp,eg,ep,ev,re,r,rp)
	-- ①：这个方法特殊召唤成功的回合，自己不是「超重武者」怪兽不能特殊召唤。②：机械族怪兽上级召唤的场合，这张卡可以作为2只的数量解放。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c36523152.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将上述“不能特殊召唤非超重武者”的限制效果注册给tp玩家，使其生效。
	Duel.RegisterEffect(e1,tp)
end
-- 限制效果的目标判定：若被特殊召唤的怪兽不是「超重武者」（卡号不属于0x9a字段），则返回true，即禁止该特殊召唤。
function c36523152.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x9a)
end
-- EFFECT_DOUBLE_TRIBUTE的值函数：当c（被上级召唤的怪兽）是机械族时返回true，此时持有者可以作为2只祭品；用于机械族怪兽的上级召唤。
function c36523152.condition(e,c)
	local ec=e:GetHandler()
	return c:IsRace(RACE_MACHINE) and (ec:IsFaceup() or c:GetControler()==ec:GetControler())
end
