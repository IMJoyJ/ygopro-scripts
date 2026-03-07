--超重武者ビッグワラ－G
-- 效果：
-- ①：自己墓地没有魔法·陷阱卡存在的场合，这张卡可以从手卡特殊召唤。这个方法特殊召唤成功的回合，自己不是「超重武者」怪兽不能特殊召唤。
-- ②：机械族怪兽上级召唤的场合，这张卡可以作为2只的数量解放。
function c36523152.initial_effect(c)
	-- 效果原文内容：①：自己墓地没有魔法·陷阱卡存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c36523152.spcon)
	e1:SetOperation(c36523152.spop)
	c:RegisterEffect(e1)
	-- 效果原文内容：②：机械族怪兽上级召唤的场合，这张卡可以作为2只的数量解放。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DOUBLE_TRIBUTE)
	e2:SetValue(c36523152.condition)
	c:RegisterEffect(e2)
end
-- 规则层面操作：检查手卡特殊召唤的条件，包括场上是否有空位以及墓地是否存在魔法或陷阱卡。
function c36523152.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 规则层面操作：检查玩家场上主要怪兽区域是否有空位。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 规则层面操作：检查玩家墓地是否存在魔法或陷阱卡。
		and not Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_SPELL+TYPE_TRAP)
end
-- 规则层面操作：创建并注册一个禁止特殊召唤的效果，使该回合不能特殊召唤非超重武者怪兽。
function c36523152.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果原文内容：这个方法特殊召唤成功的回合，自己不是「超重武者」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c36523152.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 规则层面操作：将效果e1注册给玩家tp，使其生效。
	Duel.RegisterEffect(e1,tp)
end
-- 规则层面操作：设定禁止特殊召唤的目标，即非超重武者怪兽不能特殊召唤。
function c36523152.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x9a)
end
-- 规则层面操作：设定上级召唤时可作为2只祭品的条件，即必须是机械族怪兽。
function c36523152.condition(e,c)
	return c:IsRace(RACE_MACHINE)
end
