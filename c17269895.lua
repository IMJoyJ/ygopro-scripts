--覇者の鳴動
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，在对方把10只以上的怪兽特殊召唤的回合，不能对应这张卡的发动让效果发动。
-- ①：让这个回合对方特殊召唤的怪兽数量的以下效果各适用。
-- ●1只以上：自己的墓地·除外状态的1只暗属性同调怪兽特殊召唤。
-- ●3只以上：直到下次的自己回合的结束时为止的期间，自己的怪兽区域的「红莲魔龙」不受对方发动的效果影响。
-- ●5只以上：对方场上的怪兽全部变成里侧守备表示。
local s,id,o=GetID()
-- 注册卡片效果，设置发动条件、目标和处理函数
function s.initial_effect(c)
	-- 记录该卡与红莲魔龙（70902743）的关联
	aux.AddCodeList(c,70902743)
	-- ①：让这个回合对方特殊召唤的怪兽数量的以下效果各适用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	if not s.global_check then
		s.global_check=true
		-- 当对方怪兽特殊召唤成功时，为对方玩家注册一个标识效果，用于记录该回合对方特殊召唤的怪兽数量
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetOperation(s.checkop)
		-- 将全局效果注册到游戏环境
		Duel.RegisterEffect(ge1,0)
	end
end
-- 处理对方怪兽特殊召唤成功事件，为召唤玩家注册一个标识效果
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	while tc do
		-- 为召唤玩家注册一个标识效果，用于记录该回合对方特殊召唤的怪兽数量
		Duel.RegisterFlagEffect(tc:GetSummonPlayer(),id,RESET_PHASE+PHASE_END,0,1)
		tc=eg:GetNext()
	end
end
-- 过滤满足条件的暗属性同调怪兽（可用于特殊召唤）
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤满足条件的可以变为里侧守备表示的怪兽
function s.posfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- 判断是否满足发动条件，包括特殊召唤、改变表示形式等效果
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方在本回合特殊召唤的怪兽数量
	local ct=Duel.GetFlagEffect(1-tp,id)
	-- 判断是否满足特殊召唤1只以上怪兽的条件
	local b1=ct>=1 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否满足特殊召唤1只以上怪兽的条件
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp)
	-- 判断是否满足特殊召唤3只以上怪兽的条件
	local b2=ct>=3 and Duel.GetFlagEffect(tp,id+o)==0
	-- 判断是否满足特殊召唤5只以上怪兽的条件
	local b3=ct>=5 and Duel.IsExistingMatchingCard(s.posfilter,tp,0,LOCATION_MZONE,1,nil)
	if chk==0 then return b1 or b2 or b3 end
	-- 设置连锁操作信息，表示将要特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
	-- 获取对方场上的所有可以变为里侧守备表示的怪兽
	local g=Duel.GetMatchingGroup(s.posfilter,tp,0,LOCATION_MZONE,nil)
	if ct>=5 and g:GetCount()>0 then
		-- 设置连锁操作信息，表示将要改变怪兽表示形式
		Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
	end
	if ct>=10 and e:IsCostChecked() and e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 设置连锁限制，禁止连锁发动效果
		Duel.SetChainLimit(aux.FALSE)
	end
end
-- 处理卡片发动效果，根据对方特殊召唤的怪兽数量执行不同效果
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方在本回合特殊召唤的怪兽数量
	local ct=Duel.GetFlagEffect(1-tp,id)
	local flag=false
	-- 判断是否满足特殊召唤1只以上怪兽的条件
	if ct>=1 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否满足特殊召唤1只以上怪兽的条件
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的1只暗属性同调怪兽
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的怪兽特殊召唤到场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			flag=true
		end
	end
	-- 判断是否满足特殊召唤3只以上怪兽的条件
	if ct>=3 and Duel.GetFlagEffect(tp,id+o)==0 then
		-- 中断当前效果处理，使后续效果视为不同时处理
		if flag then Duel.BreakEffect() end
		flag=true
		-- ●3只以上：直到下次的自己回合的结束时为止的期间，自己的怪兽区域的「红莲魔龙」不受对方发动的效果影响。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,1))  --"「霸者的鸣动」适用中"
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetTargetRange(LOCATION_MZONE,0)
		-- 设置效果目标为红莲魔龙
		e1:SetTarget(aux.TargetBoolFunction(Card.IsCode,70902743))
		e1:SetValue(s.efilter)
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN)
		-- 将效果注册给玩家
		Duel.RegisterEffect(e1,tp)
		-- 为玩家注册一个标识效果，防止重复触发该效果
		Duel.RegisterFlagEffect(tp,id+o,RESET_PHASE+PHASE_END+RESET_SELF_TURN,0,1)
	end
	if ct>=5 then
		-- 中断当前效果处理，使后续效果视为不同时处理
		if flag then Duel.BreakEffect() end
		-- 获取对方场上的所有可以变为里侧守备表示的怪兽
		local g=Duel.GetMatchingGroup(s.posfilter,tp,0,LOCATION_MZONE,nil)
		if g:GetCount()>0 then
			-- 中断当前效果处理，使后续效果视为不同时处理
			Duel.BreakEffect()
			-- 将对方场上的所有怪兽变为里侧守备表示
			Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
		end
	end
end
-- 效果过滤函数，判断是否为对方发动的效果且未被无效化
function s.efilter(e,re)
	return e:GetHandlerPlayer()~=re:GetOwnerPlayer() and re:IsActivated()
end
