--威炎星－ヒエンシャク
-- 效果：
-- 这张卡可以把自己场上表侧表示存在的3张名字带有「炎舞」的魔法·陷阱卡送去墓地，从手卡特殊召唤。这张卡召唤·特殊召唤成功时，可以从卡组选1张名字带有「炎舞」的陷阱卡在自己场上盖放。「威炎星-飞燕灼」的这个效果1回合只能使用1次。此外，只要这张卡在场上表侧表示存在，自己场上的兽战士族怪兽不会成为对方的卡的效果的对象。
function c2521011.initial_effect(c)
	-- 效果原文内容：这张卡可以把自己场上表侧表示存在的3张名字带有「炎舞」的魔法·陷阱卡送去墓地，从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c2521011.spcon)
	e1:SetTarget(c2521011.sptg)
	e1:SetOperation(c2521011.spop)
	c:RegisterEffect(e1)
	-- 效果原文内容：这张卡召唤·特殊召唤成功时，可以从卡组选1张名字带有「炎舞」的陷阱卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(2521011,0))  --"盖放"
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCountLimit(1,2521011)
	e2:SetTarget(c2521011.settg)
	e2:SetOperation(c2521011.setop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- 效果原文内容：此外，只要这张卡在场上表侧表示存在，自己场上的兽战士族怪兽不会成为对方的卡的效果的对象。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	-- 规则层面作用：设置效果目标为场上所有兽战士族怪兽
	e4:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_BEASTWARRIOR))
	-- 规则层面作用：设置效果值为当对方效果适用时，若该效果的发动玩家不是此卡的控制者，则该效果不适用
	e4:SetValue(aux.tgoval)
	c:RegisterEffect(e4)
end
-- 规则层面作用：定义过滤函数，用于筛选场上表侧表示存在的名字带有「炎舞」的魔法·陷阱卡
function c2521011.spfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x7c) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGraveAsCost()
end
-- 规则层面作用：判断是否满足特殊召唤条件，即自己场上是否存在3张名字带有「炎舞」的魔法·陷阱卡
function c2521011.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 规则层面作用：获取自己场上所有名字带有「炎舞」的魔法·陷阱卡
	local g=Duel.GetMatchingGroup(c2521011.spfilter,tp,LOCATION_ONFIELD,0,nil)
	-- 规则层面作用：检查是否满足特殊召唤条件，即自己场上是否存在3张名字带有「炎舞」的魔法·陷阱卡
	return g:CheckSubGroup(aux.mzctcheck,3,3,tp)
end
-- 规则层面作用：设置特殊召唤时的选择目标，即选择3张名字带有「炎舞」的魔法·陷阱卡
function c2521011.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 规则层面作用：获取自己场上所有名字带有「炎舞」的魔法·陷阱卡
	local g=Duel.GetMatchingGroup(c2521011.spfilter,tp,LOCATION_ONFIELD,0,nil)
	-- 规则层面作用：提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 规则层面作用：选择3张名字带有「炎舞」的魔法·陷阱卡并检查是否满足怪兽区空位要求
	local sg=g:SelectSubGroup(tp,aux.mzctcheck,true,3,3,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 规则层面作用：执行特殊召唤操作，将选中的卡送去墓地
function c2521011.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 规则层面作用：将选中的卡以特殊召唤原因送去墓地
	Duel.SendtoGrave(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 规则层面作用：定义过滤函数，用于筛选可以盖放的「炎舞」陷阱卡
function c2521011.filter(c)
	return c:IsSetCard(0x7c) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
-- 规则层面作用：设置盖放效果的检查条件，即自己卡组中是否存在至少1张名字带有「炎舞」的陷阱卡
function c2521011.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：检查自己卡组中是否存在至少1张名字带有「炎舞」的陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c2521011.filter,tp,LOCATION_DECK,0,1,nil) end
end
-- 规则层面作用：执行盖放操作，选择并盖放一张名字带有「炎舞」的陷阱卡
function c2521011.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 规则层面作用：从自己卡组中选择1张名字带有「炎舞」的陷阱卡
	local g=Duel.SelectMatchingCard(tp,c2521011.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 规则层面作用：将选中的陷阱卡盖放在场上
		Duel.SSet(tp,g:GetFirst())
	end
end
