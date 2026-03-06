--ゲイザー・シャーク
-- 效果：
-- 把墓地的这张卡从游戏中除外，选择「间歇泉鲨」以外的自己墓地2只水属性·5星怪兽才能发动。选择的2只怪兽的效果无效特殊召唤，只用那2只为素材把1只水属性的超量怪兽超量召唤。「间歇泉鲨」的效果1回合只能使用1次。
function c23536866.initial_effect(c)
	-- 把墓地的这张卡从游戏中除外，选择「间歇泉鲨」以外的自己墓地2只水属性·5星怪兽才能发动。选择的2只怪兽的效果无效特殊召唤，只用那2只为素材把1只水属性的超量怪兽超量召唤。「间歇泉鲨」的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(23536866,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,23536866)
	-- 将此卡从游戏中除外作为费用
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(c23536866.target)
	e1:SetOperation(c23536866.operation)
	c:RegisterEffect(e1)
end
-- 过滤满足等级为5、属性为水、不是间歇泉鲨、可以成为效果对象、可以特殊召唤的墓地怪兽
function c23536866.filter(c,e,tp)
	return c:IsLevel(5) and c:IsAttribute(ATTRIBUTE_WATER) and not c:IsCode(23536866)
		and c:IsCanBeEffectTarget(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤满足属性为水、可以作为2-2个素材的XYZ召唤、在指定位置有足够召唤空间的额外怪兽
function c23536866.xyzfilter(c,mg,tp)
	-- 属性为水、可以作为2-2个素材的XYZ召唤、在指定位置有足够召唤空间
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsXyzSummonable(mg,2,2) and Duel.GetLocationCountFromEx(tp,tp,mg,c)>0
end
-- 过滤满足在mg中存在满足mfilter2条件的怪兽的怪兽
function c23536866.mfilter1(c,mg,exg)
	return mg:IsExists(c23536866.mfilter2,1,c,c,exg)
end
-- 过滤满足在exg中存在可以作为指定2个怪兽为素材的XYZ召唤的怪兽
function c23536866.mfilter2(c,mc,exg)
	return exg:IsExists(Card.IsXyzSummonable,1,nil,Group.FromCards(c,mc))
end
-- 判断是否满足特殊召唤2只怪兽的条件，包括玩家能特殊召唤2次、未被青眼精灵龙效果影响、场上空位大于1、额外有可召唤的超量怪兽
function c23536866.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取满足filter条件的墓地怪兽组
	local mg=Duel.GetMatchingGroup(c23536866.filter,tp,LOCATION_GRAVE,0,nil,e,tp)
	-- 获取满足xyzfilter条件的额外怪兽组
	local exg=Duel.GetMatchingGroup(c23536866.xyzfilter,tp,LOCATION_EXTRA,0,nil,mg,tp)
	-- 检测玩家是否可以特殊召唤2次
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检测玩家场上是否有2个以上空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and exg:GetCount()>0 end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg1=mg:FilterSelect(tp,c23536866.mfilter1,1,1,nil,mg,exg)
	local tc1=sg1:GetFirst()
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg2=mg:FilterSelect(tp,c23536866.mfilter2,1,1,tc1,tc1,exg)
	sg1:Merge(sg2)
	-- 设置连锁目标为已选择的怪兽组
	Duel.SetTargetCard(sg1)
	-- 设置操作信息为特殊召唤2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg1,2,0,0)
end
-- 过滤满足与效果相关且可以特殊召唤的怪兽
function c23536866.filter2(c,e,tp)
	return c:IsRelateToEffect(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 检测是否被青眼精灵龙效果影响、场上空位是否足够、获取目标怪兽组、判断怪兽数量是否满足2只、特殊召唤2只怪兽、为怪兽添加无效化效果、完成特殊召唤流程、调整场上状态、检测是否满足2只怪兽在场上的条件、获取可召唤的超量怪兽组、提示选择并进行XYZ召唤
function c23536866.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 检测玩家场上是否空位不足2个
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 获取连锁目标怪兽组并过滤满足filter2条件的怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c23536866.filter2,nil,e,tp)
	if g:GetCount()<2 then return end
	local tc1=g:GetFirst()
	local tc2=g:GetNext()
	-- 特殊召唤第一只怪兽
	Duel.SpecialSummonStep(tc1,0,tp,tp,false,false,POS_FACEUP)
	-- 特殊召唤第二只怪兽
	Duel.SpecialSummonStep(tc2,0,tp,tp,false,false,POS_FACEUP)
	-- 使第一只怪兽效果无效
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc1:RegisterEffect(e1)
	local e2=e1:Clone()
	tc2:RegisterEffect(e2)
	-- 使第一只怪兽的效果无效化
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_DISABLE_EFFECT)
	e3:SetValue(RESET_TURN_SET)
	e3:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc1:RegisterEffect(e3)
	local e4=e3:Clone()
	tc2:RegisterEffect(e4)
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
	-- 刷新场上状态
	Duel.AdjustAll()
	if g:FilterCount(Card.IsLocation,nil,LOCATION_MZONE)<2 then return end
	-- 获取满足xyzfilter条件的额外怪兽组
	local xyzg=Duel.GetMatchingGroup(c23536866.xyzfilter,tp,LOCATION_EXTRA,0,nil,g,tp)
	if xyzg:GetCount()>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local xyz=xyzg:Select(tp,1,1,nil):GetFirst()
		-- 进行XYZ召唤
		Duel.XyzSummon(tp,xyz,g)
	end
end
