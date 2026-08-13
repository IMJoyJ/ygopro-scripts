--オルターガイスト・マリオネッター
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡召唤时才能发动。从卡组把1张「幻变骚灵」陷阱卡在自己场上盖放。
-- ②：以自己场上1张「幻变骚灵」卡和自己墓地1只「幻变骚灵」怪兽为对象才能发动。作为对象的场上的卡送去墓地，作为对象的墓地的怪兽特殊召唤。
function c53143898.initial_effect(c)
	-- ①：这张卡召唤时才能发动。从卡组把1张「幻变骚灵」陷阱卡在自己场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(53143898,0))
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c53143898.settg)
	e1:SetOperation(c53143898.setop)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：以自己场上1张「幻变骚灵」卡和自己墓地1只「幻变骚灵」怪兽为对象才能发动。作为对象的场上的卡送去墓地，作为对象的墓地的怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(53143898,1))
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,53143898)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(c53143898.sptg)
	e2:SetOperation(c53143898.spop)
	c:RegisterEffect(e2)
end
-- 定义①效果检索/盖放的卡牌过滤条件：必须是「幻变骚灵」字段的陷阱卡，且当前可以被盖放到魔法与陷阱区。
function c53143898.setfilter(c)
	return c:IsSetCard(0x103) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
-- ①效果的发动条件判定函数：在效果发动时点检查卡组中是否存在满足setfilter条件的卡，以决定效果能否发动。
function c53143898.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若为发动条件检查（chk==0），则确认己方卡组中存在至少1张符合条件的「幻变骚灵」陷阱卡，才能发动①效果。
	if chk==0 then return Duel.IsExistingMatchingCard(c53143898.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- ①效果处理时的操作：从卡组选择1张符合条件的「幻变骚灵」陷阱卡，将其盖放到自己场上。
function c53143898.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 向操作玩家显示选择提示，要求其选择一张要盖放的卡牌。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家从己方卡组中选出1张满足setfilter条件的「幻变骚灵」陷阱卡。
	local g=Duel.SelectMatchingCard(tp,c53143898.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选出的卡牌覆盖到己方的魔法与陷阱区。
		Duel.SSet(tp,g:GetFirst())
	end
end
-- 定义②效果中“自己场上1张「幻变骚灵」卡”的可选对象过滤条件：表侧表示、是「幻变骚灵」卡、能够被送去墓地，用于场上任意区域。
function c53143898.thfilter1(c)
	return c:IsFaceup() and c:IsSetCard(0x103) and c:IsAbleToGrave()
end
-- 定义②效果中在己方主要怪兽区没有空位时的可选对象过滤条件：表侧表示、是「幻变骚灵」卡、能够被送去墓地，且位于主要怪兽区（非额外怪兽区），确保送墓后腾出特殊召唤所需的格子。
function c53143898.thfilter2(c)
	return c:IsFaceup() and c:IsSetCard(0x103) and c:IsAbleToGrave() and c:GetSequence()<5
end
-- 定义②效果中“自己墓地1只「幻变骚灵」怪兽”的可选对象过滤条件：是「幻变骚灵」怪兽，且能够被当前效果特殊召唤出来。
function c53143898.spfilter(c,e,tp)
	return c:IsSetCard(0x103) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动条件和目标选择处理：检查是否有可送去墓地的场上「幻变骚灵」卡和可特殊召唤的墓地「幻变骚灵」怪兽，然后让玩家选择两个对象并设置操作信息。
function c53143898.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取己方主要怪兽区的可用空格数量，用于判断特殊召唤后是否会有格子，并影响场上对象的选择范围。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then
		local b=false
		if ft>0 then
			-- 当主要怪兽区有空位时，检查自己场上是否存在1张以上符合条件的「幻变骚灵」卡可以作为送去墓地的对象。
			b=Duel.IsExistingTarget(c53143898.thfilter1,tp,LOCATION_ONFIELD,0,1,nil)
		else
			-- 当主要怪兽区无空位时，检查自己主要怪兽区是否存在1张以上符合条件的「幻变骚灵」卡可以作为送去墓地的对象。
			b=Duel.IsExistingTarget(c53143898.thfilter2,tp,LOCATION_MZONE,0,1,nil)
		end
		-- ②效果的发动条件：场上存在可送去墓地的「幻变骚灵」卡，且墓地存在可特殊召唤的「幻变骚灵」怪兽，两者同时满足才可发动。
		return b and Duel.IsExistingTarget(c53143898.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	end
	local g1=nil
	-- 向玩家显示选择提示，要求其选择一张要送去墓地的卡牌。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	if ft>0 then
		-- 当主要怪兽区有空位时，让玩家选择自己场上1张符合条件的「幻变骚灵」卡作为效果对象（送去墓地），并自动登记为当前连锁的对象。
		g1=Duel.SelectTarget(tp,c53143898.thfilter1,tp,LOCATION_ONFIELD,0,1,1,nil)
	else
		-- 当主要怪兽区无空位时，让玩家选择自己主要怪兽区1张符合条件的「幻变骚灵」卡作为效果对象（送去墓地），并自动登记为当前连锁的对象。
		g1=Duel.SelectTarget(tp,c53143898.thfilter2,tp,LOCATION_MZONE,0,1,1,nil)
	end
	-- 向玩家显示选择提示，要求其选择一张要特殊召唤的怪兽卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只符合条件的「幻变骚灵」怪兽作为效果对象（特殊召唤），并自动登记为当前连锁的对象。
	local g2=Duel.SelectTarget(tp,c53143898.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置当前连锁的操作信息，声明本效果包含“把对象卡送去墓地”，并指定可能被送去墓地的卡组为g1。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g1,1,0,0)
	-- 设置当前连锁的操作信息，声明本效果包含“特殊召唤”，并指定可能被特殊召唤的卡组为g2。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g2,1,0,0)
	e:SetLabelObject(g1:GetFirst())
end
-- ②效果处理时的实际操作：确认场上对象仍与效果相关后将其送去墓地；若送墓成功且墓地对象不受王家长眠之谷等影响，则将其特殊召唤。
function c53143898.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的两个效果对象，按顺序记为tc1（场上送去墓地的卡）和tc2（墓地特殊召唤的怪兽）。
	local tc1,tc2=Duel.GetFirstTarget()
	if tc1~=e:GetLabelObject() then tc1,tc2=tc2,tc1 end
	-- 判断场上对象是否仍与效果关联，若是则将其以效果原因送去墓地，并确认送墓操作实际成功。
	if tc1:IsRelateToEffect(e) and Duel.SendtoGrave(tc1,REASON_EFFECT)>0
		and tc1:IsLocation(LOCATION_GRAVE) and tc2:IsRelateToEffect(e)
		-- 额外判定墓地对象是否不受“王家长眠之谷”等效果影响（即仍可被特殊召唤），从而决定是否执行特殊召唤。
		and aux.NecroValleyFilter()(tc2) then
		-- 将墓地对象以表侧表示形式特殊召唤到己方场上（不检查召唤条件和苏生限制）。
		Duel.SpecialSummon(tc2,0,tp,tp,false,false,POS_FACEUP)
	end
end
