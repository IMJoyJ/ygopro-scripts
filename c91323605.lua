--奇異界開
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上的怪兽被对方的攻击·效果破坏的场合才能发动。同名卡不在场地区域存在的1张场地魔法卡从卡组到自己的场地区域表侧表示放置。那之后，从卡组把5只卡名不同的怪兽给对方观看，对方从那之中随机选1只。那1只怪兽在自己场上特殊召唤，剩余回到卡组。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上的怪兽被对方的攻击·效果破坏的场合才能发动。同名卡不在场地区域存在的1张场地魔法卡从卡组到自己的场地区域表侧表示放置。那之后，从卡组把5只卡名不同的怪兽给对方观看，对方从那之中随机选1只。那1只怪兽在自己场上特殊召唤，剩余回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上的怪兽被对方的攻击或效果破坏
function s.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:GetReasonPlayer()==1-tp and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- 检查触发时点是否存在满足被对方破坏条件的自己场上怪兽
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 过滤条件：场上表侧表示存在的指定卡名的卡
function s.xfilter(c,code)
	return c:IsFaceup() and c:IsCode(code)
end
-- 过滤条件：卡组中可以放置到场上且同名卡不在自己场地区域存在的场地魔法卡
function s.filter(c,tp)
	return c:IsType(TYPE_FIELD) and not c:IsForbidden() and c:CheckUniqueOnField(tp)
		-- 检查自己场地区域是否存在同名卡
		and not Duel.IsExistingMatchingCard(s.xfilter,tp,LOCATION_FZONE,0,1,nil,c:GetCode())
end
-- 过滤条件：卡组中可以特殊召唤的怪兽
function s.sfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的合法性检查与特殊召唤操作信息设置
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取卡组中所有可以特殊召唤的怪兽
	local g=Duel.GetMatchingGroup(s.sfilter,tp,LOCATION_DECK,0,nil,e,tp)
	-- 检查卡组中是否存在可放置的场地魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,tp)
		-- 检查自己场上是否有空怪兽格，且卡组中可特召的怪兽卡名种类是否在5种以上
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and g:GetClassCount(Card.GetCode)>4 end
	-- 设置特殊召唤的操作信息（从卡组特殊召唤1只怪兽）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理的核心逻辑：放置场地魔法，然后展示5张卡名不同的怪兽并由对方随机选1只特殊召唤
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要放置到场上的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从卡组选择1张满足条件的场地魔法卡
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if not tc then return end
	-- 获取自己场地区域当前存在的卡
	local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
	if fc then
		-- 因规则将原本存在的场地卡送去墓地
		Duel.SendtoGrave(fc,REASON_RULE)
		-- 中断当前效果处理，使后续动作不与送墓同时处理
		Duel.BreakEffect()
	end
	-- 将选择的场地魔法卡在自己的场地区域表侧表示放置
	Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
	-- 重新获取卡组中所有可以特殊召唤的怪兽
	local g=Duel.GetMatchingGroup(s.sfilter,tp,LOCATION_DECK,0,nil,e,tp)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从符合条件的怪兽中选择5张卡名不同的怪兽
	local mg=g:SelectSubGroup(tp,aux.dncheck,false,5,5)
	if mg then
		-- 中断当前效果处理，使后续动作不与放置场地魔法同时处理
		Duel.BreakEffect()
		-- 给对方玩家确认选出的5只怪兽
		Duel.ConfirmCards(1-tp,mg)
		local sg=mg:RandomSelect(1-tp,1)
		-- 给自己确认对方随机选出的那1只怪兽
		Duel.ConfirmCards(tp,sg)
		-- 将对方随机选出的那1只怪兽在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
