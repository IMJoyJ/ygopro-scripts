--マナドゥム・ミーク
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次。
-- ①：自己场上有「维萨斯-斯塔弗罗斯特」或者攻击力1500/守备力2100的怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：这张卡被战斗·效果破坏的场合才能发动。从卡组把1只「末那愚子族·小温顺」特殊召唤。那之后，可以让这个效果特殊召唤的怪兽的等级上升2星。
local s,id,o=GetID()
-- 初始化效果注册：登记关联卡名，注册①的规则特殊召唤效果和②的被破坏时诱发效果。
function s.initial_effect(c)
	-- 将卡名『维萨斯-斯塔弗罗斯特』登记到这张卡上，用于关联卡名检索/判定。
	aux.AddCodeList(c,56099748)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：自己场上有「维萨斯-斯塔弗罗斯特」或者攻击力1500/守备力2100的怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.sprcon)
	c:RegisterEffect(e1)
	-- ②：这张卡被战斗·效果破坏的场合才能发动。从卡组把1只「末那愚子族·小温顺」特殊召唤。那之后，可以让这个效果特殊召唤的怪兽的等级上升2星。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 判定条件：怪兽为表侧表示，且满足『卡名是维萨斯-斯塔弗罗斯特』或『攻击力1500且守备力2100的怪兽』之一。
function s.filter(c)
	local b1=c:IsCode(56099748)
	local b2=c:IsAttack(1500) and c:IsDefense(2100) and c:IsType(TYPE_MONSTER)
	return c:IsFaceup() and (b1 or b2)
end
-- ①的规则特殊召唤的发动条件：自己场上存在满足s.filter的怪兽，且自己的主要怪兽区有空位（当c不存在时用于规则效果判定返回true）。
function s.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判定自己的主要怪兽区是否有空位。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判定自己场上是否存在至少1只满足s.filter条件的表侧表示怪兽。
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- ②的发动条件：这张卡被战斗或效果破坏（检查破坏原因包含战斗破坏或效果破坏）。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
-- ②特殊召唤的对象筛选：必须是从卡组选出的同名卡『末那愚子族·小温顺』，且满足当前效果的特殊召唤条件。
function s.spfilter(c,e,tp)
	return c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②的发动目标判定：自己主要怪兽区有空位且卡组存在符合条件的同名怪兽，满足才能发动。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定自己主要怪兽区是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判定卡组是否存在1张可特殊召唤的同名卡。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置本次连锁的操作信息：效果包含特殊召唤，预定从卡组特殊召唤1只怪兽到tp的场上。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②的效果处理：先确认怪兽区有空位，然后从卡组选择1只同名怪兽表侧攻击表示特殊召唤；若特殊召唤成功且该怪兽等级不低于1，再询问玩家是否使其等级上升2星，选择是则赋予其等级+2的效果。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时若场上没有可用的主要怪兽区，则不进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示『请选择要特殊召唤的卡』的提示，让玩家选择怪兽卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组筛选符合条件的1张同名怪兽卡作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 确认特殊召唤成功且该怪兽的当前等级不低于1，作为是否询问等级提升的前提。
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 and tc:IsLevelAbove(1)
		-- 询问玩家是否让这只特殊召唤的怪兽等级上升2星。
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否上升等级？"
		-- 中断当前效果处理，使后续的等级上升效果作为另一段处理，避免占用同一时点。
		Duel.BreakEffect()
		-- 那之后，可以让这个效果特殊召唤的怪兽的等级上升2星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
