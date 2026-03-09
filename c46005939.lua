--ペンデュラム・エクシーズ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己的灵摆区域2张卡为对象才能发动。那2张卡效果无效特殊召唤，只用那2只怪兽为素材把1只超量怪兽超量召唤。那个时候，要作为超量素材的1只怪兽的等级可以当作和另1只怪兽相同等级使用。
function c46005939.initial_effect(c)
	-- 创建灵摆超量效果，设置为发动时点，具有取对象属性，限制每回合只能发动一次
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
-- 过滤函数：检查灵摆区域的卡是否可以特殊召唤，并且存在另一张灵摆区域的卡满足条件
function c46005939.spfilter1(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检测灵摆区域是否存在满足spfilter2条件的卡
		and Duel.IsExistingTarget(c46005939.spfilter2,tp,LOCATION_PZONE,0,1,c,e,tp,c)
end
-- 计算超量等级的函数，将当前卡等级加上标签中的等级值
function c46005939.xyzlv(e,c,rc)
	return e:GetHandler():GetLevel()+e:GetLabel()*0x10000
end
-- 过滤函数：检查灵摆区域的卡是否可以特殊召唤，并且能与另一张卡组成超量召唤条件
function c46005939.spfilter2(c,e,tp,mc)
	if not c:IsCanBeSpecialSummoned(e,0,tp,false,false) then return false end
	local e1=nil
	local e2=nil
	if c:IsLevelAbove(1) and mc:IsLevelAbove(1) then
		-- 为第一只特殊召唤的怪兽设置超量等级效果，使其等级可视为另一只怪兽的等级
		e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_XYZ_LEVEL)
		e1:SetValue(c46005939.xyzlv)
		e1:SetLabel(mc:GetLevel())
		c:RegisterEffect(e1,true)
		-- 为第二只特殊召唤的怪兽设置超量等级效果，使其等级可视为第一只怪兽的等级
		e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_XYZ_LEVEL)
		e2:SetValue(c46005939.xyzlv)
		e2:SetLabel(c:GetLevel())
		mc:RegisterEffect(e2,true)
	end
	-- 检测是否能以这两只怪兽为素材进行超量召唤
	local res=Duel.IsExistingMatchingCard(Card.IsXyzSummonable,tp,LOCATION_EXTRA,0,1,nil,Group.FromCards(c,mc),2,2)
	if e1 then e1:Reset() end
	if e2 then e2:Reset() end
	return res
end
-- 判断是否满足发动条件：玩家能特殊召唤2只怪兽，未被青眼精灵龙效果影响，场上空位足够
function c46005939.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检测玩家是否能特殊召唤2只怪兽
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检测玩家场上主怪兽区是否至少有2个空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检测灵摆区域是否存在满足spfilter1条件的卡
		and Duel.IsExistingTarget(c46005939.spfilter1,tp,LOCATION_PZONE,0,1,nil,e,tp) end
	-- 获取玩家灵摆区域的所有卡
	local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	-- 设置当前效果的目标卡为灵摆区域的卡
	Duel.SetTargetCard(g)
	-- 设置操作信息：将灵摆区域的2张卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,0,0)
end
-- 过滤函数：检查卡是否与当前效果相关且可以特殊召唤
function c46005939.spfilter3(c,e,tp)
	return c:IsRelateToEffect(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动效果：检测是否被青眼精灵龙效果影响，判断场上空位是否足够，获取目标卡组，特殊召唤2只怪兽，设置效果无效和无效效果，完成特殊召唤并调整场上状态
function c46005939.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 检测玩家场上主怪兽区是否至少有2个空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 获取连锁中目标卡组并过滤出与效果相关的卡
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c46005939.spfilter3,nil,e,tp)
	if g:GetCount()<2 then return end
	local tc1=g:GetFirst()
	local tc2=g:GetNext()
	-- 将第一只怪兽特殊召唤到场上
	Duel.SpecialSummonStep(tc1,0,tp,tp,false,false,POS_FACEUP)
	-- 将第二只怪兽特殊召唤到场上
	Duel.SpecialSummonStep(tc2,0,tp,tp,false,false,POS_FACEUP)
	-- 为第一只特殊召唤的怪兽设置效果无效效果
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
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
	-- 刷新场上状态
	Duel.AdjustAll()
	if g:FilterCount(Card.IsLocation,nil,LOCATION_MZONE)<2 then return end
	local e5=nil
	local e6=nil
	if tc1:IsLevelAbove(1) and tc2:IsLevelAbove(1) then
		-- 为第一只特殊召唤的怪兽设置超量等级效果，使其等级可视为第二只怪兽的等级
		e5=Effect.CreateEffect(e:GetHandler())
		e5:SetType(EFFECT_TYPE_SINGLE)
		e5:SetCode(EFFECT_XYZ_LEVEL)
		e5:SetValue(c46005939.xyzlv)
		e5:SetLabel(tc2:GetLevel())
		e5:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc1:RegisterEffect(e5,true)
		-- 为第二只特殊召唤的怪兽设置超量等级效果，使其等级可视为第一只怪兽的等级
		e6=Effect.CreateEffect(e:GetHandler())
		e6:SetType(EFFECT_TYPE_SINGLE)
		e6:SetCode(EFFECT_XYZ_LEVEL)
		e6:SetValue(c46005939.xyzlv)
		e6:SetLabel(tc1:GetLevel())
		e6:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc2:RegisterEffect(e6,true)
	end
	-- 获取能以目标卡组为素材进行超量召唤的卡组
	local xyzg=Duel.GetMatchingGroup(Card.IsXyzSummonable,tp,LOCATION_EXTRA,0,nil,g,2,2)
	if xyzg:GetCount()>0 then
		-- 提示玩家选择要特殊召唤的超量怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local xyz=xyzg:Select(tp,1,1,nil):GetFirst()
		-- 使用目标卡组进行超量召唤
		Duel.XyzSummon(tp,xyz,g)
	else
		if e5 then e5:Reset() end
		if e6 then e5:Reset() end
	end
end
