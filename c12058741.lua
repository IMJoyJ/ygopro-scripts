--スネークアイ・ワイトバーチ
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：自己场上有炎属性怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：对方回合，把包含这张卡的自己场上2张表侧表示卡送去墓地才能发动。从手卡·卡组把「蛇眼桦树灵」以外的1只「蛇眼」怪兽特殊召唤。
local s,id,o=GetID()
-- 为「蛇眼桦树灵」注册两个效果：e1为手卡规则特殊召唤效果（自己场上有炎属性怪兽时从手卡特殊召唤，一回合一次），e2为对方回合可发动的诱发即时效果（以包含自身的2张表侧表示卡为cost送去墓地，从手卡·卡组特殊召唤「蛇眼」怪兽，一回合一次）。
function s.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次；①：自己场上有炎属性怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(s.spscon)
	c:RegisterEffect(e1)
	-- ②的效果1回合只能使用1次；②：对方回合，把包含这张卡的自己场上2张表侧表示卡送去墓地才能发动。从手卡·卡组把「蛇眼桦树灵」以外的1只「蛇眼」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetCost(s.cost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断怪兽是否为表侧表示且属性为炎属性。
function s.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_FIRE)
end
-- ①的规则特殊召唤的发动条件：若在效果处理时c为空则可用（处理召唤规则时），并检查自己场上有空余怪兽区且存在表侧表示炎属性怪兽。
function s.spscon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己怪兽区是否有空位（用于规则特殊召唤）。注意：这里使用Duel.GetLocationCount检查可用怪兽区数量大于0。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己场上是否存在表侧表示的炎属性怪兽（至少1只），以决定是否满足①的召唤条件。
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil)
end
-- ②的发动条件：仅在对方回合且当前回合玩家不是自己时满足。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家不是自己（即对方回合），以符合②的发动时机。
	return Duel.GetTurnPlayer()==1-tp
end
-- 费用筛选函数：用于选择作为cost的另一张表侧表示卡，要求该卡为表侧表示且可作为cost送入墓地，并且这张卡与‘蛇眼桦树灵’自身一起离开后自己场上仍有空余怪兽区（为特召做准备）。
function s.cfilter(c,tc,tp)
	-- 判断候选卡是否表侧表示、能否作为cost送墓，且本卡和候选卡作为代价送墓后自己仍有怪兽区空格。
	return c:IsFaceup() and c:IsAbleToGraveAsCost() and Duel.GetMZoneCount(tp,Group.FromCards(c,tc))>0
end
-- ②的cost处理：从自己场上选择包含这张卡在内的2张表侧表示卡（另一张需满足cfilter），全部送去墓地作为发动代价。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动合法性检测：确认本卡自身能作为cost送墓，且场上存在至少1张满足cfilter的卡（即除了自身之外还能选到另一张表侧表示卡）。
	if chk==0 then return c:IsAbleToGraveAsCost() and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,c,c,tp) end
	-- 发送选择提示，提示玩家选择要送去墓地的卡（HINTMSG_TOGRAVE）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足cfilter的1张表侧表示卡，并加上这张卡自身，组成2张卡的费用组g（用+运算符合并自身）。选择时排除了本卡作为候选，但最终把本卡加入。
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_ONFIELD,0,1,1,c,c,tp)+c
	-- 将选中的2张卡作为cost送去墓地，使用REASON_COST标识此次送入为发动代价。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 检索目标筛选函数：从手卡·卡组选择「蛇眼桦树灵」以外的、卡名含「蛇眼」字段的怪兽，且该怪兽可以被通常特殊召唤（苏生限制满足、召唤条件通过）。
function s.sfilter(c,e,tp)
	return c:IsSetCard(0x19c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(id)
end
-- ②的发动目标条件：检查发动时（cost已支付后）是否有空余怪兽区，且手卡·卡组中存在满足sfilter的怪兽；满足则进入发动处理。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若cost尚未检查（或已检查过），确认自己场上存在空余怪兽区；e:IsCostChecked()用于在cost支付后跳过重复的空位判断。
	if chk==0 then return (e:IsCostChecked() or Duel.GetLocationCount(tp,LOCATION_MZONE)>0)
		-- 确认手卡·卡组中存在至少1只满足sfilter条件的「蛇眼」怪兽，以确保效果处理时有对象。
		and Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置本次连锁的操作信息：效果分类为特殊召唤（CATEGORY_SPECIAL_SUMMON），预计从手卡·卡组特殊召唤1只怪兽，目标位置为手卡·卡组。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- ②的效果处理：若自己怪兽区仍有空位，从手卡·卡组选择1只满足条件的「蛇眼」怪兽（非「蛇眼桦树灵」）正面表示特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理前再次确认怪兽区仍有空位；若无空位则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 发送特殊召唤选择提示（HINTMSG_SPSUMMON），让玩家从手卡·卡组选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·卡组选择1只满足sfilter的「蛇眼」怪兽，用于特殊召唤。这里不取对象，因此ex参数为nil。
	local g=Duel.SelectMatchingCard(tp,s.sfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	-- 将选择的怪兽以表侧表示特殊召唤到自己的怪兽区（不限制召唤条件，不检查苏生限制），完成②的效果。
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
