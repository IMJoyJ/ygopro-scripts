--ペンデュラム・エクシーズ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己的灵摆区域2张卡为对象才能发动。那2张卡效果无效特殊召唤，只用那2只怪兽为素材把1只超量怪兽超量召唤。那个时候，要作为超量素材的1只怪兽的等级可以当作和另1只怪兽相同等级使用。
function c46005939.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己的灵摆区域2张卡为对象才能发动。那2张卡效果无效特殊召唤，只用那2只怪兽为素材把1只超量怪兽超量召唤。那个时候，要作为超量素材的1只怪兽的等级可以当作和另1只怪兽相同等级使用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,46005939+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c46005939.target)
	e1:SetOperation(c46005939.activate)
	c:RegisterEffect(e1)
end
-- 筛选灵摆区域中可作为第一张素材的卡片：该卡能够被特殊召唤，且灵摆区域还存在另一张卡可作为第二张素材。
function c46005939.spfilter1(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查自己的灵摆区域是否存在除当前卡片外的另一张卡，并满足spfilter2的配合条件，以保证能凑齐2张超量素材。
		and Duel.IsExistingTarget(c46005939.spfilter2,tp,LOCATION_PZONE,0,1,c,e,tp,c)
end
-- 定义超量素材等级调整函数：返回该怪兽当前等级加上通过e:SetLabel存入的另一只怪兽等级（高16位），使其作为超量素材时等级可视为与另一只素材相同。
function c46005939.xyzlv(e,c,rc)
	return e:GetHandler():GetLevel()+e:GetLabel()*0x10000
end
-- 过滤第二张灵摆区素材：确认其可特殊召唤，并临时为两张素材赋予等级互换效果后，检查额外卡组是否有能用这两张卡作为2个素材的XYZ怪兽；结束后重置临时效果。
function c46005939.spfilter2(c,e,tp,mc)
	if not c:IsCanBeSpecialSummoned(e,0,tp,false,false) then return false end
	local e1=nil
	local e2=nil
	if c:IsLevelAbove(1) and mc:IsLevelAbove(1) then
		-- 那个时候，要作为超量素材的1只怪兽的等级可以当作和另1只怪兽相同等级使用。
		e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_XYZ_LEVEL)
		e1:SetValue(c46005939.xyzlv)
		e1:SetLabel(mc:GetLevel())
		c:RegisterEffect(e1,true)
		-- 那2张卡效果无效特殊召唤，只用那2只怪兽为素材把1只超量怪兽超量召唤。那个时候，要作为超量素材的1只怪兽的等级可以当作和另1只怪兽相同等级使用。
		e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_XYZ_LEVEL)
		e2:SetValue(c46005939.xyzlv)
		e2:SetLabel(c:GetLevel())
		mc:RegisterEffect(e2,true)
	end
	-- 检查额外卡组中是否存在能用这两张怪兽作为2只素材进行超量召唤的XYZ怪兽，用于确定效果是否可行。
	local res=Duel.IsExistingMatchingCard(Card.IsXyzSummonable,tp,LOCATION_EXTRA,0,1,nil,Group.FromCards(c,mc),2,2)
	if e1 then e1:Reset() end
	if e2 then e2:Reset() end
	return res
end
-- 发动时的目标选择函数：确认发动条件合法，并将自己的灵摆区域2张卡设定为效果对象。
function c46005939.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查玩家本回合能否进行2次特殊召唤，即特召次数限制是否允许连续特殊召唤2只怪兽。
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 确认自己主要怪兽区域至少还有2个可用空格，以容纳2只特殊召唤的怪兽。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 确认自己的灵摆区域存在至少1张满足spfilter1条件的卡片，即存在可作为第一张素材且能配齐2张素材的对象。
		and Duel.IsExistingTarget(c46005939.spfilter1,tp,LOCATION_PZONE,0,1,nil,e,tp) end
	-- 获取自己灵摆区域的所有卡片，作为后续选择对象的候选组。
	local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	-- 将选中的灵摆区域卡组登记为当前连锁的效果对象（通常为2张）。
	Duel.SetTargetCard(g)
	-- 设置效果处理信息：本次效果将进行2只怪兽的特殊召唤（CATEGORY_SPECIAL_SUMMON）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,0,0)
end
-- 处理阶段的过滤函数：判定对象卡仍与发动时的效果相关，且当前仍可被特殊召唤。
function c46005939.spfilter3(c,e,tp)
	return c:IsRelateToEffect(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理函数：实际执行将2只灵摆怪兽效果无效并特殊召唤，随后进行1只超量怪兽的超量召唤。
function c46005939.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 处理时再次检查主要怪兽区域空位是否至少为2，避免特殊召唤无法进行。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 从连锁信息中取出发动时设定的对象卡组，并过滤出仍然满足可特殊召唤条件的卡片。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c46005939.spfilter3,nil,e,tp)
	if g:GetCount()<2 then return end
	local tc1=g:GetFirst()
	local tc2=g:GetNext()
	-- 将第一只灵摆怪兽以表侧表示加入特殊召唤处理流程（特殊召唤Step）。
	Duel.SpecialSummonStep(tc1,0,tp,tp,false,false,POS_FACEUP)
	-- 将第二只灵摆怪兽以表侧表示加入特殊召唤处理流程（特殊召唤Step）。
	Duel.SpecialSummonStep(tc2,0,tp,tp,false,false,POS_FACEUP)
	-- 那2张卡效果无效特殊召唤
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc1:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	e2:SetValue(RESET_TURN_SET)
	tc1:RegisterEffect(e2)
	local e3=e1:Clone()
	tc2:RegisterEffect(e3)
	local e4=e2:Clone()
	tc2:RegisterEffect(e4)
	-- 结束连续特殊召唤处理，正式完成2只怪兽的特殊召唤。
	Duel.SpecialSummonComplete()
	-- 立即刷新场地状态，确保后续超量召唤判断读到最新的怪兽区域信息。
	Duel.AdjustAll()
	if g:FilterCount(Card.IsLocation,nil,LOCATION_MZONE)<2 then return end
	local e5=nil
	local e6=nil
	if tc1:IsLevelAbove(1) and tc2:IsLevelAbove(1) then
		-- 那个时候，要作为超量素材的1只怪兽的等级可以当作和另1只怪兽相同等级使用。
		e5=Effect.CreateEffect(e:GetHandler())
		e5:SetType(EFFECT_TYPE_SINGLE)
		e5:SetCode(EFFECT_XYZ_LEVEL)
		e5:SetValue(c46005939.xyzlv)
		e5:SetLabel(tc2:GetLevel())
		e5:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc1:RegisterEffect(e5,true)
		-- 只用那2只怪兽为素材把1只超量怪兽超量召唤。那个时候，要作为超量素材的1只怪兽的等级可以当作和另1只怪兽相同等级使用。
		e6=Effect.CreateEffect(e:GetHandler())
		e6:SetType(EFFECT_TYPE_SINGLE)
		e6:SetCode(EFFECT_XYZ_LEVEL)
		e6:SetValue(c46005939.xyzlv)
		e6:SetLabel(tc1:GetLevel())
		e6:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc2:RegisterEffect(e6,true)
	end
	-- 获取额外卡组中能够以g（2只灵摆怪兽）作为素材进行超量召唤的XYZ怪兽卡组。
	local xyzg=Duel.GetMatchingGroup(Card.IsXyzSummonable,tp,LOCATION_EXTRA,0,nil,g,2,2)
	if xyzg:GetCount()>0 then
		-- 向玩家弹出选择提示，要求选择1只要超量召唤的XYZ怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local xyz=xyzg:Select(tp,1,1,nil):GetFirst()
		-- 执行XYZ召唤：用g中的2只怪兽作为素材，将选择的XYZ怪兽超量召唤到场上。
		Duel.XyzSummon(tp,xyz,g)
	else
		if e5 then e5:Reset() end
		if e6 then e5:Reset() end
	end
end
