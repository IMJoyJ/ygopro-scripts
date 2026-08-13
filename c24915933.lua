--赫焉竜グランギニョル
-- 效果：
-- 「赫之圣女 卡尔特西娅」＋光·暗属性怪兽
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡融合召唤的场合才能发动。从卡组·额外卡组把1只6星以上的光·暗属性怪兽送去墓地。
-- ②：这张卡在怪兽区域或墓地存在的状态，对方发动的怪兽的效果让怪兽特殊召唤的场合，把这张卡除外才能发动。从卡组把1只「教导」怪兽或者从额外卡组把1只「死狱乡」怪兽特殊召唤。
local s,id,o=GetID()
-- s.initial_effect是卡的初始化入口：为本卡启用苏生限制，添加融合召唤手续（1只「赫之圣女 卡尔特西娅」+1只光/暗属性怪兽），并注册①效果（融合召唤成功时从卡组·额外卡组把1只6星以上光/暗属性怪兽送去墓地）和②效果（对方发动怪兽效果特召怪兽时除外自身，从卡组特召「教导」或从额外特召「死狱乡」怪兽）。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：需要1只卡号95515789（即「赫之圣女 卡尔特西娅」）和1只满足s.matfilter的光/暗属性怪兽作为融合素材；sub=true和insf=true表示允许使用融合素材代用，并按新式融合手续登记融合召唤。
	aux.AddFusionProcCodeFun(c,95515789,s.matfilter,1,true,true)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡融合召唤的场合才能发动。从卡组·额外卡组把1只6星以上的光·暗属性怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"从卡组送去墓地"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.tgcon)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次。②：这张卡在怪兽区域或墓地存在的状态，对方发动的怪兽的效果让怪兽特殊召唤的场合，把这张卡除外才能发动。从卡组把1只「教导」怪兽或者从额外卡组把1只「死狱乡」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"从卡组特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	-- 为②效果设置发动代价：将自己（这张卡）除外；aux.bfgcost在合法检查时确认自身能被除外作为代价，发动时立即将其除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 融合素材过滤函数：判断素材怪兽是否持有光属性或暗属性（符合「光·暗属性怪兽」的要求）。
function s.matfilter(c)
	return c:IsFusionAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)
end
-- ①效果的发动条件：本卡的召唤类型为融合召唤，即这张卡融合召唤成功时才能发动。
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- ①效果送墓对象的过滤条件：怪兽等级为6星以上，属性为光或暗，且能够被送去墓地（不受“不能送去墓地”效果影响）。
function s.tgfilter(c)
	return c:IsLevelAbove(6) and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and c:IsAbleToGrave()
end
-- ①效果的发动目标阶段：chk==0时检查卡组·额外卡组是否存在至少1只满足s.tgfilter的怪兽并返回结果；chk>0（发动确定）时设置本次效果将把1只怪兽送去墓地的操作信息。
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查：从己方卡组·额外卡组中确认存在至少1只6星以上、光/暗属性且可送去墓地的怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil) end
	-- 设置当前连锁的操作信息：本次效果包含“送去墓地”分类，预计将1张卡从己方卡组·额外卡组送去墓地，目标玩家为tp；该信息用于星尘龙等卡片的连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
-- ①效果处理：显示选择提示，从己方卡组·额外卡组选择1张满足s.tgfilter的卡，将其以REASON_EFFECT（效果）送去墓地；若选择不到则不处理。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家tp显示“请选择要送去墓地的卡”的选择提示，同时写入选择缓存供Duel.SelectMatchingCard使用。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从己方卡组·额外卡组中选择1张满足s.tgfilter的卡（数量为1），作为送去墓地的卡。
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡g以效果原因（REASON_EFFECT）送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- ②效果的触发过滤器：判断一只怪兽是否是由对方发动的怪兽效果特殊召唤而来的怪兽；获取它的特殊召唤类型、来源效果和召唤玩家，要求来源效果存在且已发动，类型为怪兽，且召唤玩家是对方（1-tp）。
function s.cfilter(c,tp)
	local typ,se,sp=c:GetSpecialSummonInfo(SUMMON_INFO_TYPE,SUMMON_INFO_REASON_EFFECT,SUMMON_INFO_REASON_PLAYER)
	return se and typ&TYPE_MONSTER~=0 and se:IsActivated() and sp==1-tp
end
-- ②效果的发动条件：在特殊召唤成功事件中，eg里存在至少1只满足s.cfilter的怪兽，即对方发动了怪兽的效果将怪兽特殊召唤。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- ②效果特殊召唤目标的过滤函数：可选己方卡组的「教导」（0x145）怪兽或额外卡组的「死狱乡」（0x164）怪兽；卡组怪兽需满足除外本卡后仍有可用主要怪兽区，额外怪兽需满足除外本卡后有可用的额外怪兽区/主怪兽区；且目标能够被特殊召唤。
function s.spfilter(c,e,tp,exc)
	local b1=c:IsSetCard(0x145) and c:IsLocation(LOCATION_DECK)
		-- 对于卡组的「教导」怪兽，额外确认除外这张卡（exc）后己方主要怪兽区仍有空位，才能选择该目标。
		and Duel.GetMZoneCount(tp,exc)>0
	local b2=c:IsSetCard(0x164) and c:IsLocation(LOCATION_EXTRA)
		-- 对于额外卡组的「死狱乡」怪兽，额外确认除外这张卡（exc）后己方场上仍存在可供额外卡组怪兽特殊召唤的区域（GetLocationCountFromEx>0），才能选择该目标。
		and Duel.GetLocationCountFromEx(tp,tp,exc,c)>0
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and (b1 or b2)
end
-- ②效果的发动目标阶段：chk==0时检查卡组·额外卡组是否存在至少1只满足s.spfilter的怪兽并返回结果；chk>0（发动确定）时设置本次效果将特殊召唤1只怪兽的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查：从己方卡组·额外卡组中确认存在至少1只满足s.spfilter（可为「教导」或「死狱乡」且有可用区域）的怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp,e:GetHandler()) end
	-- 设置当前连锁的操作信息：本次效果包含“特殊召唤”分类，预计从己方卡组·额外卡组特殊召唤1只怪兽，目标玩家为tp；用于连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
-- ②效果处理：显示选择提示，从己方卡组·额外卡组选择1只满足s.spfilter的怪兽，并以正面表示特殊召唤到己方场上；该特召会正常检查召唤条件与苏生限制。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家tp显示“请选择要特殊召唤的卡”的选择提示，同时写入选择缓存供Duel.SelectMatchingCard使用。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从己方卡组·额外卡组中选择1张满足s.spfilter的卡进行特殊召唤；处理时本卡已作为cost除外，因此exc传nil。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽以正面表示（POS_FACEUP）特殊召唤到己方场上；sumtype=0表示不赋予特定召唤方式，nocheck=false、nolimit=false表示仍会检查召唤条件与苏生限制。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
