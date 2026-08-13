--クイック・シンクロン
-- 效果：
-- 这张卡可以作为「同调士」调整的代替而成为同调素材。把这张卡作为同调素材的场合，不是以「同调士」调整为素材的同调怪兽的同调召唤不能使用。
-- ①：这张卡可以把手卡1只怪兽送去墓地，从手卡特殊召唤。
function c20932152.initial_effect(c)
	-- ①：这张卡可以把手卡1只怪兽送去墓地，从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c20932152.spcon)
	e1:SetTarget(c20932152.sptg)
	e1:SetOperation(c20932152.spop)
	c:RegisterEffect(e1)
	-- 把这张卡作为同调素材的场合，不是以「同调士」调整为素材的同调怪兽的同调召唤不能使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetValue(c20932152.synlimit)
	c:RegisterEffect(e2)
	-- 这张卡可以作为「同调士」调整的代替而成为同调素材。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(20932152)
	c:RegisterEffect(e3)
end
-- 判定本卡能否作为同调素材：若目标同调怪兽的素材要求中不包含「同调士」字段，则禁止本卡作为其素材。
function c20932152.synlimit(e,c)
	if not c then return false end
	-- 若怪兽c的素材要求中不含「同调士」字段（0x1017），则返回true，即本卡不能作为c的同调素材。
	return not aux.IsMaterialListSetCard(c,0x1017)
end
-- 过滤出可作为COST送去墓地的手卡怪兽：必须是怪兽且满足作为COST送去墓地的条件。
function c20932152.spfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- 特殊召唤规则的条件：自己主要怪兽区有空位，且手卡存在本卡以外满足COST条件的怪兽。
function c20932152.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己主要怪兽区域是否有可用的空格。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡是否存在至少1张除本卡外满足COST条件的怪兽。
		and Duel.IsExistingMatchingCard(c20932152.spfilter,tp,LOCATION_HAND,0,1,c)
end
-- 选择1张手卡怪兽作为COST存入效果标签，选择成功则允许发动特殊召唤；否则不发动。
function c20932152.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取手卡中除本卡外所有可作为COST的怪兽卡组。
	local g=Duel.GetMatchingGroup(c20932152.spfilter,tp,LOCATION_HAND,0,c)
	-- 弹出选择提示，要求玩家选择一张要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤处理阶段：将之前选定的COST怪兽送去墓地，然后从手卡特殊召唤本卡。
function c20932152.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选定的怪兽以特殊召唤相关理由送去墓地。
	Duel.SendtoGrave(g,REASON_SPSUMMON)
end
