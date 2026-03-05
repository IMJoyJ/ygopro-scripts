--クイック・シンクロン
-- 效果：
-- 这张卡可以作为「同调士」调整的代替而成为同调素材。把这张卡作为同调素材的场合，不是以「同调士」调整为素材的同调怪兽的同调召唤不能使用。
-- ①：这张卡可以把手卡1只怪兽送去墓地，从手卡特殊召唤。
function c20932152.initial_effect(c)
	-- 效果原文：①：这张卡可以把手卡1只怪兽送去墓地，从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c20932152.spcon)
	e1:SetTarget(c20932152.sptg)
	e1:SetOperation(c20932152.spop)
	c:RegisterEffect(e1)
	-- 效果原文：这张卡可以作为「同调士」调整的代替而成为同调素材。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetValue(c20932152.synlimit)
	c:RegisterEffect(e2)
	-- 效果原文：把这张卡作为同调素材的场合，不是以「同调士」调整为素材的同调怪兽的同调召唤不能使用。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(20932152)
	c:RegisterEffect(e3)
end
-- 规则层面：判断目标怪兽是否为「同调士」字段的卡，若是则不能作为同调素材。
function c20932152.synlimit(e,c)
	if not c then return false end
	-- 规则层面：若目标怪兽不是「同调士」字段的卡，则可以作为同调素材。
	return not aux.IsMaterialListSetCard(c,0x1017)
end
-- 规则层面：过滤手卡中可以作为cost送去墓地的怪兽卡。
function c20932152.spfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- 规则层面：判断是否满足特殊召唤条件，包括场上是否有空位以及手卡是否有符合条件的怪兽。
function c20932152.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 规则层面：检查当前玩家场上是否有空位。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 规则层面：检查当前玩家手卡中是否存在至少1张符合条件的怪兽卡。
		and Duel.IsExistingMatchingCard(c20932152.spfilter,tp,LOCATION_HAND,0,1,c)
end
-- 规则层面：选择一张手卡中的怪兽卡送去墓地，作为特殊召唤的条件。
function c20932152.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 规则层面：获取所有满足条件的手卡怪兽。
	local g=Duel.GetMatchingGroup(c20932152.spfilter,tp,LOCATION_HAND,0,c)
	-- 规则层面：向玩家发送提示信息，提示其选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 规则层面：执行将选中的怪兽卡送去墓地的操作。
function c20932152.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 规则层面：将指定卡牌以特殊召唤为理由送去墓地。
	Duel.SendtoGrave(g,REASON_SPSUMMON)
end
