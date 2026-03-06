--水征竜－ストリーム
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：把1只龙族或水属性的怪兽和这张卡从手卡丢弃才能发动。从卡组把1只「瀑征龙-潮龙」特殊召唤。这个效果特殊召唤的怪兽在这个回合不能攻击。
function c27415516.initial_effect(c)
	-- 记录该卡牌效果中涉及的「瀑征龙-潮龙」的卡片编号
	aux.AddCodeList(c,26400609)
	-- ①：把1只龙族或水属性的怪兽和这张卡从手卡丢弃才能发动。从卡组把1只「瀑征龙-潮龙」特殊召唤。这个效果特殊召唤的怪兽在这个回合不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27415516,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,27415516)
	e1:SetCost(c27415516.spcost)
	e1:SetTarget(c27415516.sptg)
	e1:SetOperation(c27415516.spop)
	c:RegisterEffect(e1)
end
-- 定义用于判断手牌是否满足丢弃条件的过滤函数，即是否为龙族或水属性且可丢弃
function c27415516.costfilter(c)
	return (c:IsRace(RACE_DRAGON) or c:IsAttribute(ATTRIBUTE_WATER)) and c:IsDiscardable()
end
-- 检查是否满足发动条件：手牌中存在可丢弃的龙族或水属性怪兽，以及自身可丢弃
function c27415516.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable()
		-- 检查是否满足发动条件：手牌中存在可丢弃的龙族或水属性怪兽
		and Duel.IsExistingMatchingCard(c27415516.costfilter,tp,LOCATION_HAND,0,1,c) end
	-- 提示玩家选择要丢弃的手牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 选择满足条件的1张手牌作为丢弃对象
	local g=Duel.SelectMatchingCard(tp,c27415516.costfilter,tp,LOCATION_HAND,0,1,1,c)
	g:AddCard(c)
	-- 将选中的卡牌送入墓地作为发动代价
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
-- 定义用于判断卡组中是否存在可特殊召唤的「瀑征龙-潮龙」的过滤函数
function c27415516.spfilter(c,e,tp)
	return c:IsCode(26400609) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 检查是否满足发动条件：卡组中存在可特殊召唤的「瀑征龙-潮龙」且场上存在空位
function c27415516.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件：场上存在空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否满足发动条件：卡组中存在可特殊召唤的「瀑征龙-潮龙」
		and Duel.IsExistingMatchingCard(c27415516.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表示将要特殊召唤1只「瀑征龙-潮龙」
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 执行特殊召唤效果，若满足条件则将「瀑征龙-潮龙」特殊召唤并设置其不能攻击
function c27415516.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否还有空位，若无则不执行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 从卡组中检索满足条件的「瀑征龙-潮龙」
	local tc=Duel.GetFirstMatchingCard(c27415516.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	-- 尝试特殊召唤检索到的「瀑征龙-潮龙」
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 给特殊召唤的怪兽添加不能攻击的效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
