--マスター・ピース
-- 效果：
-- ①：以自己墓地2只怪兽为对象才能发动。那2只怪兽效果无效特殊召唤，只用那2只为素材把1只光属性「霍普」超量怪兽超量召唤。
function c20285786.initial_effect(c)
	-- ①：以自己墓地2只怪兽为对象才能发动。那2只怪兽效果无效特殊召唤，只用那2只为素材把1只光属性「霍普」超量怪兽超量召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c20285786.target)
	e1:SetOperation(c20285786.activate)
	c:RegisterEffect(e1)
end
-- 筛选自己墓地中既能成为效果对象又能被特殊召唤的怪兽，作为超量召唤候选素材。
function c20285786.filter(c,e,tp)
	return c:IsCanBeEffectTarget(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 筛选额外卡组中光属性『霍普』字段的超量怪兽，且当前可用2只怪兽作为素材进行超量召唤。
function c20285786.xyzfilter(c,mg)
	return c:IsSetCard(0x7f) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsXyzSummonable(mg,2,2)
end
-- 作为第一只素材的筛选：检查墓地怪兽组中是否存在另一只怪兽，使得两者能作为素材超量召唤符合条件的霍普怪兽。
function c20285786.mfilter1(c,mg,exg)
	return mg:IsExists(c20285786.mfilter2,1,c,c,exg)
end
-- 作为第二只素材的筛选：检查额外卡组中是否存在能用候选怪兽和已选素材作为素材进行超量召唤的怪兽。
function c20285786.mfilter2(c,mc,exg)
	return exg:IsExists(Card.IsXyzSummonable,1,nil,Group.FromCards(c,mc))
end
-- 效果发动时的目标选择与合法性检查：获取墓地可选素材和额外可选超量怪兽，并确认玩家可特殊召唤2只、区域足够且不受青眼精灵龙限制等。
function c20285786.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取自己墓地中可作为效果对象且可特殊召唤的怪兽集合，作为超量召唤候选素材。
	local mg=Duel.GetMatchingGroup(c20285786.filter,tp,LOCATION_GRAVE,0,nil,e,tp)
	-- 获取额外卡组中满足条件的光属性『霍普』超量怪兽集合，这些怪兽应能使用候选素材进行超量召唤。
	local exg=Duel.GetMatchingGroup(c20285786.xyzfilter,tp,LOCATION_EXTRA,0,nil,mg)
	-- 检查玩家本回合是否还能进行至少2次特殊召唤（因为需要特殊召唤2只素材怪兽）。
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己主要怪兽区域是否至少还有2个空位，用于特殊召唤2只素材怪兽。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and exg:GetCount()>0 end
	-- 显示『请选择要特殊召唤的卡』提示，准备选择第1只墓地怪兽作为素材。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg1=mg:FilterSelect(tp,c20285786.mfilter1,1,1,nil,mg,exg)
	local tc1=sg1:GetFirst()
	-- 显示『请选择要特殊召唤的卡』提示，准备选择第2只墓地怪兽作为素材。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg2=mg:FilterSelect(tp,c20285786.mfilter2,1,1,tc1,tc1,exg)
	sg1:Merge(sg2)
	-- 将选中的2只墓地怪兽设置为当前效果的对象，供后续处理时确认。
	Duel.SetTargetCard(sg1)
	-- 向系统登记本效果将进行2只怪兽的特殊召唤，用于连锁处理和时点触发。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg1,2,0,0)
end
-- 效果处理时检查目标怪兽是否仍与效果关联且可以特殊召唤，过滤出实际能特殊召唤的怪兽。
function c20285786.filter2(c,e,tp)
	return c:IsRelateToEffect(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理阶段：在满足条件时将对象怪兽效果无效并特殊召唤，再用它们超量召唤1只光属性『霍普』超量怪兽。
function c20285786.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 若自己主要怪兽区域空位不足2个，则中止效果处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 从连锁信息中取出效果发动时选定的对象卡，并过滤出仍能特殊召唤的怪兽。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c20285786.filter2,nil,e,tp)
	if g:GetCount()<2 then return end
	local tc=g:GetFirst()
	while tc do
		-- 将其中一只素材怪兽以表侧攻击表示特殊召唤（作为连续特殊召唤的一步，暂不完成处理）。
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		-- 那2只怪兽效果无效特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
	-- 完成所有素材怪兽的特殊召唤，触发召唤成功的时点。
	Duel.SpecialSummonComplete()
	-- 刷新场地信息，确保后续判断（如素材是否仍在场上）使用最新状态。
	Duel.AdjustAll()
	if g:FilterCount(Card.IsLocation,nil,LOCATION_MZONE)<2 then return end
	-- 获取额外卡组中可用当前成功特殊召唤的2只素材作为超量素材的光属性『霍普』超量怪兽。
	local xyzg=Duel.GetMatchingGroup(c20285786.xyzfilter,tp,LOCATION_EXTRA,0,nil,g)
	if xyzg:GetCount()>0 then
		-- 显示『请选择要特殊召唤的卡』提示，让玩家选择要超量召唤的额外怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local xyz=xyzg:Select(tp,1,1,nil):GetFirst()
		-- 使用2只素材怪兽进行超量召唤，将选择的『霍普』超量怪兽特殊召唤到场上。
		Duel.XyzSummon(tp,xyz,g)
	end
end
