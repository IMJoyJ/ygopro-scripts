--炎征竜－バーナー
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：把1只龙族或炎属性的怪兽和这张卡从手卡丢弃才能发动。从卡组把1只「焰征龙-爆龙」特殊召唤。这个效果特殊召唤的怪兽在这个回合不能攻击。
function c53797637.initial_effect(c)
	-- 注册此卡具有「焰征龙-爆龙」的卡片代码，用于效果判定
	aux.AddCodeList(c,53804307)
	-- ①：把1只龙族或炎属性的怪兽和这张卡从手卡丢弃才能发动。从卡组把1只「焰征龙-爆龙」特殊召唤。这个效果特殊召唤的怪兽在这个回合不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(53797637,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,53797637)
	e1:SetCost(c53797637.spcost)
	e1:SetTarget(c53797637.sptg)
	e1:SetOperation(c53797637.spop)
	c:RegisterEffect(e1)
end
-- 定义丢弃费用的过滤函数，检查手牌中是否包含龙族或炎属性且可丢弃的怪兽
function c53797637.costfilter(c)
	return (c:IsRace(RACE_DRAGON) or c:IsAttribute(ATTRIBUTE_FIRE)) and c:IsDiscardable()
end
-- 检查是否满足发动条件：手牌中有可丢弃的此卡和至少一张龙族或炎属性的怪兽
function c53797637.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable()
		-- 检查手牌中是否存在满足条件的龙族或炎属性怪兽
		and Duel.IsExistingMatchingCard(c53797637.costfilter,tp,LOCATION_HAND,0,1,c) end
	-- 提示玩家选择要丢弃的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 选择满足条件的龙族或炎属性怪兽作为丢弃对象
	local g=Duel.SelectMatchingCard(tp,c53797637.costfilter,tp,LOCATION_HAND,0,1,1,c)
	g:AddCard(c)
	-- 将选择的卡片送入墓地作为发动代价
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
-- 定义特殊召唤目标的过滤函数，检查卡组中是否存在「焰征龙-爆龙」且可特殊召唤
function c53797637.spfilter(c,e,tp)
	return c:IsCode(53804307) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 检查是否满足发动条件：卡组中存在「焰征龙-爆龙」且场上存在可用空间
function c53797637.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有可用空间
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在满足条件的「焰征龙-爆龙」
		and Duel.IsExistingMatchingCard(c53797637.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表示将特殊召唤一张怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 执行特殊召唤流程，从卡组检索「焰征龙-爆龙」并特殊召唤
function c53797637.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有可用空间进行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 从卡组检索满足条件的「焰征龙-爆龙」
	local tc=Duel.GetFirstMatchingCard(c53797637.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	-- 尝试特殊召唤检索到的怪兽
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 给特殊召唤的怪兽添加不能攻击的效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
	-- 完成特殊召唤流程，结束本次效果处理
	Duel.SpecialSummonComplete()
end
