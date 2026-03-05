--凶導の聖獣
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己的墓地·除外状态的1只怪兽为对象才能发动。把持有那只怪兽的攻击力以上的攻击力的1只额外卡组的怪兽或者卡组的「教导」怪兽送去墓地，作为对象的怪兽特殊召唤。这张卡的发动后，直到下次的自己回合的结束时自己不能从额外卡组把怪兽特殊召唤。
local s,id,o=GetID()
-- 创建效果，设置发动时的提示、分类、类型、时点、属性、发动限制、目标选择函数和效果处理函数
function s.initial_effect(c)
	-- ①：以自己的墓地·除外状态的1只怪兽为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 判断目标怪兽是否满足特殊召唤条件且场上存在满足条件的额外卡组或卡组的「教导」怪兽
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查场上是否存在满足条件的额外卡组或卡组的「教导」怪兽
		and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_EXTRA+LOCATION_DECK,0,1,nil,c:GetAttack())
end
-- 过滤函数，筛选满足条件的额外卡组或卡组的「教导」怪兽
function s.tgfilter(c,atk)
	return (c:IsSetCard(0x145) or c:IsLocation(LOCATION_EXTRA)) and c:IsType(TYPE_MONSTER)
		and c:IsAttackAbove(atk) and c:IsAbleToGrave()
end
-- 设置目标选择函数，判断目标是否为己方墓地或除外区的怪兽且满足特殊召唤条件
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 检查是否满足发动条件，判断己方场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查是否满足发动条件，判断己方墓地或除外区是否存在满足条件的怪兽
			and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽作为特殊召唤对象
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置操作信息，指定将要送去墓地的卡
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_EXTRA+LOCATION_DECK)
	-- 设置操作信息，指定将要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理函数，执行效果的发动处理
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToChain() then
		local atk=tc:GetAttack()
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 选择满足条件的额外卡组或卡组的「教导」怪兽
		local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_EXTRA+LOCATION_DECK,0,1,1,nil,atk)
		local gc=g:GetFirst()
		-- 判断选择的卡是否成功送去墓地且目标怪兽未被王家长眠之谷影响
		if gc and Duel.SendtoGrave(gc,REASON_EFFECT)~=0 and gc:IsLocation(LOCATION_GRAVE) and aux.NecroValleyFilter()(tc) then
			-- 将目标怪兽特殊召唤
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- ①：以自己的墓地·除外状态的1只怪兽为对象才能发动。把持有那只怪兽的攻击力以上的攻击力的1只额外卡组的怪兽或者卡组的「教导」怪兽送去墓地，作为对象的怪兽特殊召唤。这张卡的发动后，直到下次的自己回合的结束时自己不能从额外卡组把怪兽特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,1))  --"「凶导的圣兽」的效果适用中"
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1,0)
		e1:SetTarget(s.splimit)
		-- 判断当前回合玩家是否为效果发动者
		if Duel.GetTurnPlayer()==tp then
			e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
		else
			e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,1)
		end
		-- 注册效果，使己方不能从额外卡组特殊召唤怪兽
		Duel.RegisterEffect(e1,tp)
	end
end
-- 限制效果，禁止从额外卡组特殊召唤怪兽
function s.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA)
end
