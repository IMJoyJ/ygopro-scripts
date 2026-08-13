--炎王妃 ウルカニクス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。这张卡以外的自己的手卡·场上（表侧表示）1只炎属性怪兽破坏，「炎王妃 火神不死鸟」以外的1只兽族·兽战士族·鸟兽族的炎属性怪兽从卡组加入手卡。那之后，可以把这张卡的等级变成和这个效果加入手卡的怪兽相同。
-- ②：这张卡被破坏送去墓地的场合才能发动。从卡组把1只「炎王神兽 大鹏不死鸟」守备表示特殊召唤。
local s,id,o=GetID()
-- 为「炎王妃 火神不死鸟」注册效果：①召唤·特殊召唤成功时触发的破坏+检索+可变等级效果（e1处理召唤，e2克隆处理特殊召唤）；②被破坏送去墓地时从卡组特殊召唤「炎王神兽 大鹏不死鸟」的效果（e3）。
function s.initial_effect(c)
	-- 对应①效果中“这张卡召唤·特殊召唤的场合才能发动。这张卡以外的自己的手卡·场上（表侧表示）1只炎属性怪兽破坏，「炎王妃 火神不死鸟」以外的1只兽族·兽战士族·鸟兽族的炎属性怪兽从卡组加入手卡。那之后，可以把这张卡的等级变成和这个效果加入手卡的怪兽相同。”（此处e1登记召唤成功时的触发，e2为特殊召唤时的克隆）
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- 对应②效果：“②：这张卡被破坏送去墓地的场合才能发动。从卡组把1只「炎王神兽 大鹏不死鸟」守备表示特殊召唤。”
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 筛选可作为破坏对象的卡：炎属性，且位于手牌或场上表侧表示（即“自己的手卡·场上（表侧表示）1只炎属性怪兽”）。
function s.dfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and (c:IsLocation(LOCATION_HAND) or c:IsFaceup())
end
-- 筛选检索目标：不是「炎王妃 火神不死鸟」本身，炎属性，且种族为兽族·兽战士族·鸟兽族，并可以被加入手卡（对应检索条件）。
function s.thfilter(c)
	return not c:IsCode(id) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToHand() and c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST)
end
-- ①效果的发动判定：检查自己手牌·场上存在至少1张除自身外的可破坏炎属性怪兽，同时卡组存在至少1只满足检索条件的炎属性怪兽，两者都满足才可发动。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在“这张卡以外的自己的手卡·场上（表侧表示）1只炎属性怪兽”可以作为破坏对象。
	if chk==0 then return Duel.IsExistingMatchingCard(s.dfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,e:GetHandler())
		-- 检查卡组中是否存在「炎王妃 火神不死鸟」以外的1只兽族·兽战士族·鸟兽族的炎属性怪兽可以加入手卡。
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 取得所有满足破坏条件的候选卡（自己的手牌·场上表侧表示的炎属性怪兽，排除本卡），用于设置操作信息。
	local g=Duel.GetMatchingGroup(s.dfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,e:GetHandler())
	-- 设置操作信息：该效果将破坏1张卡，候选集合为g；此信息供相关卡片的发动检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息：该效果含有从卡组检索1张卡加入手卡；因为具体选择张在效果处理时确定，targets为nil。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：先选择并破坏1张自己的手牌或场上表侧表示的炎属性怪兽（本卡除外），破坏成功后再从卡组选1只符合条件的炎属性怪兽加入手卡并向对方确认；若本卡仍与效果关联且表侧表示，可询问玩家是否将等级变为加入手卡怪兽的等级，同意则赋予等级变更效果。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 弹出选择提示，让玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从自己的手牌·场上表侧表示的炎属性怪兽中，选择除本卡外的1张作为破坏对象（效果处理时选择，非发动时取对象）。
	local dg=Duel.SelectMatchingCard(tp,s.dfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,aux.ExceptThisCard(e))
	-- 若成功选择了破坏对象且该对象被效果破坏，才继续执行后续检索加入手卡；否则效果处理直接结束。
	if dg:GetCount()>0 and Duel.Destroy(dg,REASON_EFFECT)~=0 then
		-- 弹出选择提示，让玩家从卡组选择要加入手卡的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组选择1只满足检索条件的炎属性怪兽（「炎王妃 火神不死鸟」以外、兽/兽战士/鸟兽族、炎属性、可加入手卡）。
		local thg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if thg:GetCount()>0 then
			-- 将选择的卡加入其持有者的手卡（此处为己方手卡），返回值th为实际加入手卡的数量。
			local th=Duel.SendtoHand(thg,nil,REASON_EFFECT)
			-- 将刚才加入手卡的卡展示给对方玩家确认，符合卡组检索后公开确认的规则。
			Duel.ConfirmCards(1-tp,thg)
			if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
			local lv=thg:GetFirst():GetLevel()
			-- 当确实有卡加入手卡、该卡有等级、本卡当前等级不同且玩家选择“是”时，才执行等级变更的任意处理。
			if th*lv>0 and c:GetLevel()~=lv and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then  --"是否变成相同等级？"
				-- 中断当前效果处理，使等级变更处理与前后的破坏/检索处理在不同时点结算，避免错时点。
				Duel.BreakEffect()
				-- 对应①最后一句：“那之后，可以把这张卡的等级变成和这个效果加入手卡的怪兽相同。”
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_CHANGE_LEVEL)
				e1:SetValue(lv)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
				c:RegisterEffect(e1)
			end
		end
	end
end
-- ②效果的发动条件：本卡被破坏并因此送去墓地时才能发动。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY)
end
-- 筛选特殊召唤对象：卡号为23015896（「炎王神兽 大鹏不死鸟」），且能够被当前效果以表侧守备表示特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsCode(23015896) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ②效果的发动判定：自己主要怪兽区有空位，且卡组存在可以特殊召唤的「炎王神兽 大鹏不死鸟」。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上主要怪兽区是否存在可用空格，确保有特殊召唤的位置。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在符合条件的「炎王神兽 大鹏不死鸟」可供特殊召唤。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：该效果将从卡组特殊召唤1只怪兽，预定特殊召唤到己方场上。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：若自己主要怪兽区仍有空位，则从卡组选择1只「炎王神兽 大鹏不死鸟」，以表侧守备表示特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己场上主要怪兽区有空位，没有空位则特殊召唤不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出选择提示，让玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只符合条件的「炎王神兽 大鹏不死鸟」作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的「炎王神兽 大鹏不死鸟」以表侧守备表示特殊召唤到己方场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
