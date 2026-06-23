--マナドゥム・ヒアレス
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次。
-- ①：自己场上有「维萨斯-斯塔弗罗斯特」或者攻击力1500/守备力2100的怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：这张卡被战斗·效果破坏的场合才能发动。从卡组把1只「末那愚子族·小无畏」特殊召唤。这个效果发动的回合的战斗阶段中，自己场上的同调怪兽的攻击力上升500。
local s,id,o=GetID()
-- 初始化效果函数，注册两个效果：①特殊召唤条件和②被破坏时的效果
function s.initial_effect(c)
	-- 记录该卡与「维萨斯-斯塔弗罗斯特」的卡号关联
	aux.AddCodeList(c,56099748)
	-- 设置效果①：自己场上有「维萨斯-斯塔弗罗斯特」或者攻击力1500/守备力2100的怪兽存在的场合，这张卡可以从手卡特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.sprcon)
	c:RegisterEffect(e1)
	-- 设置效果②：这张卡被战斗·效果破坏的场合才能发动。从卡组把1只「末那愚子族·小无畏」特殊召唤。这个效果发动的回合的战斗阶段中，自己场上的同调怪兽的攻击力上升500
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 定义过滤函数，用于判断场上是否存在符合条件的怪兽（为「维萨斯-斯塔弗罗斯特」或攻击力1500/守备力2100的怪兽）
function s.filter(c)
	local b1=c:IsCode(56099748)
	local b2=c:IsAttack(1500) and c:IsDefense(2100) and c:IsType(TYPE_MONSTER)
	return c:IsFaceup() and (b1 or b2)
end
-- 定义特殊召唤条件函数，检查是否满足特殊召唤条件
function s.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查玩家场上是否有足够的怪兽区域
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家场上是否存在符合条件的怪兽
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 定义被破坏时的发动条件，仅在因效果或战斗破坏时才能发动
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
-- 定义从卡组特殊召唤的过滤函数，用于选择「末那愚子族·小无畏」
function s.spfilter(c,e,tp)
	return c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义特殊召唤的处理目标函数，检查是否满足发动条件
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家卡组中是否存在符合条件的「末那愚子族·小无畏」
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息，表示将从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 定义效果②的处理函数，包括设置攻击力上升效果并特殊召唤怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 设置攻击力上升效果，使战斗阶段中自己场上的同调怪兽攻击力上升500
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetCondition(s.atkcon)
	e1:SetTarget(s.atktg)
	e1:SetValue(500)
	-- 将攻击力上升效果注册给玩家
	Duel.RegisterEffect(e1,tp)
	-- 检查玩家场上是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择卡组中符合条件的「末那愚子族·小无畏」
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义攻击力上升效果的触发条件，仅在战斗阶段中生效
function s.atkcon(e)
	-- 获取当前阶段
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
-- 定义攻击力上升效果的目标过滤函数，仅对同调怪兽生效
function s.atktg(e,c)
	return c:IsType(TYPE_SYNCHRO) and c:IsFaceup()
end
