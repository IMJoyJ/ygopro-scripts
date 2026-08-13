--炎征竜－バーナー
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：把1只龙族或炎属性的怪兽和这张卡从手卡丢弃才能发动。从卡组把1只「焰征龙-爆龙」特殊召唤。这个效果特殊召唤的怪兽在这个回合不能攻击。
function c53797637.initial_effect(c)
	-- 将卡号53804307（焰征龙-爆龙）登记到本卡的记述卡名列表中，用于与该卡名相关的检索/判断。
	aux.AddCodeList(c,53804307)
	-- 这个卡名的效果1回合只能使用1次。①：把1只龙族或炎属性的怪兽和这张卡从手卡丢弃才能发动。从卡组把1只「焰征龙-爆龙」特殊召唤。这个效果特殊召唤的怪兽在这个回合不能攻击。
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
-- 定义代价筛选函数：选择手卡中1只龙族或炎属性且可以被丢弃的怪兽作为发动代价。
function c53797637.costfilter(c)
	return (c:IsRace(RACE_DRAGON) or c:IsAttribute(ATTRIBUTE_FIRE)) and c:IsDiscardable()
end
-- 代价检测阶段：确认本卡自身可以丢弃，且手卡中存在其他满足条件的龙族/炎属性怪兽可供丢弃。
function c53797637.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable()
		-- 检查手卡中是否存在至少1张除本卡以外、满足代价筛选条件的怪兽。
		and Duel.IsExistingMatchingCard(c53797637.costfilter,tp,LOCATION_HAND,0,1,c) end
	-- 向玩家显示“请选择要丢弃的手牌”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 让玩家从手卡选择1张满足代价筛选条件且不是本卡的怪兽，作为丢弃代价。
	local g=Duel.SelectMatchingCard(tp,c53797637.costfilter,tp,LOCATION_HAND,0,1,1,c)
	g:AddCard(c)
	-- 将选中的怪兽和本卡以代价丢弃的形式送去墓地。
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
-- 定义特殊召唤筛选函数：卡组中卡号为53804307（焰征龙-爆龙）且能够被特殊召唤的卡。
function c53797637.spfilter(c,e,tp)
	return c:IsCode(53804307) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动条件检测：我方主要怪兽区有空位，且卡组中存在可特殊召唤的「焰征龙-爆龙」。
function c53797637.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测我方主要怪兽区是否有可用空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检测卡组中是否存在1只符合特殊召唤条件的「焰征龙-爆龙」。
		and Duel.IsExistingMatchingCard(c53797637.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：声明本连锁涉及从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组将1只「焰征龙-爆龙」特殊召唤，若召唤成功则给它附加本回合不能攻击的效果。
function c53797637.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认主要怪兽区仍有空位，若无空位则直接终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 从卡组获取第一张满足特殊召唤筛选条件的「焰征龙-爆龙」。
	local tc=Duel.GetFirstMatchingCard(c53797637.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	-- 若成功取得该卡并执行特殊召唤步骤成功，则进入后续处理。
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽在这个回合不能攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
	-- 完成特殊召唤步骤，将此前步骤中特殊召唤的怪兽正式特殊召唤到场上。
	Duel.SpecialSummonComplete()
end
