--契約を結びし竜の戦士
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：丢弃1张手卡才能发动。除「缔结契约的龙之战士」外的1只4星以下的龙族怪兽从手卡·卡组特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
local s,id,o=GetID()
-- 初始化效果函数：创建并注册效果e1。e1为起动效果（EFFECT_TYPE_IGNITION），只能在主要怪兽区发动；效果分类为特殊召唤；设置描述、同名卡一回合1次的次数限制；并指定代价函数spcost、发动目标条件sptg、效果处理spop。
function s.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：丢弃1张手卡才能发动。除「缔结契约的龙之战士」外的1只4星以下的龙族怪兽从手卡·卡组特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
-- 代价筛选函数：判断一张手卡当前是否可以被丢弃（可作丢弃代价）。
function s.costfilter(c)
	return c:IsDiscardable()
end
-- 代价处理：先检查手卡是否有至少1张可丢弃的卡；若有则丢弃1张手卡作为发动代价（丢弃理由为REASON_COST+REASON_DISCARD）。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价可支付判定：返回true的条件是手卡中存在至少1张满足costfilter的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 实际执行代价：让玩家从手卡选择并丢弃1张满足costfilter的卡。
	Duel.DiscardHand(tp,s.costfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 特殊召唤对象筛选：不是「缔结契约的龙之战士」自身、等级4以下、龙族、且可以通过效果特殊召唤的怪兽。
function s.spfilter(c,e,tp)
	return not c:IsCode(id) and c:IsLevelBelow(4) and c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动目标设置：若主要怪兽区有空位且手卡·卡组存在符合条件的龙族怪兽，则允许发动并返回true。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查主要怪兽区是否还有空格，无空格则无法开展特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡·卡组中是否存在至少1只符合spfilter筛选条件的龙族怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：登记本次效果将进行1次特殊召唤，位置为手卡·卡组，以便系统识别。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果处理：确认有空位后，从手卡·卡组选择1只符合条件的龙族怪兽表侧表示特殊召唤；成功后给该怪兽附加“效果无效化”的处理；最后完成特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若主要怪兽区已无空位，则无法特殊召唤，直接终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出选卡提示：要求玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·卡组选出1只满足spfilter的怪兽。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 对选中的怪兽进行特殊召唤步骤；若步骤成功，则继续为其赋予效果无效化状态。
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 对应“这个效果特殊召唤的怪兽的效果无效化。”：赋予该怪兽EFFECT_DISABLE效果无效状态；该无效效果本身不会被无效，并在怪兽离场等标准重置时解除。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 对应“这个效果特殊召唤的怪兽的效果无效化。”：赋予该怪兽EFFECT_DISABLE_EFFECT，使其效果也无效化；该无效效果不会被无效，并在变里侧等情况下重置。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
	-- 完成特殊召唤的全部分解步骤，触发特殊召唤成功后的时点。
	Duel.SpecialSummonComplete()
end
