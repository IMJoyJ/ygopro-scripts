--ホーンテッド・アンデット
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：从自己或者对方的墓地选1只不死族怪兽除外，把持有和那个等级相同等级的2只「祟灵衍生物」（不死族·暗·攻/守0）在自己场上特殊召唤。
-- ②：这张卡在墓地存在的场合才能发动。选除外的1只自己的不死族怪兽回到卡组，这张卡在自己场上盖放。这个效果盖放的这张卡从场上离开的场合除外。
function c32335697.initial_effect(c)
	-- 效果原文内容：这个卡名的①②的效果1回合只能有1次使用其中任意1个。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(32335697,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_TOKEN+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,32335697)
	e1:SetTarget(c32335697.target)
	e1:SetOperation(c32335697.activate)
	c:RegisterEffect(e1)
	-- 效果原文内容：②：这张卡在墓地存在的场合才能发动。选除外的1只自己的不死族怪兽回到卡组，这张卡在自己场上盖放。这个效果盖放的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(32335697,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1,32335697)
	e2:SetTarget(c32335697.settg)
	e2:SetOperation(c32335697.setop)
	c:RegisterEffect(e2)
end
-- 规则层面作用：定义过滤函数，用于检测满足条件的不死族怪兽（等级≥1且可除外），并判断玩家是否可以特殊召唤对应等级的祟灵衍生物token。
function c32335697.rmfilter(c,tp)
	return c:IsRace(RACE_ZOMBIE) and c:IsLevelAbove(1) and c:IsAbleToRemove()
		-- 规则层面作用：检查玩家是否可以特殊召唤指定等级的祟灵衍生物token。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,32335698,nil,TYPES_TOKEN_MONSTER,0,0,c:GetLevel(),RACE_ZOMBIE,ATTRIBUTE_DARK)
end
-- 规则层面作用：判断是否满足①效果的发动条件，包括场上空位数量、是否存在符合条件的不死族怪兽以及是否受到青眼精灵龙效果影响。
function c32335697.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：检测玩家场上是否有足够的怪兽区域（至少2个）来发动效果。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 规则层面作用：检查玩家墓地是否存在符合条件的不死族怪兽（等级≥1且可除外）。
		and Duel.IsExistingMatchingCard(c32335697.rmfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,tp)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133) end
	-- 规则层面作用：设置操作信息，表示将从墓地除外1张卡。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,PLAYER_ALL,LOCATION_GRAVE)
	-- 规则层面作用：设置操作信息，表示将特殊召唤2只祟灵衍生物token。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
	-- 规则层面作用：设置操作信息，表示将生成2只祟灵衍生物token。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
end
-- 规则层面作用：执行①效果的主要逻辑，选择并除外一张不死族怪兽，然后特殊召唤与该怪兽等级相同的2只祟灵衍生物token。
function c32335697.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=1 or Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 规则层面作用：提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 规则层面作用：从玩家墓地中选择一张符合条件的不死族怪兽。
	local tc=Duel.SelectMatchingCard(tp,c32335697.rmfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,tp):GetFirst()
	-- 规则层面作用：判断所选怪兽是否成功除外。
	if tc and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_REMOVED)
		-- 规则层面作用：检查玩家是否可以特殊召唤对应等级的祟灵衍生物token。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,32335698,nil,TYPES_TOKEN_MONSTER,0,0,tc:GetLevel(),RACE_ZOMBIE,ATTRIBUTE_DARK) then
		for i=1,2 do
			-- 规则层面作用：创建一只祟灵衍生物token。
			local token=Duel.CreateToken(tp,32335698)
			-- 效果原文内容：效果改变token的等级为所选怪兽的等级。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetValue(tc:GetLevel())
			token:RegisterEffect(e1)
			-- 规则层面作用：将创建的token特殊召唤到场上。
			Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 规则层面作用：定义过滤函数，用于检测满足条件的除外的不死族怪兽（正面表示且可送回卡组）。
function c32335697.setfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_ZOMBIE) and c:IsAbleToDeck()
end
-- 规则层面作用：判断是否满足②效果的发动条件，包括该卡是否可盖放以及是否存在符合条件的除外不死族怪兽。
function c32335697.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable()
		-- 规则层面作用：检查玩家除外区域是否存在符合条件的不死族怪兽。
		and Duel.IsExistingMatchingCard(c32335697.setfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 规则层面作用：设置操作信息，表示将该卡从墓地离开。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 规则层面作用：执行②效果的主要逻辑，选择并送回卡组一张除外的不死族怪兽，然后将该卡盖放。
function c32335697.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 规则层面作用：提示玩家选择要送回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 规则层面作用：从玩家除外区域选择一张符合条件的不死族怪兽。
	local g=Duel.SelectMatchingCard(tp,c32335697.setfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	if #g>0 then
		-- 规则层面作用：显示所选卡被选为对象的动画效果。
		Duel.HintSelection(g)
		-- 规则层面作用：将选中的卡送回卡组，并尝试将该卡盖放。
		if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and c:IsRelateToEffect(e) and Duel.SSet(tp,c)~=0 then
			-- 效果原文内容：这个效果盖放的这张卡从场上离开的场合除外。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
			e1:SetValue(LOCATION_REMOVED)
			c:RegisterEffect(e1)
		end
	end
end
