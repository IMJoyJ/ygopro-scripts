--閻魔の裁き
-- 效果：
-- ①：对方对怪兽的特殊召唤成功时才能发动。那些怪兽破坏。那之后，以下效果可以适用。
-- ●从自己墓地把5只不死族怪兽除外，从手卡·卡组把1只7星以上的不死族怪兽特殊召唤。
function c32120116.initial_effect(c)
	-- 效果原文内容：①：对方对怪兽的特殊召唤成功时才能发动。那些怪兽破坏。那之后，以下效果可以适用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(c32120116.target)
	e1:SetOperation(c32120116.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：过滤出由对方召唤的怪兽
function c32120116.filter(c,tp)
	return c:IsSummonPlayer(tp)
end
-- 效果作用：判断是否满足发动条件并设置破坏对象
function c32120116.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c32120116.filter,1,nil,1-tp) end
	-- 效果作用：将连锁中涉及的怪兽设为处理对象
	Duel.SetTargetCard(eg)
	local g=eg:Filter(c32120116.filter,nil,1-tp)
	-- 效果作用：设置破坏效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果作用：过滤出与效果相关的对方召唤怪兽
function c32120116.filter2(c,e,tp)
	return c:IsSummonPlayer(tp) and c:IsRelateToEffect(e)
end
-- 效果作用：过滤可除外的不死族怪兽
function c32120116.rmfilter(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsAbleToRemove()
end
-- 效果作用：过滤可特殊召唤的7星以上不死族怪兽
function c32120116.spfilter(c,e,tp)
	return c:IsRace(RACE_ZOMBIE) and c:IsLevelAbove(7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果作用：处理阎魔的裁决的主要效果流程
function c32120116.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c32120116.filter2,nil,e,1-tp)
	-- 效果作用：破坏对方特殊召唤的怪兽并判断是否成功
	if #g>0 and Duel.Destroy(g,REASON_EFFECT)>0 then
		-- 效果作用：检索满足条件的墓地不死族怪兽
		local g1=Duel.GetMatchingGroup(aux.NecroValleyFilter(c32120116.rmfilter),tp,LOCATION_GRAVE,0,nil)
		-- 效果作用：检索满足条件的手卡和卡组不死族怪兽
		local g2=Duel.GetMatchingGroup(c32120116.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil,e,tp)
		-- 效果作用：判断是否选择发动特殊召唤效果
		if #g1>4 and #g2>0 and Duel.SelectYesNo(tp,aux.Stringid(32120116,0)) then  --"是否特殊召唤？"
			-- 效果作用：提示玩家选择要除外的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
			local rg=g1:Select(tp,5,5,nil)
			-- 效果作用：将5只不死族怪兽除外
			if Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)==5 then
				-- 效果作用：提示玩家选择要特殊召唤的卡
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				local sg=g2:Select(tp,1,1,nil)
				if #sg>0 then
					-- 效果作用：将符合条件的不死族怪兽特殊召唤
					Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
				end
			end
		end
	end
end
