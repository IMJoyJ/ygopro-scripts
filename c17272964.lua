--マナドゥム・ヒアレス
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次。
-- ①：自己场上有「维萨斯-斯塔弗罗斯特」或者攻击力1500/守备力2100的怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：这张卡被战斗·效果破坏的场合才能发动。从卡组把1只「末那愚子族·小无畏」特殊召唤。这个效果发动的回合的战斗阶段中，自己场上的同调怪兽的攻击力上升500。
local s,id,o=GetID()
-- 注册卡片的全部效果：①作为手卡特殊召唤规则效果（带1回合1次限制），②作为被战斗·效果破坏时从卡组特召同名卡并附加战斗阶段同调怪兽攻击力上升的效果。
function s.initial_effect(c)
	-- 将『维萨斯-斯塔弗罗斯特』（卡号56099748）登记为这张卡上记载的卡名，用于①中“有「维萨斯-斯塔弗罗斯特」”的判定。
	aux.AddCodeList(c,56099748)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：自己场上有「维萨斯-斯塔弗罗斯特」或者攻击力1500/守备力2100的怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.sprcon)
	c:RegisterEffect(e1)
	-- ②：这张卡被战斗·效果破坏的场合才能发动。从卡组把1只「末那愚子族·小无畏」特殊召唤。这个效果发动的回合的战斗阶段中，自己场上的同调怪兽的攻击力上升500。
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
-- 过滤函数：用于判定“场上有满足条件的怪兽”，即场上存在表侧表示的「维萨斯-斯塔弗罗斯特」或攻击力1500且守备力2100的怪兽。
function s.filter(c)
	local b1=c:IsCode(56099748)
	local b2=c:IsAttack(1500) and c:IsDefense(2100) and c:IsType(TYPE_MONSTER)
	return c:IsFaceup() and (b1 or b2)
end
-- ①特殊召唤规则效果的条件：如果调用时无怪兽参数则视为可适用；否则需自己主要怪兽区有空位，且自己场上有符合条件的怪兽。
function s.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己主要怪兽区是否存在可用空格，以确定能否特殊召唤这张卡。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己场上是否至少存在1张满足s.filter条件的表侧表示怪兽（维萨斯或攻1500/防2100的怪兽）。
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- ②的发动条件：这张卡被战斗或效果破坏时才能发动。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
-- ②特召筛选：从卡组寻找与自身同卡号的「末那愚子族·小无畏」，且能够被这次效果特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②的发动目标判定：仅在主要怪兽区有空位且卡组中存在可特殊召唤的同名卡时才可发动。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己主要怪兽区有空位，作为特殊召唤的前提。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认卡组中存在满足spfilter的卡片（同名且可特殊召唤），用于是否满足发动条件。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理信息：本次效果将进行特殊召唤，对象来自卡组的1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：先给己方表侧同调怪兽附加攻击力上升500的永续效果（直到结束阶段），然后从卡组选择1只同名卡特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 从卡组把1只「末那愚子族·小无畏」特殊召唤。这个效果发动的回合的战斗阶段中，自己场上的同调怪兽的攻击力上升500。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetCondition(s.atkcon)
	e1:SetTarget(s.atktg)
	e1:SetValue(500)
	-- 将攻击力上升的效果注册到场上，使满足条件的己方同调怪兽在战斗阶段内攻击力+500。
	Duel.RegisterEffect(e1,tp)
	-- 若主要怪兽区没有空位，则跳过后续的特殊召唤处理（但前面已注册的攻击力上升效果仍然适用）。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向操作玩家显示“请选择要特殊召唤的卡”的提示，要求选择卡组中的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1张满足spfilter的卡（即同名且可特殊召唤的「末那愚子族·小无畏」）。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 攻击力上升效果的条件：当前处于战斗阶段（从战斗阶段开始到战斗阶段结束之间）。
function s.atkcon(e)
	-- 获取当前游戏阶段，用于判断是否处于战斗阶段。
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
-- 攻击力上升效果的对象：自己场上的表侧表示的同调怪兽。
function s.atktg(e,c)
	return c:IsType(TYPE_SYNCHRO) and c:IsFaceup()
end
