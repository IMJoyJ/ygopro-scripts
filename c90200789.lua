--忍法 超変化の術
-- 效果：
-- 选择自己场上1只名字带有「忍者」的怪兽和对方场上表侧表示存在的1只怪兽发动。选择的怪兽送去墓地，把1只那个等级合计以下的龙族·恐龙族·海龙族怪兽从自己卡组往自己场上特殊召唤。这张卡从场上离开时，那只怪兽从游戏中除外。
function c90200789.initial_effect(c)
	-- 选择自己场上1只名字带有「忍者」的怪兽和对方场上表侧表示存在的1只怪兽发动。选择的怪兽送去墓地，把1只那个等级合计以下的龙族·恐龙族·海龙族怪兽从自己卡组往自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c90200789.target)
	e1:SetOperation(c90200789.operation)
	c:RegisterEffect(e1)
	-- 这张卡从场上离开时，那只怪兽从游戏中除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetOperation(c90200789.desop)
	c:RegisterEffect(e2)
end
-- 过滤自己场上表侧表示的「忍者」怪兽，且对方场上存在能与其等级合计满足卡组中特召怪兽等级要求的表侧表示怪兽
function c90200789.filter1(c,tp,slv)
	local lv1=c:GetLevel()
	return c:IsFaceup() and c:IsSetCard(0x2b) and lv1>0
		-- 检查对方场上是否存在满足等级合计条件的表侧表示怪兽
		and Duel.IsExistingTarget(c90200789.filter2,tp,0,LOCATION_MZONE,1,nil,lv1,slv)
end
-- 过滤对方场上表侧表示、等级大于0且与自己场上「忍者」怪兽等级合计大于等于卡组中可特召怪兽最低等级的怪兽
function c90200789.filter2(c,lv1,slv)
	local lv2=c:GetLevel()
	return c:IsFaceup() and lv2>0 and lv1+lv2>=slv
end
-- 过滤卡组中可以特殊召唤的、等级在指定数值以下的龙族·恐龙族·海龙族怪兽
function c90200789.spfilter(c,e,tp,lv)
	return c:IsRace(RACE_DRAGON+RACE_DINOSAUR+RACE_SEASERPENT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and (not lv or c:IsLevelBelow(lv))
end
-- 效果发动时的落点与对象选择处理，确认卡组有可特召怪兽，并选择自己场上1只「忍者」怪兽和对方场上1只表侧表示怪兽作为对象
function c90200789.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取卡组中所有满足特殊召唤条件的龙族·恐龙族·海龙族怪兽
	local sg=Duel.GetMatchingGroup(c90200789.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	if chk==0 then
		if sg:GetCount()==0 then return false end
		local mg,mlv=sg:GetMinGroup(Card.GetLevel)
		-- 检查自己场上的怪兽区域是否有空位（因为要送去墓地2只怪兽并特召1只，所以怪兽区域空位数量大于等于-1即可）
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
			-- 检查自己场上是否存在符合条件的「忍者」怪兽作为对象
			and Duel.IsExistingTarget(c90200789.filter1,tp,LOCATION_MZONE,0,1,nil,tp,mlv)
	end
	local mg,mlv=sg:GetMinGroup(Card.GetLevel)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择自己场上1只「忍者」怪兽作为效果对象
	local g1=Duel.SelectTarget(tp,c90200789.filter1,tp,LOCATION_MZONE,0,1,1,nil,tp,mlv)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择对方场上1只表侧表示怪兽作为效果对象
	local g2=Duel.SelectTarget(tp,c90200789.filter2,tp,0,LOCATION_MZONE,1,1,nil,g1:GetFirst():GetLevel(),mlv)
	g1:Merge(g2)
	-- 设置将选择的2只怪兽送去墓地的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g1,2,0,0)
	-- 设置从卡组特殊召唤1只怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，将作为对象的怪兽送去墓地，并根据它们的等级合计从卡组特殊召唤1只龙族·恐龙族·海龙族怪兽，并建立对象关系
function c90200789.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中作为效果对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()==0 then return end
	-- 将仍存在于场上的对象怪兽送去墓地
	Duel.SendtoGrave(tg,REASON_EFFECT)
	-- 检查自己场上是否有可用的怪兽区域，若无则结束效果处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local tc=tg:GetFirst()
	local lv=0
	if tc:IsLocation(LOCATION_GRAVE) then lv=lv+tc:GetLevel() end
	tc=tg:GetNext()
	if tc and tc:IsLocation(LOCATION_GRAVE) then lv=lv+tc:GetLevel() end
	if lv==0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只等级在送去墓地的怪兽等级合计以下的龙族·恐龙族·海龙族怪兽
	local g=Duel.SelectMatchingCard(tp,c90200789.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,lv)
	local tc=g:GetFirst()
	-- 若成功将选定的怪兽以表侧表示特殊召唤
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 中断当前效果处理，使后续的建立对象关系处理不与特殊召唤同时发生（防止错时点）
		Duel.BreakEffect()
		c:SetCardTarget(tc)
	end
	-- 完成特殊召唤的最终处理
	Duel.SpecialSummonComplete()
end
-- 离场时的效果处理函数，当这张卡从场上离开时，将特殊召唤的怪兽除外
function c90200789.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		-- 将特殊召唤的那只怪兽表侧表示除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
