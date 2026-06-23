--マスター・ピース
-- 效果：
-- ①：以自己墓地2只怪兽为对象才能发动。那2只怪兽效果无效特殊召唤，只用那2只为素材把1只光属性「霍普」超量怪兽超量召唤。
function c20285786.initial_effect(c)
	-- 创建效果，设置为发动时点，取对象，可特殊召唤，提示在结束阶段时点
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
-- 过滤满足条件的墓地怪兽，可作为效果对象且可特殊召唤
function c20285786.filter(c,e,tp)
	return c:IsCanBeEffectTarget(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤满足条件的光属性「霍普」超量怪兽，且可用作XYZ素材
function c20285786.xyzfilter(c,mg)
	return c:IsSetCard(0x7f) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsXyzSummonable(mg,2,2)
end
-- 过滤满足条件的墓地怪兽，存在另一只怪兽可配合其进行XYZ召唤
function c20285786.mfilter1(c,mg,exg)
	return mg:IsExists(c20285786.mfilter2,1,c,c,exg)
end
-- 过滤满足条件的额外怪兽，可与指定怪兽配合进行XYZ召唤
function c20285786.mfilter2(c,mc,exg)
	return exg:IsExists(Card.IsXyzSummonable,1,nil,Group.FromCards(c,mc))
end
-- 判断是否满足发动条件，包括玩家可特殊召唤次数、未受青眼精灵龙影响、场上空位足够、存在可召唤的超量怪兽
function c20285786.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取满足条件的墓地怪兽组
	local mg=Duel.GetMatchingGroup(c20285786.filter,tp,LOCATION_GRAVE,0,nil,e,tp)
	-- 获取满足条件的额外怪兽组
	local exg=Duel.GetMatchingGroup(c20285786.xyzfilter,tp,LOCATION_EXTRA,0,nil,mg)
	-- 检测玩家是否可特殊召唤2次
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检测玩家场上主怪兽区是否至少有2个空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and exg:GetCount()>0 end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg1=mg:FilterSelect(tp,c20285786.mfilter1,1,1,nil,mg,exg)
	local tc1=sg1:GetFirst()
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg2=mg:FilterSelect(tp,c20285786.mfilter2,1,1,tc1,tc1,exg)
	sg1:Merge(sg2)
	-- 设置连锁对象为选中的2只怪兽
	Duel.SetTargetCard(sg1)
	-- 设置操作信息为特殊召唤2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg1,2,0,0)
end
-- 过滤满足条件的怪兽，与效果相关且可特殊召唤
function c20285786.filter2(c,e,tp)
	return c:IsRelateToEffect(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动效果，检测是否受青眼精灵龙影响、场上空位是否足够、获取目标怪兽组并特殊召唤，再将怪兽效果无效化，最后进行XYZ召唤
function c20285786.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 检测玩家场上主怪兽区是否至少有2个空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 获取连锁对象卡组并过滤出与效果相关的怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c20285786.filter2,nil,e,tp)
	if g:GetCount()<2 then return end
	local tc=g:GetFirst()
	while tc do
		-- 特殊召唤一只怪兽
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		-- 使目标怪兽效果无效
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
	-- 完成特殊召唤步骤
	Duel.SpecialSummonComplete()
	-- 刷新场上信息
	Duel.AdjustAll()
	if g:FilterCount(Card.IsLocation,nil,LOCATION_MZONE)<2 then return end
	-- 获取满足条件的额外怪兽组
	local xyzg=Duel.GetMatchingGroup(c20285786.xyzfilter,tp,LOCATION_EXTRA,0,nil,g)
	if xyzg:GetCount()>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local xyz=xyzg:Select(tp,1,1,nil):GetFirst()
		-- 进行XYZ召唤
		Duel.XyzSummon(tp,xyz,g)
	end
end
