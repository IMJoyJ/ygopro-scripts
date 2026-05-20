--赤しゃりの軍貫
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡的卡名只要在手卡·卡组·场上·墓地存在当作「舍利军贯」使用。
-- ②：把手卡1只其他的「舍利军贯」给对方观看才能发动。这张卡从手卡特殊召唤。那之后，以下可以适用。
-- ●「舍利军贯」以外的1只「军贯」怪兽效果无效从卡组特殊召唤，用那只怪兽和这张卡为素材，把有那只怪兽的卡名记述的1只超量怪兽当作超量召唤从额外卡组特殊召唤。
function c63748694.initial_effect(c)
	-- 设置此卡在手卡、卡组、场上、墓地存在时，卡名当作「舍利军贯」使用
	aux.EnableChangeCode(c,24639891,LOCATION_HAND+LOCATION_DECK+LOCATION_MZONE+LOCATION_GRAVE)
	-- 这个卡名的②的效果1回合只能使用1次。②：把手卡1只其他的「舍利军贯」给对方观看才能发动。这张卡从手卡特殊召唤。那之后，以下可以适用。●「舍利军贯」以外的1只「军贯」怪兽效果无效从卡组特殊召唤，用那只怪兽和这张卡为素材，把有那只怪兽的卡名记述的1只超量怪兽当作超量召唤从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,63748694)
	e1:SetCost(c63748694.spcost)
	e1:SetTarget(c63748694.sptg)
	e1:SetOperation(c63748694.spop)
	c:RegisterEffect(e1)
end
-- 过滤手卡中未公开的「舍利军贯」
function c63748694.cfilter(c)
	return c:IsCode(24639891) and not c:IsPublic()
end
-- 效果②的发动代价：将手卡1只其他的「舍利军贯」给对方观看
function c63748694.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在除自身以外的「舍利军贯」
	if chk==0 then return Duel.IsExistingMatchingCard(c63748694.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 提示玩家选择要给对方确认的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 让玩家选择手卡中1只其他的「舍利军贯」
	local g=Duel.SelectMatchingCard(tp,c63748694.cfilter,tp,LOCATION_HAND,0,1,1,e:GetHandler())
	-- 给对方玩家确认选择的卡片
	Duel.ConfirmCards(1-tp,g)
	-- 洗切手卡
	Duel.ShuffleHand(tp)
end
-- 效果②的发动准备：检查自身能否特殊召唤
function c63748694.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 过滤卡组中可以特殊召唤，且能作为素材超量召唤额外卡组对应怪兽的「舍利军贯」以外的「军贯」怪兽
function c63748694.filter(c,e,tp,oc)
	return c:IsSetCard(0x166) and not c:IsCode(24639891) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查额外卡组是否存在满足条件的超量怪兽
		and Duel.IsExistingMatchingCard(c63748694.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,oc,c)
end
-- 过滤额外卡组中，记述了卡组特召怪兽卡名、可以被这两只怪兽作为素材超量召唤的超量怪兽
function c63748694.xyzfilter(c,e,tp,oc,mc)
	-- 检查卡片是否为超量怪兽，且其效果文本中是否记述了作为素材的怪兽的卡名
	return c:IsType(TYPE_XYZ) and aux.IsCodeListed(c,mc:GetCode())
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
		and oc:IsCanBeXyzMaterial(c) and mc:IsCanBeXyzMaterial(c)
		-- 检查在将这两只怪兽作为素材时，是否有足够的额外怪兽区域空位来特殊召唤该超量怪兽
		and Duel.GetLocationCountFromEx(tp,tp,Group.FromCards(oc,mc),c)>0
		-- 检查这两只怪兽是否满足必须作为超量素材的限制条件
		and aux.MustMaterialCheck(Group.FromCards(oc,mc),tp,EFFECT_MUST_BE_XMATERIAL)
end
-- 效果②的效果处理：特殊召唤自身，并可选从卡组特召怪兽并进行超量召唤
function c63748694.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取卡组中所有满足条件的「军贯」怪兽
	local mg=Duel.GetMatchingGroup(c63748694.filter,tp,LOCATION_DECK,0,nil,e,tp,c)
	-- 若此卡仍存在于手卡，则将其特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 检查自己场上是否有可用的怪兽区域空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133) and Duel.IsPlayerCanSpecialSummonCount(tp,2)
		-- 检查卡组中是否有可特召的怪兽，并让玩家选择是否适用后续效果
		and mg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(63748694,0)) then  --"是否特殊召唤并超量召唤？"
		-- 中断当前效果处理，使后续的特殊召唤不与此卡的特殊召唤视为同时处理
		Duel.BreakEffect()
		-- 提示玩家选择要特殊召唤的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=mg:Select(tp,1,1,nil)
		local sc=sg:GetFirst()
		-- 将选择的「军贯」怪兽从卡组特殊召唤
		Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
		-- 效果无效从卡组特殊召唤
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		sc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		sc:RegisterEffect(e2)
		-- 刷新场地信息，使无效化效果立即生效
		Duel.AdjustAll()
		local g=Group.FromCards(c,sc)
		if g:FilterCount(Card.IsLocation,nil,LOCATION_MZONE)<2 then return end
		-- 获取额外卡组中所有满足条件的超量怪兽
		local xyzg=Duel.GetMatchingGroup(c63748694.xyzfilter,tp,LOCATION_EXTRA,0,nil,e,tp,c,sc)
		if xyzg:GetCount()>0 then
			-- 提示玩家选择要特殊召唤的超量怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local xyz=xyzg:Select(tp,1,1,nil):GetFirst()
			xyz:SetMaterial(g)
			-- 将这两只怪兽重叠作为超量素材
			Duel.Overlay(xyz,g)
			-- 将超量怪兽当作超量召唤从额外卡组特殊召唤
			Duel.SpecialSummon(xyz,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
			xyz:CompleteProcedure()
		end
	end
end
