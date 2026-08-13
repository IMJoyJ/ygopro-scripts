--暗黒界の魔神王 レイン
-- 效果：
-- ①：这张卡可以让自己场上1只7星以下的「暗黑界」怪兽回到持有者手卡，从墓地特殊召唤。
-- ②：这张卡被效果从手卡丢弃去墓地的场合才能发动。从卡组把「暗黑界的魔神王 雷恩」以外的1只5星以上的「暗黑界」怪兽加入手卡。被对方的效果丢弃的场合，可以再从自己的卡组·墓地选1只4星以下的「暗黑界」怪兽在自己或者对方场上特殊召唤。
function c41406613.initial_effect(c)
	-- ①：这张卡可以让自己场上1只7星以下的「暗黑界」怪兽回到持有者手卡，从墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41406613,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCondition(c41406613.spcon)
	e1:SetTarget(c41406613.sptg)
	e1:SetOperation(c41406613.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡被效果从手卡丢弃去墓地的场合才能发动。从卡组把「暗黑界的魔神王 雷恩」以外的1只5星以上的「暗黑界」怪兽加入手卡。被对方的效果丢弃的场合，可以再从自己的卡组·墓地选1只4星以下的「暗黑界」怪兽在自己或者对方场上特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(41406613,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c41406613.condition)
	e2:SetTarget(c41406613.target)
	e2:SetOperation(c41406613.operation)
	c:RegisterEffect(e2)
end
-- 该过滤函数用于选择作为特殊召唤代价的怪兽：要求表侧表示、暗黑界字段、7星以下、可以返回手牌，并且该怪兽返回手牌后自己场上仍存在可用的怪兽区域。
function c41406613.spfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x6) and c:IsLevelBelow(7) and c:IsAbleToHandAsCost()
		-- 进一步要求该怪兽返回手牌后，自己场上仍有可用怪兽区，以腾出位置进行从墓地的特殊召唤。
		and Duel.GetMZoneCount(tp,c)>0
end
-- 规则特殊召唤（EFFECT_SPSUMMON_PROC）的发动条件：若询问的是本卡自身则允许；本卡受「王家长眠之谷」影响时不能从墓地特殊召唤；否则检查自己场上是否存在可作为代价返回手牌的暗黑界怪兽。
function c41406613.spcon(e,c)
	if c==nil then return true end
	if c:IsHasEffect(EFFECT_NECRO_VALLEY) then return false end
	local tp=c:GetControler()
	-- 检查自己场上是否至少存在1只满足spfilter的暗黑界怪兽（即表侧、7星以下、可回手且回手后有空位）。
	return Duel.IsExistingMatchingCard(c41406613.spfilter,tp,LOCATION_MZONE,0,1,nil,tp)
end
-- 特殊召唤手续的目标选择：从自己场上符合条件的暗黑界怪兽中选出1只作为代价，选中后交给e:SetLabelObject记录，供后续处理使用。
function c41406613.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己场上所有满足spfilter的暗黑界怪兽，组成候选集合供玩家选择。
	local g=Duel.GetMatchingGroup(c41406613.spfilter,tp,LOCATION_MZONE,0,nil,tp)
	-- 弹出“请选择要返回手牌的卡”的选择提示，引导玩家选择用于返回手牌作为特殊召唤代价的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤规则效果的实际处理：取出之前在目标选择阶段记录的怪兽，将其返回持有者手牌，完成特殊召唤的代价处理。
function c41406613.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的怪兽返回持有者手牌，原因记为REASON_SPSUMMON，表示作为这次特殊召唤手续的一部分。
	Duel.SendtoHand(g,nil,REASON_SPSUMMON)
end
-- ②效果的发动条件判定：记录这张卡被丢弃前所在的控制者（用于判断是否被对方效果丢弃）；只有这张卡是“从手牌且因效果被丢弃去墓地”时，条件才成立。
function c41406613.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	e:SetLabel(c:GetPreviousControler())
	return c:IsPreviousLocation(LOCATION_HAND) and (r&(REASON_EFFECT+REASON_DISCARD))==REASON_EFFECT+REASON_DISCARD
end
-- 检索用过滤条件：从卡组中寻找「暗黑界」字段、5星以上、可以加入手牌、且卡名不是「暗黑界的魔神王 雷恩」的怪兽。
function c41406613.filter1(c)
	return c:IsSetCard(0x6) and c:IsAbleToHand() and c:IsLevelAbove(5) and not c:IsCode(41406613)
end
-- ②效果的发动合法性与处理预定：先确认卡组存在检索目标；然后根据是否因对方效果丢弃，将效果类别相应设为只检索或检索＋特殊召唤；最后声明将从卡组加入1张手牌。
function c41406613.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时判定卡组中是否存在1只满足filter1的「暗黑界」5星以上怪兽，作为可发动的条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c41406613.filter1,tp,LOCATION_DECK,0,1,nil) end
	if rp==1-tp and tp==e:GetLabel() then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	else
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	end
	-- 向系统登记本次连锁将进行“从卡组将1张卡加入手牌”的操作，便于其他卡片（如星尘龙等）进行对应。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 追加特殊召唤的过滤条件：对象为「暗黑界」4星以下的怪兽，且在自己或对方场上存在可用怪兽区时能够被特殊召唤到对应区域。
function c41406613.filter2(c,e,tp,ft,ft2)
	return c:IsSetCard(0x6) and c:IsLevelBelow(4)
		and ((ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP))
			or (ft2>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)))
end
-- ②效果处理：先从卡组检索1张5星以上暗黑界怪兽加入手牌并给对方确认；若是由对方效果丢弃且存在可特殊召唤的4星以下暗黑界怪兽，则询问玩家是否进行追加特殊召唤，选定怪兽和使用方后以表侧表示特殊召唤。
function c41406613.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上可用的怪兽区数量，用于判断能否在自己场上特殊召唤。
	local ft=Duel.GetMZoneCount(tp)
	-- 获取对方场上可用的怪兽区数量，用于判断能否在对方场上特殊召唤。
	local ft2=Duel.GetMZoneCount(1-tp)
	-- 弹出“请选择要加入手牌的卡”的选择提示，用于选择检索目标。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张满足filter1的暗黑界怪兽（5星以上、非本卡）加入手牌。
	local g=Duel.SelectMatchingCard(tp,c41406613.filter1,tp,LOCATION_DECK,0,1,1,nil)
	-- 若确实选到了卡且成功将其加入手牌，则继续执行后续的确认与追加特殊召唤部分。
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		-- 将检索到的卡向对方玩家公开确认，保证检索信息的透明。
		Duel.ConfirmCards(1-tp,g)
		if rp==1-tp and tp==e:GetLabel()
			-- 检查自己的卡组·墓地中是否存在1只满足filter2、且不受「王家长眠之谷」影响的暗黑界4星以下怪兽，以决定能否进行追加特殊召唤。
			and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(c41406613.filter2),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp,ft,ft2)
			-- 询问玩家是否要发动追加特殊召唤效果（从卡组·墓地特殊召唤4星以下暗黑界怪兽到场上），选择“是”才继续进行。
			and Duel.SelectYesNo(tp,aux.Stringid(41406613,2)) then  --"是否特殊召唤？"
			-- 弹出“请选择要特殊召唤的卡”的选择提示，用于选择追加特殊召唤的对象。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 从卡组·墓地选择1只满足filter2且不受「王家长眠之谷」影响的暗黑界4星以下怪兽，用于特殊召唤。
			local tg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c41406613.filter2),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp,ft,ft2)
			-- 中断当前效果处理，使随后进行的特殊召唤不再与前面的检索视为同一系列处理，避免造成错误的时点（错失时点）。
			Duel.BreakEffect()
			local tc=tg:GetFirst()
			local o1=ft>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
			local o2=ft2>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
			local opt=0
			if o1 and o2 then
				-- 当自己和对方式怪兽区都有空位时，让玩家选择将怪兽特殊召唤到自己场上还是对方场上，选项依次为“在自己场上特殊召唤”和“在对方场上特殊召唤”。
				opt=Duel.SelectOption(tp,aux.Stringid(41406613,3),aux.Stringid(41406613,4))  --"在自己场上特殊召唤/在对方场上特殊召唤"
			elseif o1 then
				opt=0
			else
				opt=1
			end
			local p=tp
			if opt==1 then p=1-tp end
			-- 将选中的怪兽以表侧攻击表示特殊召唤到目标玩家（p = tp或1-tp）的场上，并遵守常规的召唤条件和苏生限制。
			Duel.SpecialSummon(tc,0,tp,p,false,false,POS_FACEUP)
		end
	end
end
