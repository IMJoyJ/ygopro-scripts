--先史遺産石紋
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己·对方的主要阶段，以自己的场上·墓地1张超量怪兽卡为对象才能发动。从自己的手卡·卡组·墓地选持有比那张怪兽卡的阶级数值高1的等级的2只「先史遗产」怪兽效果无效特殊召唤，只用那2只为素材把1只「先史遗产」超量怪兽超量召唤。
function c50797682.initial_effect(c)
	-- 效果初始化，设置为发动时点，可取对象，可自由连锁，限制每回合只能发动一次
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCountLimit(1,50797682+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c50797682.condition)
	e1:SetTarget(c50797682.target)
	e1:SetOperation(c50797682.activate)
	c:RegisterEffect(e1)
end
-- 效果发动条件：当前阶段为自己的主要阶段1或主要阶段2
function c50797682.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段
	local ph=Duel.GetCurrentPhase()
	return (ph==PHASE_MAIN1 or ph==PHASE_MAIN2)
end
-- 目标过滤器：检查对象是否为超量怪兽且其等级之上1的「先史遗产」怪兽在手牌/卡组/墓地存在，且额外卡组有符合条件的超量怪兽可召唤
function c50797682.tgfilter(c,e,tp)
	if c:GetOriginalType()&TYPE_XYZ==0 or c:IsFacedown() then return false end
	-- 获取满足等级要求的「先史遗产」怪兽组（手牌/卡组/墓地）
	local mg=Duel.GetMatchingGroup(c50797682.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp,c:GetRank())
	-- 检查是否存在满足条件的超量怪兽可用于召唤
	return Duel.IsExistingMatchingCard(c50797682.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg)
end
-- 特殊召唤过滤器：检查是否为「先史遗产」且等级等于目标怪兽阶级+1，可特殊召唤
function c50797682.spfilter(c,e,tp,rk)
	return c:IsLevel(rk+1) and c:IsSetCard(0x70) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 超量召唤过滤器：检查是否为「先史遗产」超量怪兽，且可用mg作为素材进行2-2的超量召唤
function c50797682.xyzfilter(c,e,tp,mg)
	return c:IsSetCard(0x70) and c:IsXyzSummonable(mg,2,2) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
-- 选择素材过滤器1：检查mg中是否存在满足条件的卡，使得与另一张卡组合后能用于超量召唤
function c50797682.mfilter1(c,mg,exg)
	return mg:IsExists(c50797682.mfilter2,1,c,c,exg)
end
-- 选择素材过滤器2：检查exg中是否存在可使用c和mc作为素材的超量怪兽
function c50797682.mfilter2(c,mc,exg)
	return exg:IsExists(Card.IsXyzSummonable,1,nil,Group.FromCards(c,mc))
end
-- 效果目标设定：检查是否满足特殊召唤数量、青眼精灵龙限制、场上空位及存在有效目标
function c50797682.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_ONFIELD+LOCATION_GRAVE) and c50797682.tgfilter(chkc,e,tp) end
	-- 检测玩家是否可以特殊召唤2只怪兽
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检测玩家场上是否有至少2个空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检测是否存在满足条件的目标怪兽（场上或墓地）
		and Duel.IsExistingTarget(c50797682.tgfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择目标怪兽（场上或墓地的超量怪兽）
	Duel.SelectTarget(tp,c50797682.tgfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：准备特殊召唤2只「先史遗产」怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果发动处理函数：执行特殊召唤和超量召唤流程
function c50797682.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检测玩家是否可以特殊召唤2只怪兽
	if not Duel.IsPlayerCanSpecialSummonCount(tp,2) then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 检测玩家场上是否有至少2个空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	-- 获取满足等级要求的「先史遗产」怪兽组（手牌/卡组/墓地）
	local mg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c50797682.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp,tc:GetRank())
	-- 获取额外卡组中可超量召唤的「先史遗产」超量怪兽组
	local exg=Duel.GetMatchingGroup(c50797682.xyzfilter,tp,LOCATION_EXTRA,0,nil,e,tp,mg)
	-- 提示选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local g1=mg:FilterSelect(tp,c50797682.mfilter1,1,1,nil,mg,exg)
	local tc1=g1:GetFirst()
	-- 提示选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local g2=mg:FilterSelect(tp,c50797682.mfilter2,1,1,tc1,tc1,exg)
	g1:Merge(g2)
	if g1:GetCount()<2 then return end
	local tc=g1:GetFirst()
	while tc do
		-- 将卡特殊召唤至场上
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		-- 效果原文内容：那只怪兽的效果无效
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		tc:RegisterEffect(e2)
		tc=g1:GetNext()
	end
	-- 完成所有特殊召唤步骤
	Duel.SpecialSummonComplete()
	-- 刷新场上信息
	Duel.AdjustAll()
	if g1:FilterCount(Card.IsLocation,nil,LOCATION_MZONE)<2 then return end
	-- 获取额外卡组中可超量召唤的「先史遗产」超量怪兽组
	local xyzg=Duel.GetMatchingGroup(c50797682.xyzfilter,tp,LOCATION_EXTRA,0,nil,e,tp,g1)
	if #xyzg>0 then
		-- 提示选择要特殊召唤的超量怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local xyz=xyzg:Select(tp,1,1,nil):GetFirst()
		-- 执行超量召唤
		Duel.XyzSummon(tp,xyz,g1)
	end
end
