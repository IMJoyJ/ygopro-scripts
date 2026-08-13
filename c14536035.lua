--ダーク・グレファー
-- 效果：
-- ①：这张卡可以从手卡丢弃1只5星以上的暗属性怪兽，从手卡特殊召唤。
-- ②：1回合1次，从手卡丢弃1只暗属性怪兽才能发动。从卡组把1只暗属性怪兽送去墓地。
function c14536035.initial_effect(c)
	-- ①：这张卡可以从手卡丢弃1只5星以上的暗属性怪兽，从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(14536035,0))  --"特殊召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c14536035.spcon)
	e1:SetTarget(c14536035.sptg)
	e1:SetOperation(c14536035.spop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，从手卡丢弃1只暗属性怪兽才能发动。从卡组把1只暗属性怪兽送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(14536035,1))  --"送去墓地"
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c14536035.sgcost)
	e2:SetTarget(c14536035.sgtg)
	e2:SetOperation(c14536035.sgop)
	c:RegisterEffect(e2)
end
-- 筛选满足等级5以上且暗属性的怪兽，作为从手卡丢弃进行特殊召唤的候选。
function c14536035.spfilter(c)
	return c:IsLevelAbove(5) and c:IsAttribute(ATTRIBUTE_DARK)
end
-- 特殊召唤规则的条件：若c为空则允许；否则需要有可用主要怪兽区，且手牌中存在除自身外1只5星以上暗属性怪兽可供丢弃。
function c14536035.spcon(e,c)
	if c==nil then return true end
	-- 判断要特殊召唤的玩家（这张卡的控制者）场上是否存在可用的主要怪兽区域。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
		-- 确认手牌中存在除这张卡自身外至少1只5星以上暗属性怪兽可被丢弃。
		Duel.IsExistingMatchingCard(c14536035.spfilter,c:GetControler(),LOCATION_HAND,0,1,c)
end
-- 选择作为特殊召唤代价从手牌丢弃的怪兽：从手牌中满足条件的5星以上暗属性怪兽中选取1张，并存入LabelObject；未选择则特殊召唤不能进行。
function c14536035.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取手牌中除这张卡自身外所有满足spfilter（5星以上暗属性）的怪兽，构成可选丢弃的候选集合。
	local g=Duel.GetMatchingGroup(c14536035.spfilter,tp,LOCATION_HAND,0,c)
	-- 发送UI提示，要求玩家选择要丢弃的手牌（选择框提示信息）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤手续实际处理：将之前选定的1只手牌怪兽丢弃到墓地，原因标记为丢弃+特殊召唤；随后由规则效果完成特殊召唤。
function c14536035.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 把选中的丢弃对象送去墓地，原因设定为丢弃（REASON_DISCARD）与特殊召唤（REASON_SPSUMMON）的组合。
	Duel.SendtoGrave(g,REASON_DISCARD+REASON_SPSUMMON)
end
-- 判断一张手牌是否为暗属性且可被丢弃，作为②效果发动时丢弃代价的筛选条件。
function c14536035.costfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsDiscardable()
end
-- ②效果的代价处理：在合法性检查时确认手牌中有可丢弃的暗属性怪兽；实际发动时从手牌选择丢弃1张暗属性怪兽，原因标记为代价+丢弃。
function c14536035.sgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价合法性检查：判断手牌中是否存在至少1张满足costfilter（暗属性且可丢弃）的卡片，作为能否发动②效果的前提。
	if chk==0 then return Duel.IsExistingMatchingCard(c14536035.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 实际发动代价：让玩家从手牌选择1张满足costfilter的卡并丢弃，丢弃原因包含COST和DISCARD。
	Duel.DiscardHand(tp,c14536035.costfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤条件：用于②效果的目标，要求是暗属性且可以送去墓地的卡（从卡组选择送去墓地）。
function c14536035.filter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToGrave()
end
-- ②效果的发动目标判定：检查卡组中是否存在1张暗属性且能送去墓地的卡，并将本次操作信息设为“从卡组将1张卡送去墓地”（不取对象，处理时选择）。
function c14536035.sgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动目标的合法性检查：确认卡组中是否存在至少1张满足filter（暗属性且可送往墓地）的卡片。
	if chk==0 then return Duel.IsExistingMatchingCard(c14536035.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本次效果的操作信息：类别为送去墓地（CATEGORY_TOGRAVE），预计处理1张卡，位置为持有者的卡组，用于连锁处理时相关效果的判定。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ②效果的实际处理：提示玩家选择要送去墓地的卡，从卡组选取1张满足filter的卡，若存在则将其送去墓地（原因：效果）。
function c14536035.sgop(e,tp,eg,ep,ev,re,r,rp)
	-- 发送UI提示，要求玩家选择要送去墓地的卡（提示文本“请选择要送去墓地的卡”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1张满足filter（暗属性且可送去墓地）的卡作为本次效果处理的对象。
	local g=Duel.SelectMatchingCard(tp,c14536035.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡送去墓地，原因标记为效果（REASON_EFFECT）。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
