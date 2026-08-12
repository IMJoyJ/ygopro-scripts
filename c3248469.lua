--ワナビー！
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：自己·对方的结束阶段，把手卡·场上的这张卡送去墓地才能发动。把没有使用的对方的魔法与陷阱区域数量的卡从自己卡组上面翻开。可以从那之中选1张陷阱卡在自己场上盖放。剩下的卡用喜欢的顺序回到卡组下面。这个效果盖放的卡在下次的结束阶段送去墓地。
local s,id,o=GetID()
-- 创建一个在结束阶段发动的效果，可以发动于手牌或怪兽区域，每回合只能发动一次，需要支付将自己这张卡送去墓地的代价，效果是翻开自己卡组上方的卡并选择陷阱卡盖放，其余卡放回卡组底部。
function s.initial_effect(c)
	-- ①：自己·对方的结束阶段，把手卡·场上的这张卡送去墓地才能发动。把没有使用的对方的魔法与陷阱区域数量的卡从自己卡组上面翻开。可以从那之中选1张陷阱卡在自己场上盖放。剩下的卡用喜欢的顺序回到卡组下面。这个效果盖放的卡在下次的结束阶段送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
-- 支付将自己这张卡送去墓地的代价。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() end
	-- 将自己这张卡送去墓地。
	Duel.SendtoGrave(c,REASON_COST)
end
-- 过滤函数，用于判断卡是否在魔法与陷阱区域（序列小于5）。
function s.xfilter(c)
	return c:GetSequence()<5
end
-- 判断自己卡组上方的卡是否足够翻开以满足盖放陷阱卡的数量要求。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己卡组上方的卡是否足够翻开以满足盖放陷阱卡的数量要求。
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=5-Duel.GetMatchingGroupCount(s.xfilter,tp,0,LOCATION_SZONE,nil) end
end
-- 过滤函数，用于判断卡是否为陷阱卡且可以盖放。
function s.filter(c)
	return c:IsType(TYPE_TRAP) and c:IsSSetable()
end
-- 执行效果的主要操作，包括翻开卡组上方的卡、选择陷阱卡盖放、将剩余卡放回卡组底部。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 计算需要翻开的卡的数量，等于5减去对方未使用的魔法与陷阱区域数量。
	local ct=5-Duel.GetMatchingGroupCount(s.xfilter,tp,0,LOCATION_SZONE,nil)
	-- 如果自己卡组上方的卡不足，则不执行效果。
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<ct then return end
	-- 确认自己卡组最上方的指定数量的卡。
	Duel.ConfirmDecktop(tp,ct)
	-- 获取自己卡组最上方的指定数量的卡组成的组。
	local g=Duel.GetDecktopGroup(tp,ct)
	-- 如果翻开的卡中有陷阱卡且玩家选择盖放，则执行盖放操作。
	if g:FilterCount(s.filter,nil)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否选1张陷阱卡盖放？"
		-- 禁用后续操作的洗牌检测。
		Duel.DisableShuffleCheck()
		-- 提示玩家选择要盖放的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		local sg=g:FilterSelect(tp,s.filter,1,1,nil)
		local tc=sg:GetFirst()
		-- 将选择的陷阱卡盖放到场上。
		Duel.SSet(tp,tc)
		local c=e:GetHandler()
		local fid=c:GetFieldID()
		-- 记录当前回合数。
		local turn=Duel.GetTurnCount()
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 创建一个在下次结束阶段将盖放的卡送去墓地的效果。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCountLimit(1)
		e1:SetLabel(fid,turn)
		e1:SetLabelObject(tc)
		e1:SetCondition(s.tgcon)
		e1:SetOperation(s.tgop)
		e1:SetReset(RESET_PHASE+PHASE_END,2)
		-- 将创建的效果注册给玩家。
		Duel.RegisterEffect(e1,tp)
		g:Sub(sg)
	end
	if #g>0 then
		-- 对剩余的卡进行排序，按玩家选择的顺序放回卡组底部。
		Duel.SortDecktop(tp,tp,#g)
		for i=1,#g do
			-- 获取卡组最上方的一张卡。
			local mg=Duel.GetDecktopGroup(tp,1)
			-- 将卡移动到卡组最底部。
			Duel.MoveSequence(mg:GetFirst(),SEQ_DECKBOTTOM)
		end
	end
end
-- 判断是否满足将盖放的卡送去墓地的条件。
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	local fid,turn=e:GetLabel()
	local tc=e:GetLabelObject()
	-- 判断盖放的卡的标志位是否匹配且不是当前回合。
	return tc:GetFlagEffectLabel(id)==fid and turn~=Duel.GetTurnCount()
end
-- 执行将盖放的卡送去墓地的操作。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将盖放的卡以效果原因送去墓地。
	Duel.SendtoGrave(tc,REASON_EFFECT)
end
