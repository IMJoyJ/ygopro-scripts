--子狸ぽんぽこ
-- 效果：
-- 这张卡召唤成功时，可以从卡组把「子狸 嘭嘭」以外的1只兽族·2星怪兽里侧守备表示特殊召唤。这个效果发动的回合，自己不能把兽族以外的怪兽特殊召唤。
function c92729410.initial_effect(c)
	-- 这张卡召唤成功时，可以从卡组把「子狸 嘭嘭」以外的1只兽族·2星怪兽里侧守备表示特殊召唤。这个效果发动的回合，自己不能把兽族以外的怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(92729410,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCost(c92729410.spcost)
	e2:SetTarget(c92729410.sptg)
	e2:SetOperation(c92729410.spop)
	c:RegisterEffect(e2)
	-- 注册一个自定义活动计数器，用于检测本回合是否特殊召唤过兽族以外的怪兽
	Duel.AddCustomActivityCounter(92729410,ACTIVITY_SPSUMMON,c92729410.counterfilter)
end
-- 计数器过滤函数，用于筛选兽族怪兽（非兽族怪兽的特殊召唤会使计数器增加）
function c92729410.counterfilter(c)
	return c:IsRace(RACE_BEAST)
end
-- 效果发动的Cost函数，检查并添加本回合不能特殊召唤兽族以外怪兽的限制
function c92729410.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：本回合自己不能有特殊召唤过兽族以外怪兽的记录
	if chk==0 then return Duel.GetCustomActivityCount(92729410,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这个效果发动的回合，自己不能把兽族以外的怪兽特殊召唤。这张卡召唤成功时，可以从卡组把「子狸 嘭嘭」以外的1只兽族·2星怪兽里侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c92729410.splimit)
	-- 给玩家注册不能特殊召唤兽族以外怪兽的限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制特殊召唤的过滤函数，限制非兽族怪兽的特殊召唤
function c92729410.splimit(e,c)
	return c:GetRace()~=RACE_BEAST
end
-- 过滤卡组中「子狸 嘭嘭」以外的2星兽族怪兽，且该怪兽能以里侧守备表示特殊召唤
function c92729410.filter(c,e,tp)
	return not c:IsCode(92729410) and c:IsLevel(2) and c:IsRace(RACE_BEAST)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 效果发动的Target（目标选择）函数，检查怪兽区域空格和卡组中是否存在符合条件的怪兽
function c92729410.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己卡组是否存在至少1张满足过滤条件的怪兽
		and Duel.IsExistingMatchingCard(c92729410.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置当前处理的连锁操作信息，表示该效果包含从卡组特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理的Operation（操作）函数，执行从卡组选择怪兽并里侧守备表示特殊召唤的处理
function c92729410.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域空格，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1张满足过滤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c92729410.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以里侧守备表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 让对方玩家确认特殊召唤的里侧表示怪兽
		Duel.ConfirmCards(1-tp,g)
	end
end
