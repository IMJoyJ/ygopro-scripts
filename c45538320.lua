--精霊術の使い魔
-- 效果：
-- 这个卡名在规则上也当作「凭依装着」卡使用。这个卡名的①②③的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1张「凭依」魔法·陷阱卡或「大灵术-「一轮」」加入手卡。
-- ②：宣言种族和属性各1个才能发动。这张卡直到回合结束时变成宣言的种族·属性。
-- ③：这张卡被战斗·效果破坏的场合才能发动。从自己的卡组·墓地把1只守备力1500的魔法师族怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化精灵术的使魔的效果：登记卡名记载的「大灵术-「一轮」」；注册①的召唤/特殊召唤时的检索效果（通常召唤与特殊召唤共享1回合1次）；注册②的起动效果（宣言种族和属性，本回合改变为宣言的种族/属性，1回合1次）；注册③的被战斗/效果破坏时的特殊召唤效果（从卡组·墓地特召守备力1500魔法师族怪兽，1回合1次）。
function s.initial_effect(c)
	-- 将「大灵术-「一轮」」(38057522) 加入本卡的卡名列表，用于记录本卡效果记载的卡名，便于规则上相关判定。
	aux.AddCodeList(c,38057522)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1张「凭依」魔法·陷阱卡或「大灵术-「一轮」」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索效果"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：宣言种族和属性各1个才能发动。这张卡直到回合结束时变成宣言的种族·属性。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"改变种族属性"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.artg)
	e3:SetOperation(s.arop)
	c:RegisterEffect(e3)
	-- ③：这张卡被战斗·效果破坏的场合才能发动。从自己的卡组·墓地把1只守备力1500的魔法师族怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCountLimit(1,id+o*2)
	e4:SetCondition(s.spcon)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
-- 定义检索过滤器：满足以下任一条件且可加入手卡的卡（1）是「凭依」字段(0xc0)的魔法·陷阱卡（2）是「大灵术-「一轮」」(38057522)。
function s.thfilter(c)
	return (c:IsSetCard(0xc0) and c:IsType(TYPE_SPELL+TYPE_TRAP) or c:IsCode(38057522)) and c:IsAbleToHand()
end
-- 效果①的发动条件判定：确认卡组中存在可检索对象；同时登记本次操作信息，声明将进行卡组检索加入手卡。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动判定时（chk==0）检查卡组是否存在至少1张满足检索条件的卡，以此作为效果能否发动的条件。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记操作信息：向系统声明本效果将把发动者卡组的1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的检索处理：让发动者从卡组选择1张符合条件的卡加入手卡，并向对方展示被检索的卡。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示发动者选择要加入手卡的卡（显示“请选择要加入手牌的卡”的选择提示）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从发动者卡组中选出1张满足 thfilter 条件的卡作为检索对象（不取对象，处理时选择）。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将检索到的卡以效果原因加入其持有者的手卡（nil 表示返回持有者手卡）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对手确认，以符合检索引擎的公开要求。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果②的发动条件与宣言处理：要求发动者宣言1个种族和1个属性，根据当前卡片已有的种族/属性限制可选项，并把宣言结果存入效果的标签，供处理阶段使用。
function s.artg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return ((RACE_ALL&~c:GetRace())~=0 or (ATTRIBUTE_ALL&~c:GetAttribute())~=0) end
	local race,att
	-- 提示发动者宣言种族（显示“请选择要宣言的种族”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RACE)  --"请选择要宣言的种族"
	if ATTRIBUTE_ALL&~c:GetAttribute()==0 then
		-- 当没有可选的与当前不同的属性时，种族只能从当前种族以外的种族中选择（避免宣言结果与现状完全相同）。
		race=Duel.AnnounceRace(tp,1,RACE_ALL&~c:GetRace())
	else
		-- 通常情况下，从全部种族中宣言1个种族。
		race=Duel.AnnounceRace(tp,1,RACE_ALL)
	end
	-- 提示发动者宣言属性（显示“请选择要宣言的属性”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
	if RACE_ALL&~c:GetRace()==0 or race==c:GetRace() then
		-- 当宣言的种族与当前种族相同（或没有可选的与当前不同的种族）时，属性只能从当前属性以外的属性中选择，以保证宣言结果与现状不完全相同。
		att=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL&~c:GetAttribute())
	else
		-- 通常情况下，从全部属性中宣言1个属性。
		att=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL)
	end
	e:SetLabel(race,att)
end
-- 效果②的处理：获取宣言的种族和属性，若本卡仍在场上表侧表示，则通过单次效果将本卡的种族和属性分别变更为宣言的种族/属性，直到回合结束时生效。
function s.arop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rac,att=e:GetLabel()
	if c:IsRelateToChain() and c:IsFaceup() then
		if not c:IsAttribute(att) then
			-- 变成宣言的属性。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
			e1:SetValue(att)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
			c:RegisterEffect(e1)
		end
		if not c:IsRace(rac) then
			-- 变成宣言的种族。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_CHANGE_RACE)
			e2:SetValue(rac)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
			c:RegisterEffect(e2)
		end
	end
end
-- 效果③的发动条件：这张卡被战斗或效果破坏时才能发动（通过检查破坏原因包含 REASON_BATTLE 或 REASON_EFFECT 来判断）。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
-- 特殊召唤对象的过滤器：要求是魔法师族、守备力为1500，并且能够被当前效果以表侧表示特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_SPELLCASTER) and c:IsDefense(1500) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
-- 效果③的发动条件判定：检查自己场上是否有空余怪兽区，以及卡组·墓地中是否存在满足特殊召唤条件的魔法师族怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区，用于判断能否进行特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组·墓地中是否存在至少1只满足条件的魔法师族怪兽（魔法师族、守备力1500且可被特殊召唤），作为效果能否发动的条件之一。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 登记操作信息：本效果处理时将从卡组·墓地进行1只怪兽的特殊召唤，供连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果③的处理：确认空位后提示选择，从卡组·墓地中选出1只符合条件的魔法师族怪兽（并排除受王家长眠之谷影响的墓地卡）特殊召唤到自己场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理阶段再次确认自己场上仍有空余怪兽区，若没有则效果处理不适用。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示发动者选择要特殊召唤的怪兽（显示“请选择要特殊召唤的卡”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己的卡组·墓地中选择1只满足 s.spfilter 条件且不受王家长眠之谷影响的怪兽，作为特殊召唤对象（不取对象，处理时选择）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到发动者场上，调用特殊召唤成功处理并返回成功数量。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
