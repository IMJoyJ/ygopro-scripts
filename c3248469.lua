--ワナビー！
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：自己·对方的结束阶段，把手卡·场上的这张卡送去墓地才能发动。把没有使用的对方的魔法与陷阱区域数量的卡从自己卡组上面翻开。可以从那之中选1张陷阱卡在自己场上盖放。剩下的卡用喜欢的顺序回到卡组下面。这个效果盖放的卡在下次的结束阶段送去墓地。
local s,id,o=GetID()
-- 创建主效果e1并注册给此卡，设置效果描述、分类、类型、发动时机、发动场所（手卡·场上）、1回合1次次数限制、代价、发动条件和处理操作。
function s.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：自己·对方的结束阶段，把手卡·场上的这张卡送去墓地才能发动。把没有使用的对方的魔法与陷阱区域数量的卡从自己卡组上面翻开。可以从那之中选1张陷阱卡在自己场上盖放。剩下的卡用喜欢的顺序回到卡组下面。这个效果盖放的卡在下次的结束阶段送去墓地。
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
-- 代价函数：判断此卡能否作为代价送去墓地；若可以，则将这张卡从手卡或场上送去墓地作为发动代价。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() end
	-- 将这张卡送去墓地，作为效果发动的代价。
	Duel.SendtoGrave(c,REASON_COST)
end
-- 过滤函数：判断卡是否位于魔法与陷阱区域的第1至第5格（seq<5，即排除场地区），用来统计已占用的魔法与陷阱区域数量。
function s.xfilter(c)
	return c:GetSequence()<5
end
-- 目标/发动条件函数：检查自己卡组数量是否足够（≥需要翻开的数量），满足才可发动。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：自己卡组剩余张数不少于对方未使用的魔法与陷阱区域数量（5减去对方魔陷区已使用的格数）。
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=5-Duel.GetMatchingGroupCount(s.xfilter,tp,0,LOCATION_SZONE,nil) end
end
-- 过滤函数：判定卡是否为陷阱卡且可以盖放，用于从翻开的卡中选出可盖放的陷阱卡。
function s.filter(c)
	return c:IsType(TYPE_TRAP) and c:IsSSetable()
end
-- 效果处理：计算翻开数量ct，翻开自己卡组上方ct张；若其中有可盖放的陷阱卡且玩家选择盖放，则选1张盖放到自己场上，并为其注册下次结束阶段送去墓地的效果；剩余翻开的卡由玩家指定顺序放回卡组底端。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 计算翻开的数量：对方未使用的魔法与陷阱区域数量 = 5 - 对方魔陷区已使用的格数（xfilter统计的是非场地魔陷区）。
	local ct=5-Duel.GetMatchingGroupCount(s.xfilter,tp,0,LOCATION_SZONE,nil)
	-- 若自己卡组张数不足ct，则效果不处理。
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<ct then return end
	-- 将玩家自己卡组最上方ct张卡公开给双方确认。
	Duel.ConfirmDecktop(tp,ct)
	-- 获取自己卡组最上方ct张卡作为卡组对象g，用于后续操作。
	local g=Duel.GetDecktopGroup(tp,ct)
	-- 如果翻开的卡中存在可盖放的陷阱卡，且玩家选择‘是否选1张陷阱卡盖放？’，则进入盖放分支。
	if g:FilterCount(s.filter,nil)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否选1张陷阱卡盖放？"
		-- 禁用下一次操作后的自动洗切检查，因为之后要把翻开的卡按顺序放回卡组底端，不应当触发洗牌。
		Duel.DisableShuffleCheck()
		-- 发送选择提示，提示玩家选择要盖放的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		local sg=g:FilterSelect(tp,s.filter,1,1,nil)
		local tc=sg:GetFirst()
		-- 将选中的陷阱卡以里侧表示盖放到自己场上。
		Duel.SSet(tp,tc)
		local c=e:GetHandler()
		local fid=c:GetFieldID()
		-- 记录当前回合数，用于后续判断是否到了‘下次的结束阶段’。
		local turn=Duel.GetTurnCount()
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 剩下的卡用喜欢的顺序回到卡组下面。这个效果盖放的卡在下次的结束阶段送去墓地。
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
		-- 将‘下次结束阶段把那张盖放的卡送去墓地’的持续效果注册到场上。
		Duel.RegisterEffect(e1,tp)
		g:Sub(sg)
	end
	if #g>0 then
		-- 让玩家对剩余的翻开的卡进行排序，决定放回卡组底端的顺序。
		Duel.SortDecktop(tp,tp,#g)
		for i=1,#g do
			-- 依次取出当前卡组最上方1张卡，准备将其移回卡组底端。
			local mg=Duel.GetDecktopGroup(tp,1)
			-- 把该卡移动到卡组最底端，实现‘剩下的卡用喜欢的顺序回到卡组下面’。
			Duel.MoveSequence(mg:GetFirst(),SEQ_DECKBOTTOM)
		end
	end
end
-- 自灭效果的条件函数：确认该盖放的卡仍在场上、标记未被清除，并且此时已到下次结束阶段（不是发动当回合的结束阶段）。
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	local fid,turn=e:GetLabel()
	local tc=e:GetLabelObject()
	-- 通过标记和回合数判断：盖放卡上记录的标记仍对应本次盖放，且当前回合数不同于发动时的回合数（即已到下一次结束阶段）。
	return tc:GetFlagEffectLabel(id)==fid and turn~=Duel.GetTurnCount()
end
-- 自灭效果的处理函数：在满足条件时，将该盖放的卡送去墓地。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将这张因效果盖放的陷阱卡以效果原因送去墓地，实现‘这个效果盖放的卡在下次的结束阶段送去墓地’。
	Duel.SendtoGrave(tc,REASON_EFFECT)
end
