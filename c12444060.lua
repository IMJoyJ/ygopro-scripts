--アーティファクトの神智
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不能进行战斗阶段。
-- ①：从卡组把1只「古遗物」怪兽特殊召唤。
-- ②：这张卡被对方破坏的场合，以场上1张卡为对象才能发动。那张卡破坏。
function c12444060.initial_effect(c)
	-- ①：从卡组把1只「古遗物」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12444060,0))  --"破坏"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_BATTLE_START+TIMING_END_PHASE)
	e1:SetCountLimit(1,12444060+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c12444060.cost)
	e1:SetTarget(c12444060.target)
	e1:SetOperation(c12444060.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡被对方破坏的场合，以场上1张卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(12444060,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(c12444060.descon)
	e2:SetTarget(c12444060.destg)
	e2:SetOperation(c12444060.desop)
	c:RegisterEffect(e2)
end
-- 检查是否满足发动条件，即本回合未进行过战斗阶段
function c12444060.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若未进行过战斗阶段则返回true
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_BATTLE_PHASE)==0 end
	-- 创建一个场地区域效果，使对手不能进行战斗阶段
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将该效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 定义过滤函数，用于筛选「古遗物」怪兽
function c12444060.filter(c,e,tp)
	return c:IsSetCard(0x97) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义效果的处理目标函数
function c12444060.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的场上空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在满足条件的「古遗物」怪兽
		and Duel.IsExistingMatchingCard(c12444060.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表示将特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK)
end
-- 定义效果的处理函数
function c12444060.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 从卡组中选择一只满足条件的「古遗物」怪兽
	local g=Duel.SelectMatchingCard(tp,c12444060.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义破坏时的触发条件函数
function c12444060.descon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and e:GetHandler():IsPreviousControler(tp)
end
-- 定义破坏效果的目标选择函数
function c12444060.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 检查场上是否存在可破坏的卡片
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	-- 选择场上的一张卡作为破坏对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁操作信息，表示将破坏1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 定义破坏效果的处理函数
function c12444060.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
