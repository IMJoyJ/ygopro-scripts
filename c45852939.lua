--蝕の双仔
-- 效果：
-- 4星怪兽×2
-- 这张卡超量召唤的场合，可以让自己场上的4阶怪兽作为4星怪兽来成为素材。这个卡名的②的效果1回合只能使用1次。
-- ①：把这张卡1个超量素材取除才能发动。这个回合，这张卡在同1次的战斗阶段中最多2次可以向怪兽攻击。
-- ②：这张卡被送去墓地的场合，以自己墓地2只其他的4阶以下的超量怪兽为对象才能发动。那2只之内的1只特殊召唤，另1只作为那只怪兽的超量素材。
local s,id,o=GetID()
-- 初始化效果函数：为这张卡注册“4星怪兽×2”的XYZ召唤手续与苏生限制，并注册①的起动效果（去素材后本回合战斗阶段可最多2次向怪兽攻击）和②的诱发选发效果（送去墓地时取对象从墓地特召1只超量怪兽并将另1只叠放）。
function s.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：使用2只满足s.mfilter的怪兽叠放；s.mfilter允许4星怪兽，也允许4阶超量怪兽当作4星素材来叠放，实现“可以让自己场上的4阶怪兽作为4星怪兽来成为素材”。
	aux.AddXyzProcedureLevelFree(c,s.mfilter,nil,2,2)
	c:EnableReviveLimit()
	-- ①：把这张卡1个超量素材取除才能发动。这个回合，这张卡在同1次的战斗阶段中最多2次可以向怪兽攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"2次攻击"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.xatkcon)
	e1:SetCost(s.xatkcost)
	e1:SetTarget(s.xatktg)
	e1:SetOperation(s.xatkop)
	c:RegisterEffect(e1)
	-- ②：这张卡被送去墓地的场合，以自己墓地2只其他的4阶以下的超量怪兽为对象才能发动。那2只之内的1只特殊召唤，另1只作为那超量素材。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- s.mfilter是XYZ素材筛选函数：满足“等级对xyzc为4”（即4星怪兽）或“阶级为4”（即4阶超量怪兽）即可作为素材，这样允许用4阶超量怪兽当作4星素材。
function s.mfilter(c,xyzc)
	return c:IsXyzLevel(xyzc,4) or c:IsRank(4)
end
-- ①效果的发动条件函数：当前回合玩家必须能够进入战斗阶段时，该效果才能发动。
function s.xatkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回Duel.IsAbleToEnterBP()的值，即是否允许进入战斗阶段，作为效果可发动的判定。
	return Duel.IsAbleToEnterBP()
end
-- ①效果的代价函数：发动前检查这张卡是否有至少1个超量素材可去除；实际发动时去除这张卡1个超量素材（作为发动代价）。
function s.xatkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- ①效果的追加条件检查：这张卡尚未适用过EFFECT_EXTRA_ATTACK_MONSTER效果时才能发动，防止追加攻击次数效果重复叠加。
function s.xatktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsHasEffect(EFFECT_EXTRA_ATTACK_MONSTER) end
end
-- ①效果处理：若这张卡仍与效果关联，则给它自身附加一个“对怪兽可追加攻击1次”的永续效果（原攻击次数+1，合计最多2次攻击），该效果不会被无效，回合结束阶段重置。
function s.xatkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 这个回合，这张卡在同1次的战斗阶段中最多2次可以向怪兽攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(1)
		c:RegisterEffect(e1)
	end
end
-- ②效果的目标筛选：对象必须能成为效果对象、阶级4以下，且能够作为超量素材叠放或被特殊召唤；用于从墓地选出符合条件的超量怪兽。
function s.tgfilter(c,e,tp)
	return c:IsCanBeEffectTarget(e) and c:IsRankBelow(4)
		and (c:IsCanOverlay() or c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- s.spfilter判断某只怪兽能否作为特召对象：自身可以被特殊召唤，并且另一只怪兽（g中除它以外）可以叠放在其下方作为超量素材。
function s.spfilter(c,g,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and g:IsExists(Card.IsCanOverlay,1,c)
end
-- s.fselect判断一组2只怪兽是否满足②的要求：其中至少1只可特召，另1只可作为素材叠放。
function s.fselect(g,e,tp)
	return g:IsExists(s.spfilter,1,nil,g,e,tp)
end
-- ②效果发动目标函数：从自己墓地选取除本卡外满足条件的2只4阶以下超量怪兽；需要己方主怪兽区有空位且存在可特召+可叠放的组合；选为对象后登记1次从墓地特召的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取自己墓地中满足s.tgfilter条件的超量怪兽集合（排除这张卡本身），作为选择对象的候选。
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_GRAVE,0,e:GetHandler(),e,tp)
	if chkc then return false end
	-- 效果发动合法性检查：己方主怪兽区有空位，且墓地候选组中存在满足“1只可特召、1只可叠放”组合的2只怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and g:CheckSubGroup(s.fselect,2,2,e,tp) end
	-- 显示“请选择要操作的卡”的UI提示，引导玩家选择对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	local sg=g:SelectSubGroup(tp,s.fselect,false,2,2,e,tp)
	-- 将选择的2只墓地超量怪兽设置为当前连锁的效果对象，建立效果关联。
	Duel.SetTargetCard(sg)
	-- 登记操作信息：本效果包含1次从墓地的特殊召唤（对象数量1，位置墓地），供其他卡效果联动检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- ②效果处理：取得仍与效果关联的2只对象；若主怪兽区有空位，则排除不能特召的卡；让玩家选择1只可特召的怪兽，特殊召唤成功后，将另1只叠放为素材；若特殊召唤不成功则不再叠放。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中所有仍与效果关联的对象卡（即发动时选择的2只墓地超量怪兽）。
	local g=Duel.GetTargetsRelateToChain()
	if #g~=2 then return end
	local exg=nil
	-- 检查己方主要怪兽区是否有空格；有空格才可特殊召唤，因此仅在有空位时排除不可特召的卡。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 从对象组g中筛选出当前不能被特殊召唤的卡，作为选择特召对象时的排除列表；如果两张都不能特召则清空排除列表（由后续选择处理失败）。
		exg=g:Filter(aux.NOT(Card.IsCanBeSpecialSummoned),nil,e,0,tp,false,false)
		if #exg==2 then exg=nil end
	end
	-- 显示“请选择要特殊召唤的卡”的UI提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从对象组g中，排除不能特召的卡（exg）后，选择1张满足s.spfilter且不受王家长眠之谷影响的卡作为特召对象，返回选中的卡。
	local dc=g:FilterSelect(tp,aux.NecroValleyFilter(s.spfilter),1,1,exg,g,e,tp):GetFirst()
	if not dc then return end
	-- 尝试将选中的怪兽表侧表示特殊召唤到己方场上；若特殊召唤成功（返回值非0）则继续将另一只叠放。
	if Duel.SpecialSummon(dc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		g:RemoveCard(dc)
		-- 将剩余的那只超量怪兽叠放在特殊召唤成功的怪兽下面，作为它的超量素材。
		Duel.Overlay(dc,g)
	end
end
