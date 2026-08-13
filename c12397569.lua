--神域 バ＝ティスティナ
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己主要阶段才能发动。从卡组把1只「提斯蒂娜」怪兽送去墓地。对方场上有表侧表示卡3张以上存在的场合，可以再从手卡·卡组把1只「结晶神 提斯蒂娜」特殊召唤。
-- ②：场地区域的这张卡被对方的效果破坏的场合才能发动。从自己的卡组·墓地把1只「提斯蒂娜」怪兽特殊召唤。
local s,id,o=GetID()
-- 创建并注册本卡的三个效果：e1为场地魔法卡的发动效果，e2为①的起动效果，e3为②的被破坏时的诱发效果。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 这个卡名的①的效果1回合只能使用1次。①：自己主要阶段才能发动。从卡组把1只「提斯蒂娜」怪兽送去墓地。对方场上有表侧表示卡3张以上存在的场合，可以再从手卡·卡组把1只「结晶神 提斯蒂娜」特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
	-- ②：场地区域的这张卡被对方的效果破坏的场合才能发动。从自己的卡组·墓地把1只「提斯蒂娜」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 定义过滤条件：从卡组中选出属于「提斯蒂娜」字段的怪兽卡，且该卡可以被送去墓地。
function s.filter(c)
	return c:IsSetCard(0x1a4) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- ①效果的发动条件判断与操作信息设定：检查卡组中是否存在可送去墓地的「提斯蒂娜」怪兽，若有则登记本次效果将把卡组1只怪兽送去墓地。
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时（chk==0）检查卡组中是否存在至少1只满足s.filter的「提斯蒂娜」怪兽，作为效果能否发动的条件。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记效果处理时会将1张卡从卡组送去墓地，用于连锁判定（如星尘龙、王家长眠之谷等）。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 定义追加特殊召唤的过滤条件：选择手卡·卡组中的「结晶神 提斯蒂娜」（卡号86999951），并确认其能够被特殊召唤。
function s.sfilter(c,e,tp)
	return c:IsCode(86999951) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的处理：从卡组选1只「提斯蒂娜」怪兽送去墓地；若送墓成功、对方场上有3张以上表侧表示卡且自己场上有空位，则继续准备追加特殊召唤（后续代码处理）。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示选择提示，要求选择1张要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从自己卡组选择1张满足s.filter的「提斯蒂娜」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选择的卡送去墓地，并确认实际送墓成功且该卡确实位于墓地。
	if not (Duel.SendtoGrave(g,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_GRAVE)
		-- 判断对方场上是否存在3张以上表侧表示的卡，即效果原文中“对方场上有表侧表示卡3张以上存在的场合”。
		and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_ONFIELD,3,nil)
		-- 检查自己场上主要怪兽区是否有空位，用于后续可能进行的追加特殊召唤；若条件不足则不进行追加。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0) then return end
	-- 从手卡和卡组中检索所有可特殊召唤的「结晶神 提斯蒂娜」，生成候选集合（不取对象，处理时选择）。
	local tg=Duel.GetMatchingGroup(s.sfilter,tp,LOCATION_DECK+LOCATION_HAND,0,nil,e,tp)
	-- 当存在可特殊召唤的「结晶神 提斯蒂娜」且玩家选择“是”时，才进行追加特殊召唤。
	if #tg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把1只「结晶神 提斯蒂娜」特殊召唤？"
		-- 向玩家显示选择提示，要求选择1张要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=tg:Select(tp,1,1,nil)
		-- 中断当前效果处理，使之后的特殊召唤与之前的送墓处理分开时点，避免错过时点。
		Duel.BreakEffect()
		-- 将选中的「结晶神 提斯蒂娜」以表侧表示特殊召唤到自己的主要怪兽区。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的发动条件：这张卡被破坏前由自己控制、位于场地区域，且是被对方的效果破坏。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_FZONE) and rp==1-tp and c:IsReason(REASON_EFFECT)
end
-- 定义从卡组·墓地特殊召唤的过滤条件：选择属于「提斯蒂娜」字段的怪兽，并确认其满足特殊召唤条件。
function s.rfilter(c,e,tp)
	return c:IsSetCard(0x1a4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动条件检查：自己主要怪兽区有空位，且卡组·墓地中存在可特殊召唤的「提斯蒂娜」怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时先确认自己场上主要怪兽区是否有空余位置。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 再确认卡组·墓地是否存在至少1只可特殊召唤的「提斯蒂娜」怪兽。
		and Duel.IsExistingMatchingCard(s.rfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 登记本次效果将特殊召唤1只怪兽，可检索的范围为卡组和墓地。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- ②效果的实际处理：再次确认有怪兽区空位，提示玩家选择，并从卡组·墓地特殊召唤1只「提斯蒂娜」怪兽（通过王家长眠之谷过滤）。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理开始时若自己的主要怪兽区没有空位，则直接结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示选择提示，要求选择1张要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己卡组·墓地选择1只符合条件的「提斯蒂娜」怪兽；使用NecroValleyFilter以排除受王家长眠之谷影响的卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.rfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 将选中的「提斯蒂娜」怪兽以表侧表示特殊召唤到自己的主要怪兽区。
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
