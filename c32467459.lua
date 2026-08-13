--エルシャドール・メシャフレール
-- 效果：
-- 「影依」怪兽＋暗属性怪兽＋地属性怪兽
-- 这张卡不用融合召唤不能特殊召唤。
-- ①：场上的这张卡不受对方发动的魔法·陷阱卡的效果影响，也不受原本的等级·阶级的数值比这张卡的等级低的对方怪兽发动的效果影响。
-- ②：1回合1次，支付800基本分才能发动。从卡组把1张「影依」卡或「炼狱」魔法·陷阱卡加入手卡。
-- ③：这张卡被送去墓地的场合才能发动。从自己墓地把1只「影依」怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果：解除召唤限制、注册融合素材条件、特殊召唤限制、免疫效果、检索效果和墓地特召效果。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 「影依」怪兽＋暗属性怪兽＋地属性怪兽
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_FUSION_MATERIAL)
	e0:SetCondition(s.FShaddollCondition)
	e0:SetOperation(s.FShaddollOperation)
	c:RegisterEffect(e0)
	-- 这张卡不用融合召唤不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 为特殊召唤限制效果设定判定函数aux.fuslimit，使这张卡仅能通过融合召唤方式特殊召唤。
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	-- ①：场上的这张卡不受对方发动的魔法·陷阱卡的效果影响，也不受原本的等级·阶级的数值比这张卡的等级低的对方怪兽发动的效果影响。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetValue(s.efilter)
	c:RegisterEffect(e2)
	-- ②：1回合1次，支付800基本分才能发动。从卡组把1张「影依」卡或「炼狱」魔法·陷阱卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"检索"
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(s.thcost)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
	-- ③：这张卡被送去墓地的场合才能发动。从自己墓地把1只「影依」怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
-- 免疫效果的过滤函数：仅免疫对方发动的效果；对魔法·陷阱效果直接免疫，对怪兽效果则交给qlifilter判定。
function s.efilter(e,te)
	if te:GetHandlerPlayer()==e:GetHandlerPlayer() or not te:IsActivated() then
		return false
	end
	if te:IsActiveType(TYPE_SPELL+TYPE_TRAP) then
		return true
	else
		-- 调用机壳通用抗性过滤函数，检查该效果是否为原本等级/阶级低于本卡的对方怪兽发动且已激活的效果。
		return aux.qlifilter(e,te)
	end
end
-- 检索效果的代价函数：先确认能支付800基本分，然后实际支付。
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测阶段：确认当前玩家能支付800基本分。
	if chk==0 then return Duel.CheckLPCost(tp,800) end
	-- 实际支付800基本分作为发动代价。
	Duel.PayLPCost(tp,800)
end
-- 检索过滤条件：是「影依」卡，或既是「炼狱」系列又是魔法·陷阱卡的卡，且能够加入手卡。
function s.thfilter(c)
	return (c:IsSetCard(0x9d) or c:IsSetCard(0xc5) and c:IsType(TYPE_SPELL+TYPE_TRAP)) and c:IsAbleToHand()
end
-- 检索效果的目标函数：确认卡组有检索对象，并登记从卡组加入手卡的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件判定：卡组中存在至少1张满足检索条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记操作信息：本次效果将从卡组把1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果处理：选择1张符合条件的卡加入手卡，并向对方展示。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足s.thfilter条件的卡片。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入持有者手卡，处理原因为效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示被加入手卡的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 墓地特殊召唤的过滤条件：是「影依」怪兽且可以被特殊召唤（满足苏生限制）。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x9d) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 墓地特召效果的目标函数：确认有怪兽区域空位且墓地存在符合条件的「影依」怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件判定：自己场上有可用的主要怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且墓地存在至少1只符合s.spfilter条件的「影依」怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 登记操作信息：本次效果将从墓地特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 墓地特召效果处理：选择1只符合条件的「影依」怪兽并以表侧表示特殊召唤到己方场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时确认：若没有可用怪兽区域则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从墓地选择1只符合条件的「影依」怪兽，且不受王家长眠之谷效果影响的卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 融合素材基本过滤器：可作为融合素材的卡，包括「影依」怪兽、暗/地属性怪兽或拥有相关效果的卡，且未被‘不能作为融合素材’限制。
function s.FShaddollFilter(c,fc)
	return (c:IsFusionSetCard(0x9d) or c:IsFusionAttribute(ATTRIBUTE_DARK+ATTRIBUTE_EARTH) or c:IsHasEffect(4904633))
		and c:IsCanBeFusionMaterial(fc) and not c:IsHasEffect(6205579)
end
-- 额外融合素材过滤器：用于场地效果从对方场上取得素材，要求表侧表示、不受该效果影响并满足基本素材条件。
function s.FShaddollExFilter(c,fc,fe)
	return c:IsFaceup() and not c:IsImmuneToEffect(fe) and s.FShaddollFilter(c,fc)
end
-- 素材组合检查第一层：存在「影依」怪兽，且其余卡中存在能满足后续暗/地属性组合的配置。
function s.FShaddollFilter1(c,g)
	return c:IsFusionSetCard(0x9d) and g:IsExists(s.FShaddollFilter2,1,c,g,c)
end
-- 素材组合检查第二层：存在暗属性素材（或带相关效果），且剩余卡中存在地属性素材。
function s.FShaddollFilter2(c,g,gc)
	return (c:IsFusionAttribute(ATTRIBUTE_DARK) or c:IsHasEffect(4904633))
		and g:IsExists(s.FShaddollFilter3,1,Group.FromCards(c,gc))
end
-- 素材组合检查第三层：目标卡为地属性或具有相关效果。
function s.FShaddollFilter3(c)
	return c:IsFusionAttribute(ATTRIBUTE_EARTH) or c:IsHasEffect(4904633)
end
-- 素材组合法性前半段检查：排除未含必选素材、额外素材超限、调弦限制及必须素材限制等非法情况。
function s.FShaddollCheck(g,gc,fc,tp,c,chkf,exg)
	if gc and not g:IsContains(gc) then return false end
	-- 若素材组中含有超过1张来自额外素材组的卡，则组合不合法。
	if exg and g:FilterCount(aux.IsInGroup,nil,exg)>1 then return false end
	-- 素材组中若存在带‘调弦之魔术师’相关限制的卡，则不能作为融合素材，组合不合法。
	if g:IsExists(aux.TuneMagicianCheckX,1,nil,g,EFFECT_TUNE_MAGICIAN_F) then return false end
	-- 检查素材组是否满足‘必须作为融合素材’的限制，若不满足则组合不合法。
	if not aux.MustMaterialCheck(g,tp,EFFECT_MUST_BE_FMATERIAL) then return false end
	-- 若存在额外融合检查条件 aux.FCheckAdditional，则必须通过该检查，否则不合法。
	if aux.FCheckAdditional and not aux.FCheckAdditional(tp,g,fc)
		-- 或存在目标额外检查条件 aux.FGoalCheckAdditional，若不通过则组合不合法。
		or aux.FGoalCheckAdditional and not aux.FGoalCheckAdditional(tp,g,fc) then return false end
	return g:IsExists(s.FShaddollFilter1,1,nil,g)
		-- 并且若指定了玩家，则要求融合召唤时有可用的额外怪兽区域。
		and (chkf==PLAYER_NONE or Duel.GetLocationCountFromEx(tp,tp,g,fc)>0)
end
-- 融合素材条件判定：从指定范围中筛选所有可用融合素材（含额外素材），检查能否组成3张满足要求的素材组。
function s.FShaddollCondition(e,g,gc,chkf)
	-- 当素材组g为空（判定能否发动融合）时，仅检查是否存在强制融合素材限制。
	if g==nil then return aux.MustMaterialCheck(nil,e:GetHandlerPlayer(),EFFECT_MUST_BE_FMATERIAL) end
	local c=e:GetHandler()
	local mg=g:Filter(s.FShaddollFilter,nil,c)
	local tp=e:GetHandlerPlayer()
	-- 获取己方场地区域的卡，用于判断能否借其效果追加额外融合素材。
	local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
	local exg=nil
	if fc and fc:IsHasEffect(81788994) and fc:IsCanRemoveCounter(tp,0x16,3,REASON_EFFECT) then
		local fe=fc:IsHasEffect(81788994)
		-- 从对方场上表侧表示怪兽中筛选可加入融合素材组的额外素材。
		exg=Duel.GetMatchingGroup(s.FShaddollExFilter,tp,0,LOCATION_MZONE,mg,c,fe)
	end
	if exg then mg:Merge(exg) end
	if gc and not mg:IsContains(gc) then return false end
	return mg:CheckSubGroup(s.FShaddollCheck,3,3,gc,fc,tp,c,chkf,exg)
end
-- 融合素材选择处理：构建候选素材组（含额外素材），提示玩家选择3张作为融合素材；若用到额外素材则移除对应计数器，然后设置融合素材。
function s.FShaddollOperation(e,tp,eg,ep,ev,re,r,rp,gc,chkf)
	local c=e:GetHandler()
	local mg=eg:Filter(s.FShaddollFilter,nil,c)
	-- 取得己方场地区域的卡，用于检查是否有提供额外素材的场地效果。
	local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
	local exg=nil
	if fc and fc:IsHasEffect(81788994) and fc:IsCanRemoveCounter(tp,0x16,3,REASON_EFFECT) then
		local fe=fc:IsHasEffect(81788994)
		-- 从对方场上表侧表示怪兽中筛选可用的额外融合素材。
		exg=Duel.GetMatchingGroup(s.FShaddollExFilter,tp,0,LOCATION_MZONE,mg,c,fe)
	end
	if exg then mg:Merge(exg) end
	-- 提示玩家选择要作为融合素材的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)  --"请选择要作为融合素材的卡"
	local g=mg:SelectSubGroup(tp,s.FShaddollCheck,false,3,3,gc,c,tp,c,chkf,exg)
	-- 如果最终选择的素材组中包含来自额外素材组的卡，则执行后续扣除计数处理。
	if exg and g:IsExists(aux.IsInGroup,1,nil,exg) then
		fc:RemoveCounter(tp,0x16,3,REASON_EFFECT)
	end
	-- 将选定的素材组设置为本次融合召唤使用的融合素材。
	Duel.SetFusionMaterial(g)
end
