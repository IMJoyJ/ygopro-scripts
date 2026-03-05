--獣神機王バルバロスUr
-- 效果：
-- ①：这张卡可以从自己的手卡·场上·墓地把兽战士族怪兽和机械族怪兽各1只除外从手卡特殊召唤。
-- ②：这张卡的战斗让对方受到的战斗伤害变成0。
function c19028307.initial_effect(c)
	-- 效果原文内容：①：这张卡可以从自己的手卡·场上·墓地把兽战士族怪兽和机械族怪兽各1只除外从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c19028307.spcon)
	e1:SetTarget(c19028307.sptg)
	e1:SetOperation(c19028307.spop)
	c:RegisterEffect(e1)
	-- 效果原文内容：②：这张卡的战斗让对方受到的战斗伤害变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_NO_BATTLE_DAMAGE)
	c:RegisterEffect(e2)
end
-- 检索满足条件的卡片组：检查是否可以作为除外费用、是否属于兽战士族或机械族、是否在场上时为表侧表示。
function c19028307.spcostfilter(c)
	return c:IsAbleToRemoveAsCost() and c:IsRace(RACE_BEASTWARRIOR+RACE_MACHINE) and (not c:IsLocation(LOCATION_MZONE) or c:IsFaceup())
end
-- 检查所选卡片组是否满足特殊召唤条件：是否有足够的怪兽区域、是否包含一个兽战士族和一个机械族怪兽。
function c19028307.spcheck(sg,tp)
	-- 检查所选卡片组是否满足特殊召唤条件：是否有足够的怪兽区域、是否包含一个兽战士族和一个机械族怪兽。
	return Duel.GetMZoneCount(tp,sg,tp)>0 and aux.gfcheck(sg,Card.IsRace,RACE_BEASTWARRIOR,RACE_MACHINE)
end
-- 判断特殊召唤条件是否满足：获取符合条件的卡片组并检查是否存在包含2张符合条件的卡片的子组。
function c19028307.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取满足除外费用条件的卡片组：从场上、手牌、墓地检索符合条件的卡片。
	local g=Duel.GetMatchingGroup(c19028307.spcostfilter,tp,LOCATION_MZONE+LOCATION_HAND+LOCATION_GRAVE,0,c)
	return g:CheckSubGroup(c19028307.spcheck,2,2,tp)
end
-- 设置特殊召唤的目标选择逻辑：获取符合条件的卡片组并提示选择2张符合条件的卡片。
function c19028307.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取满足除外费用条件的卡片组：从场上、手牌、墓地检索符合条件的卡片。
	local g=Duel.GetMatchingGroup(c19028307.spcostfilter,tp,LOCATION_MZONE+LOCATION_HAND+LOCATION_GRAVE,0,c)
	-- 向玩家发送提示信息，提示选择要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:SelectSubGroup(tp,c19028307.spcheck,true,2,2,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 执行特殊召唤的操作：将选定的卡片除外并从手卡特殊召唤。
function c19028307.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将目标卡片以正面表示形式除外，作为特殊召唤的费用。
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
