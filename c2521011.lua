--威炎星－ヒエンシャク
-- 效果：
-- 这张卡可以把自己场上表侧表示存在的3张名字带有「炎舞」的魔法·陷阱卡送去墓地，从手卡特殊召唤。这张卡召唤·特殊召唤成功时，可以从卡组选1张名字带有「炎舞」的陷阱卡在自己场上盖放。「威炎星-飞燕灼」的这个效果1回合只能使用1次。此外，只要这张卡在场上表侧表示存在，自己场上的兽战士族怪兽不会成为对方的卡的效果的对象。
function c2521011.initial_effect(c)
	-- 这张卡可以把自己场上表侧表示存在的3张名字带有「炎舞」的魔法·陷阱卡送去墓地，从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c2521011.spcon)
	e1:SetTarget(c2521011.sptg)
	e1:SetOperation(c2521011.spop)
	c:RegisterEffect(e1)
	-- 这张卡召唤·特殊召唤成功时，可以从卡组选1张名字带有「炎舞」的陷阱卡在自己场上盖放。「威炎星-飞燕灼」的这个效果1回合只能使用1次。
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
	-- 此外，只要这张卡在场上表侧表示存在，自己场上的兽战士族怪兽不会成为对方的卡的效果的对象。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	-- 设置该抗性效果的作用对象为兽战士族怪兽，即只有自己场上符合兽战士族种族的怪兽才会受到此效果保护。
	e4:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_BEASTWARRIOR))
	-- 设置效果的具体判定逻辑，使该抗性效果只针对对方玩家的卡的效果，即对方卡的效果不能以这些兽战士族怪兽为对象。
	e4:SetValue(aux.tgoval)
	c:RegisterEffect(e4)
end
-- 定义特殊召唤素材的筛选条件：表侧表示的名字带有「炎舞」的魔法·陷阱卡，且可以作为COST送去墓地。
function c2521011.spfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x7c) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGraveAsCost()
end
-- 特殊召唤手续的发动条件：检查自己场上是否存在满足条件的「炎舞」卡，且选出3张送墓后自己场上仍有可用的怪兽区空格；c为nil时用于规则询问。
function c2521011.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取自己场上所有满足条件的「炎舞」魔法·陷阱卡。
	local g=Duel.GetMatchingGroup(c2521011.spfilter,tp,LOCATION_ONFIELD,0,nil)
	-- 检查这些卡中是否存在3张的组合，使将它们送去墓地后自己场上仍有可用的怪兽区域空格。
	return g:CheckSubGroup(aux.mzctcheck,3,3,tp)
end
-- 特殊召唤手续的COST选择阶段：提示玩家从候选中选择3张符合条件的「炎舞」卡作为送去墓地的COST，选择成功则保存该组卡并返回true。
function c2521011.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己场上所有可作为特殊召唤COST的「炎舞」魔法·陷阱卡。
	local g=Duel.GetMatchingGroup(c2521011.spfilter,tp,LOCATION_ONFIELD,0,nil)
	-- 弹出选择提示，让玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从候选中选择一组3张卡（且送墓后怪兽区有空位）作为特殊召唤的COST。
	local sg=g:SelectSubGroup(tp,aux.mzctcheck,true,3,3,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤手续的实际执行：将之前选定的3张「炎舞」卡送去墓地，完成特殊召唤的COST。
function c2521011.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的3张「炎舞」卡送去墓地，作为这次特殊召唤的COST。
	Duel.SendtoGrave(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 定义盖放目标的筛选条件：名字带有「炎舞」的陷阱卡，且可以盖放到场上。
function c2521011.filter(c)
	return c:IsSetCard(0x7c) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
-- 效果发动的合法条件判定：只有己方卡组中存在至少1张符合条件的「炎舞」陷阱卡时才能发动。
function c2521011.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时（chk==0）检查卡组中是否存在可盖放的「炎舞」陷阱卡，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c2521011.filter,tp,LOCATION_DECK,0,1,nil) end
end
-- 效果处理：从卡组选择1张符合条件的「炎舞」陷阱卡，盖放在自己场上。
function c2521011.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出“请选择要盖放的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从卡组中选出1张符合条件的「炎舞」陷阱卡。
	local g=Duel.SelectMatchingCard(tp,c2521011.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的陷阱卡盖放在自己场上。
		Duel.SSet(tp,g:GetFirst())
	end
end
