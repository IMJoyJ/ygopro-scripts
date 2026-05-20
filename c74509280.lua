--Sin パラレルギア
-- 效果：
-- 把这张卡作为同调素材的场合，其他的同调素材怪兽必须是手卡1只「罪」怪兽。
function c74509280.initial_effect(c)
	c:SetUniqueOnField(1,1,c74509280.uqfilter,LOCATION_MZONE)
	-- 把这张卡作为同调素材的场合，其他的同调素材怪兽必须是手卡1只「罪」怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_TUNER_MATERIAL_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e1:SetTarget(c74509280.synlimit)
	e1:SetTargetRange(1,1)
	e1:SetValue(LOCATION_HAND)
	c:RegisterEffect(e1)
end
-- 过滤场上未被无效且原本卡名为特定「罪」怪兽（具有场上只能存在1只限制）的卡
function c74509280.sfilter(c)
	return c:IsOriginalCodeRule(598988,1710476,9433350,36521459,37115575,55343236) and not c:IsDisabled()
end
-- 场上唯一性过滤函数，用于在「罪 领域」适用且场上存在其他「罪」怪兽时，判定此卡在场上的唯一性
function c74509280.uqfilter(c)
	-- 检查当前玩家是否受到「罪 领域」的效果影响
	if Duel.IsPlayerAffectedByEffect(c:GetControler(),75223115)
		-- 检查场上是否存在至少1张未被无效且原本具有唯一性限制的「罪」怪兽
		and Duel.IsExistingMatchingCard(c74509280.sfilter,c:GetControler(),LOCATION_MZONE,LOCATION_MZONE,1,nil) then
		return c:IsCode(74509280)
	else
		return false
	end
end
-- 同调素材限制的过滤函数，限制其他的同调素材怪兽必须是「罪」怪兽
function c74509280.synlimit(e,c)
	return c:IsSetCard(0x23)
end
