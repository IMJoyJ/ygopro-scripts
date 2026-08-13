--獣神機王バルバロスUr
-- 效果：
-- ①：这张卡可以从自己的手卡·场上·墓地把兽战士族怪兽和机械族怪兽各1只除外从手卡特殊召唤。
-- ②：这张卡的战斗让对方受到的战斗伤害变成0。
function c19028307.initial_effect(c)
	-- ①：这张卡可以从自己的手卡·场上·墓地把兽战士族怪兽和机械族怪兽各1只除外从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c19028307.spcon)
	e1:SetTarget(c19028307.sptg)
	e1:SetOperation(c19028307.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡的战斗让对方受到的战斗伤害变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_NO_BATTLE_DAMAGE)
	c:RegisterEffect(e2)
end
-- 素材过滤：判定怪兽是否可作为召唤素材，要求能被除外、种族为兽战士族或机械族，且在场上时必须是表侧表示。
function c19028307.spcostfilter(c)
	return c:IsAbleToRemoveAsCost() and c:IsRace(RACE_BEASTWARRIOR+RACE_MACHINE) and (not c:IsLocation(LOCATION_MZONE) or c:IsFaceup())
end
-- 素材组合检查：确认除去这些素材后我方仍有可用怪兽区，且所选两张素材的种类刚好分别为兽战士族和机械族。
function c19028307.spcheck(sg,tp)
	-- 计算移除素材后的可用怪兽区域数大于0，并利用aux.gfcheck验证两张素材分别满足兽战士族和机械族条件。
	return Duel.GetMZoneCount(tp,sg,tp)>0 and aux.gfcheck(sg,Card.IsRace,RACE_BEASTWARRIOR,RACE_MACHINE)
end
-- 规则召唤条件：当c为nil时直接放行，否则从手卡·场上·墓地中检索是否存在满足条件的2张素材组合。
function c19028307.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 筛选出当前玩家手卡·场上·墓地中可作为除外素材的怪兽（不包括此卡自身）。
	local g=Duel.GetMatchingGroup(c19028307.spcostfilter,tp,LOCATION_MZONE+LOCATION_HAND+LOCATION_GRAVE,0,c)
	return g:CheckSubGroup(c19028307.spcheck,2,2,tp)
end
-- 目标处理：让玩家选择2张素材，校验后保留选中组并存入效果LabelObject，作为后续除外操作的数据。
function c19028307.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取当前玩家可选的素材候选组，范围是手卡·场上·墓地，且排除此卡。
	local g=Duel.GetMatchingGroup(c19028307.spcostfilter,tp,LOCATION_MZONE+LOCATION_HAND+LOCATION_GRAVE,0,c)
	-- 弹出选择提示，要求玩家选择要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:SelectSubGroup(tp,c19028307.spcheck,true,2,2,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤处理：取出之前选定的素材组，将其除外并作为这次规则特殊召唤的手续。
function c19028307.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选定的素材以表侧表示除外，作为这次特殊召唤的COST/手续。
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
