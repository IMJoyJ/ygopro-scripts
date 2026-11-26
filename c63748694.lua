--赤しゃりの軍貫
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡的卡名只要在手卡·卡组·场上·墓地存在当作「舍利军贯」使用。
-- ②：把手卡1只其他的「舍利军贯」给对方观看才能发动。这张卡从手卡特殊召唤。那之后，以下可以适用。
-- ●「舍利军贯」以外的1只「军贯」怪兽效果无效从卡组特殊召唤，用那只怪兽和这张卡为素材，把有那只怪兽的卡名记述的1只超量怪兽当作超量召唤从额外卡组特殊召唤。
function c63748694.initial_effect(c)
	-- 永续效果，这张卡只要在手卡·卡组·场上·墓地存在，卡名当作「舍利军贯」使用（对应①效果：这张卡的卡名只要在手卡·卡组·场上·墓地存在当作「舍利军贯」使用）
	aux.EnableChangeCode(c,24639891,LOCATION_HAND+LOCATION_DECK+LOCATION_MZONE+LOCATION_GRAVE)
	-- 这个卡名的②的效果1回合只能使用1次。 ②：把手卡1只其他的「舍利军贯」给对方观看才能发动。这张卡从手卡特殊召唤。那之后，以下可以适用。 ●「舍利军贯」以外的1只「军贯」怪兽效果无效从卡组特殊召唤，用那只怪兽和这张卡为素材，把有那只怪兽的卡名记述的1只超量怪兽当作超量召唤从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,63748694)
	e1:SetCost(c63748694.spcost)
	e1:SetTarget(c63748694.sptg)
	e1:SetOperation(c63748694.spop)
	c:RegisterEffect(e1)
end
-- 过滤函数，检查是否为手卡中未处于公开状态的「舍利军贯」
function c63748694.cfilter(c)
	return c:IsCode(24639891) and not c:IsPublic()
end
-- 发动代价处理，检查并选择手卡中除自身外1只未公开的「舍利军贯」给对方确认并洗切手卡
function c63748694.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手卡是否存在这张卡以外至少1只未公开的「舍利军贯」
	if chk==0 then return Duel.IsExistingMatchingCard(c63748694.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 提示控制者选择手卡1只「舍利军贯」给对方观看
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从自己手卡选择1张除自身外未公开的「舍利军贯」
	local g=Duel.SelectMatchingCard(tp,c63748694.cfilter,tp,LOCATION_HAND,0,1,1,e:GetHandler())
	-- 向对方展示选中的「舍利军贯」
	Duel.ConfirmCards(1-tp,g)
	-- 洗切自己的手卡
	Duel.ShuffleHand(tp)
end
-- 检查自己怪兽区是否有空位且此卡可特殊召唤，并设置操作信息
function c63748694.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否至少有1个空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置将手卡的这张卡特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 过滤函数，检查是否为「舍利军贯」以外的「军贯」怪兽、可特殊召唤且额外卡组存在对应可超量召唤的超量怪兽
function c63748694.filter(c,e,tp,oc)
	return c:IsSetCard(0x166) and not c:IsCode(24639891) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查额外卡组是否存在可用这张卡和该怪兽作为超量素材超量召唤的超量怪兽
		and Duel.IsExistingMatchingCard(c63748694.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,oc,c)
end
-- 过滤函数，检查额外卡组怪兽是否为记述了目标怪兽卡名的超量怪兽、素材合法、额外空位充足且满足必须素材限制
function c63748694.xyzfilter(c,e,tp,oc,mc)
	-- 判断额外卡组怪兽是否为超量怪兽且效果文本记述了卡组特召怪兽的卡名
	return c:IsType(TYPE_XYZ) and aux.IsCodeListed(c,mc:GetCode())
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
		and oc:IsCanBeXyzMaterial(c) and mc:IsCanBeXyzMaterial(c)
		-- 检查以两只怪兽为素材将其送离怪兽区后，从额外卡组特殊召唤该超量怪兽的可用格子数是否充足
		and Duel.GetLocationCountFromEx(tp,tp,Group.FromCards(oc,mc),c)>0
		-- 检查两只怪兽是否满足“必须作为超量素材”类效果的限制
		and aux.MustMaterialCheck(Group.FromCards(oc,mc),tp,EFFECT_MUST_BE_XMATERIAL)
end
-- 效果处理，将此卡从手卡特殊召唤后，可从卡组效果无效特召1只其他「军贯」怪兽并用两只怪兽把有其卡名记述的超量怪兽当作超量召唤特殊召唤
function c63748694.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取卡组中所有满足后续超量联动条件的「军贯」怪兽
	local mg=Duel.GetMatchingGroup(c63748694.filter,tp,LOCATION_DECK,0,nil,e,tp,c)
	-- 将与效果关联的这张卡表侧表示特殊召唤到自己场上并判断是否成功
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 检查自己怪兽区是否仍有可用空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133) and Duel.IsPlayerCanSpecialSummonCount(tp,2)
		-- 若卡组存在可特召并超量的「军贯」怪兽，询问控制者是否适用后续效果
		and mg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(63748694,0)) then  --"是否特殊召唤并超量召唤？"
		-- 中断当前效果处理，使后续从卡组特殊召唤与超量召唤视为不同时处理
		Duel.BreakEffect()
		-- 提示控制者从卡组选择要特殊召唤的「军贯」怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=mg:Select(tp,1,1,nil)
		local sc=sg:GetFirst()
		-- 将选中的「军贯」怪兽从卡组表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
		-- ●「舍利军贯」以外的1只「军贯」怪兽效果无效从卡组特殊召唤
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		sc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		sc:RegisterEffect(e2)
		-- 立刻刷新场地与状态信息，以便正确判定两只怪兽作为超量素材的条件
		Duel.AdjustAll()
		local g=Group.FromCards(c,sc)
		if g:FilterCount(Card.IsLocation,nil,LOCATION_MZONE)<2 then return end
		-- 获取额外卡组中可用这两只怪兽作为超量素材特殊召唤的超量怪兽
		local xyzg=Duel.GetMatchingGroup(c63748694.xyzfilter,tp,LOCATION_EXTRA,0,nil,e,tp,c,sc)
		if xyzg:GetCount()>0 then
			-- 提示控制者从额外卡组选择要当作超量召唤特殊召唤的超量怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local xyz=xyzg:Select(tp,1,1,nil):GetFirst()
			xyz:SetMaterial(g)
			-- 将这张卡和从卡组特殊召唤的「军贯」怪兽叠放到目标超量怪兽下方作为超量素材
			Duel.Overlay(xyz,g)
			-- 将选中的超量怪兽当作超量召唤从额外卡组表侧表示特殊召唤
			Duel.SpecialSummon(xyz,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
			xyz:CompleteProcedure()
		end
	end
end
