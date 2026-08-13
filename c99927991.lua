--魔救の奇縁
-- 效果：
-- ①：把自己场上的岩石族怪兽数量＋5张从自己卡组上面翻开。可以从那之中选持有翻开的卡数量以下的等级的1只岩石族怪兽加入手卡。剩下的卡用喜欢的顺序回到卡组最下面。这张卡的发动后，直到回合结束时自己不是岩石族怪兽不能特殊召唤。
function c99927991.initial_effect(c)
	-- ①：把自己场上的岩石族怪兽数量＋5张从自己卡组上面翻开。可以从那之中选持有翻开的卡数量以下的等级的1只岩石族怪兽加入手卡。剩下的卡用喜欢的顺序回到卡组最下面。这张卡的发动后，直到回合结束时自己不是岩石族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c99927991.target)
	e1:SetOperation(c99927991.activate)
	c:RegisterEffect(e1)
end
-- 判断怪兽是否为表侧表示的岩石族，用于筛选自己场上存在的岩石族怪兽数量。
function c99927991.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_ROCK)
end
-- 发动时的合法检测：确认卡组足够翻开‘场上岩石族数量+5’张，否则不能发动。
function c99927991.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上所有表侧表示岩石族怪兽，用于计算翻卡数量。
	local g=Duel.GetMatchingGroup(c99927991.filter,tp,LOCATION_MZONE,0,nil)
	-- 卡组数量必须大于‘场上岩石族数量+4’，即至少要有‘岩石族数量+5’张卡才能发动。
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>4+g:GetCount() end
end
-- 判断翻开的卡是否为岩石族、等级不高于翻卡数量且能加入手卡，用于选择加入手卡的怪兽。
function c99927991.thfilter(c,lv)
	return c:IsRace(RACE_ROCK) and c:IsLevelBelow(lv) and c:IsAbleToHand()
end
-- 效果处理：翻开卡组上方‘场上岩石族数量+5’张，选择符合条件的岩石族怪兽加入手卡，其余按任意顺序放回卡组底部，并附加自肃。
function c99927991.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上表侧表示岩石族怪兽，计算最终翻卡张数。
	local tg=Duel.GetMatchingGroup(c99927991.filter,tp,LOCATION_MZONE,0,nil)
	local count=5+tg:GetCount()
	-- 确认卡组剩余数量足够翻开，防止不足。
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=count then
		-- 向自己展示卡组最上方对应数量的卡，作为‘翻开’处理。
		Duel.ConfirmDecktop(tp,count)
		-- 取得卡组最上方对应数量的卡片组，用于后续筛选。
		local g=Duel.GetDecktopGroup(tp,count)
		local ct=g:GetCount()
		-- 如果翻开的卡中存在可加入手卡的岩石族怪兽且玩家选择执行，则进入选卡阶段。
		if ct>0 and g:FilterCount(c99927991.thfilter,nil,ct)>0 and Duel.SelectYesNo(tp,aux.Stringid(99927991,0)) then  --"是否选卡加入手卡？"
			-- 禁用自动洗切卡组检测，因为随后从卡组选卡后需要将剩余卡放回卡组底部，不应触发洗牌。
			Duel.DisableShuffleCheck()
			-- 给出‘选择要加入手牌的卡’的提示信息。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			local sg=g:FilterSelect(tp,c99927991.thfilter,1,1,nil,ct)
			-- 将选中的那张岩石族怪兽以效果原因加入持有者手卡。
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			-- 将加入手卡的卡展示给对方玩家确认。
			Duel.ConfirmCards(1-tp,sg)
			-- 洗切手卡，使对方无法确定刚加入的卡的位置。
			Duel.ShuffleHand(tp)
			ct=g:GetCount()-sg:GetCount()
		end
		if ct>0 then
			-- 让玩家对自己卡组顶部的剩余卡自由排序，以决定放回卡组底部的顺序。
			Duel.SortDecktop(tp,tp,ct)
			for i=1,ct do
				-- 每次循环取当前卡组最上方的一张卡。
				local mg=Duel.GetDecktopGroup(tp,1)
				-- 将这张卡按已排好的顺序移动到卡组最下方，实现‘剩下的卡按喜欢的顺序回到卡组最下面’。
				Duel.MoveSequence(mg:GetFirst(),SEQ_DECKBOTTOM)
			end
		end
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 这张卡的发动后，直到回合结束时自己不是岩石族怪兽不能特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1,0)
		e1:SetTarget(c99927991.splimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将不能特殊召唤非岩石族怪兽的效果注册为场地效果，影响该玩家。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 自肃判定：若怪兽不是岩石族则不能特殊召唤。
function c99927991.splimit(e,c)
	return not c:IsRace(RACE_ROCK)
end
