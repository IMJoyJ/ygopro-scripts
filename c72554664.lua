--烙印の光
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己·对方的场上·墓地1只融合怪兽为对象才能发动。那只怪兽回到额外卡组。那之后，可以选自己墓地的「阿不思的落胤」和对方墓地的怪兽各1只在持有者场上特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- 将「阿不思的落胤」（卡号68468459）放入该卡的关联卡片密码列表中
	aux.AddCodeList(c,68468459)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己·对方的场上·墓地1只融合怪兽为对象才能发动。那只怪兽回到额外卡组。那之后，可以选自己墓地的「阿不思的落胤」和对方墓地的怪兽各1只在持有者场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOEXTRA+CATEGORY_GRAVE_SPSUMMON+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：场上表侧表示或墓地的融合怪兽，且能回到额外卡组
function s.filter(c)
	return c:IsFaceupEx() and c:IsType(TYPE_FUSION) and c:IsAbleToExtra()
end
-- 过滤条件：自己墓地中可以特殊召唤的「阿不思的落胤」
function s.spfilter1(c,e,tp)
	return c:IsCode(68468459)
		-- 判定自己场上是否有空余的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤条件：对方墓地中可以特殊召唤到对方场上的怪兽
function s.spfilter2(c,e,tp)
	-- 判定对方场上是否有空余的怪兽区域（从发动效果的玩家视角来看对方场上的空格）
	return Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
end
-- 效果①的发动准备（Target阶段），检查并选择作为对象的融合怪兽，并设置操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and s.filter(chkc) end
	-- 检查自己或对方的场上或墓地是否存在至少1只满足条件的融合怪兽
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,nil,tp) end
	-- 提示玩家选择要返回额外卡组的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 玩家选择自己或对方场上·墓地的1只融合怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,1,nil,tp)
	-- 设置操作信息，表示此效果包含将选中的1张卡送回额外卡组的操作
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,g,1,0,0)
end
-- 效果①的处理逻辑（Operation阶段），使对象怪兽回到额外卡组，并根据玩家选择决定是否特殊召唤怪兽
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e)
		-- 将对象怪兽送回持有者的额外卡组，并确认是否成功
		and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0
		and tc:IsLocation(LOCATION_EXTRA) then
		-- 获取自己墓地中满足特殊召唤条件且不受「王家长眠之谷」影响的「阿不思的落胤」
		local g1=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter1),tp,LOCATION_GRAVE,0,nil,e,tp)
		-- 获取对方墓地中满足特殊召唤条件且不受「王家长眠之谷」影响的怪兽
		local g2=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter2),tp,0,LOCATION_GRAVE,nil,e,tp)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if not Duel.IsPlayerAffectedByEffect(tp,59822133)
			and #g1>0 and #g2>0
			-- 询问玩家是否选择进行后续的特殊召唤效果
			and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then  --"是否从墓地特殊召唤？"
			-- 中断当前效果处理，使后续的特殊召唤与返回额外卡组不视为同时处理
			Duel.BreakEffect()
			-- 提示玩家选择自己墓地中要特殊召唤的「阿不思的落胤」
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))  --"请选择要特殊召唤的自己的怪兽"
			local sg1=g1:Select(tp,1,1,nil):GetFirst()
			-- 提示玩家选择对方墓地中要特殊召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))  --"请选择要特殊召唤的对方的怪兽"
			local sg2=g2:Select(tp,1,1,nil):GetFirst()
			-- 将选中的「阿不思的落胤」以表侧表示特殊召唤到自己场上（第一步）
			Duel.SpecialSummonStep(sg1,0,tp,tp,false,false,POS_FACEUP)
			-- 将选中的对方怪兽以表侧表示特殊召唤到对方场上（第二步）
			Duel.SpecialSummonStep(sg2,0,tp,1-tp,false,false,POS_FACEUP)
			-- 完成上述所有怪兽的特殊召唤处理
			Duel.SpecialSummonComplete()
		end
	end
end
