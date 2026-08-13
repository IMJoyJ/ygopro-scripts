--閻魔の裁き
-- 效果：
-- ①：对方对怪兽的特殊召唤成功时才能发动。那些怪兽破坏。那之后，以下效果可以适用。
-- ●从自己墓地把5只不死族怪兽除外，从手卡·卡组把1只7星以上的不死族怪兽特殊召唤。
function c32120116.initial_effect(c)
	-- ①：对方对怪兽的特殊召唤成功时才能发动。那些怪兽破坏。那之后，以下效果可以适用。●从自己墓地把5只不死族怪兽除外，从手卡·卡组把1只7星以上的不死族怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(c32120116.target)
	e1:SetOperation(c32120116.activate)
	c:RegisterEffect(e1)
end
-- 筛选出由对方玩家特殊召唤成功的怪兽，作为本卡发动条件的判定依据。
function c32120116.filter(c,tp)
	return c:IsSummonPlayer(tp)
end
-- 发动时的目标处理：确认对方有特殊召唤成功的怪兽，将其设为关联对象，并设置破坏那些怪兽的操作信息。
function c32120116.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c32120116.filter,1,nil,1-tp) end
	-- 将本次特殊召唤成功的所有怪兽设置为当前连锁的广义对象，以便效果处理时确认关联。
	Duel.SetTargetCard(eg)
	local g=eg:Filter(c32120116.filter,nil,1-tp)
	-- 设置操作信息，向系统声明本效果将要破坏对方特殊召唤的那些怪兽，供其他卡片效果检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 筛选出仍然与本效果关联且由对方玩家特殊召唤的怪兽，作为实际破坏的对象。
function c32120116.filter2(c,e,tp)
	return c:IsSummonPlayer(tp) and c:IsRelateToEffect(e)
end
-- 筛选自己墓地中满足除外条件的不死族怪兽（种族为不死族且可以被除外）。
function c32120116.rmfilter(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsAbleToRemove()
end
-- 筛选手卡·卡组中可被特殊召唤的7星以上不死族怪兽（满足特殊召唤条件）。
function c32120116.spfilter(c,e,tp)
	return c:IsRace(RACE_ZOMBIE) and c:IsLevelAbove(7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理：先破坏对方特殊召唤成功的关联怪兽，若破坏成功，则由玩家选择是否除外墓地5只不死族并特殊召唤1只7星以上不死族怪兽。
function c32120116.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c32120116.filter2,nil,e,1-tp)
	-- 判断场上仍有对方特殊召唤的关联怪兽且实际破坏数量大于0，若没有则后续效果不处理。
	if #g>0 and Duel.Destroy(g,REASON_EFFECT)>0 then
		-- 获取自己墓地中可除外且不受王家长眠之谷影响的不死族怪兽集合。
		local g1=Duel.GetMatchingGroup(aux.NecroValleyFilter(c32120116.rmfilter),tp,LOCATION_GRAVE,0,nil)
		-- 获取手卡·卡组中可特殊召唤的7星以上不死族怪兽集合。
		local g2=Duel.GetMatchingGroup(c32120116.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil,e,tp)
		-- 若墓地可除外的不死族怪兽不少于5只且特召候选存在，则询问玩家是否发动后续特殊召唤效果。
		if #g1>4 and #g2>0 and Duel.SelectYesNo(tp,aux.Stringid(32120116,0)) then  --"是否特殊召唤？"
			-- 提示玩家选择要除外的卡，进入除外选卡界面。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
			local rg=g1:Select(tp,5,5,nil)
			-- 实际除外所选的不死族怪兽，若成功除外5张则继续执行特殊召唤。
			if Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)==5 then
				-- 提示玩家选择要特殊召唤的卡，进入特召选卡界面。
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				local sg=g2:Select(tp,1,1,nil)
				if #sg>0 then
					-- 将选中的7星以上不死族怪兽以表侧表示特殊召唤到玩家自己场上。
					Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
				end
			end
		end
	end
end
