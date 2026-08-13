--躯売りのカラス
-- 效果：
-- ①：把最多有双方墓地的陷阱卡种类数量＋1张的卡从自己卡组上面送去墓地（最多4张）。那之后，可以从以下效果选1个适用。
-- ●从送去墓地的卡之中把1只怪兽特殊召唤。
-- ●从送去墓地的卡之中把「卖骸乌鸦」以外的1张魔法·陷阱卡在自己场上盖放。把速攻魔法·陷阱卡盖放的场合，那张卡在盖放的回合也能发动。
local s,id,o=GetID()
-- 注册本卡的①效果：作为魔法卡的发动（自由时点），设置送墓、特殊召唤与盖放等效果分类，并绑定目标与处理函数
function s.initial_effect(c)
	-- ①：把最多有双方墓地的陷阱卡种类数量＋1张的卡从自己卡组上面送去墓地（最多4张）。那之后，可以从以下效果选1个适用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 效果发动的合法性检测与操作信息设置：确认自己能把卡组上方的卡送去墓地
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测自己能否把卡组顶端至少1张卡送去墓地，不能则不能发动
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
	-- 设置操作信息：预计把自己卡组1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 过滤函数：判断怪兽能否被这个效果特殊召唤
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤函数：筛选「卖骸乌鸦」以外、可以盖放到自己场上的魔法·陷阱卡
function s.setfilter(c,tp)
	return not c:IsCode(id) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
		-- 要求自己的魔法·陷阱区有空位，或者该卡是场地魔法（不占用通常魔陷格）
		and (Duel.GetLocationCount(tp,LOCATION_SZONE)>0 or c:IsType(TYPE_FIELD))
end
-- 效果处理：计算双方墓地陷阱卡种类数＋1（上限4），让玩家宣言送墓数量并从卡组上方送墓，然后从送去墓地的卡中选择适用特殊召唤或盖放效果
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检索双方墓地中的所有陷阱卡
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,TYPE_TRAP)
	local ct=g:GetClassCount(Card.GetCode)+1
	if ct>4 then ct=4 end
	local st={}
	if ct>1 then
		for i=ct,1,-1 do
			-- 检测自己卡组剩余卡数是否足够送墓i张，把可宣言的数量加入选项
			if Duel.IsPlayerCanDiscardDeck(tp,i) then
				table.insert(st,i)
			end
		end
		-- 向玩家显示提示信息：请选择要送去墓地的卡的数量
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))  --"请选择要送去墓地的卡的数量"
		-- 让玩家宣言要送去墓地的卡的数量
		ct=Duel.AnnounceNumber(tp,table.unpack(st))
	end
	-- 把宣言数量的卡从自己卡组上面送去墓地，并确认至少有1张实际送去墓地
	if Duel.DiscardDeck(tp,ct,REASON_EFFECT)~=0 then
		-- 取得实际送去墓地的卡中现在仍在墓地、且不受「王家长眠之谷」影响的卡
		local sg=Duel.GetOperatedGroup():Filter(aux.NecroValleyFilter(Card.IsLocation),nil,LOCATION_GRAVE)
		if sg:GetCount()>0 then
			-- 立刻刷新场地信息，使刚送去墓地的卡的状态可被正确判定
			Duel.AdjustAll()
			-- 检查自己怪兽区是否有空格
			local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
				and sg:IsExists(s.spfilter,1,nil,e,tp)
			local b2=sg:IsExists(s.setfilter,1,nil,tp)
			-- 让玩家从「特殊召唤」「盖放」「不适用」中选择一个效果
			local op=aux.SelectFromOptions(tp,
				{b1,aux.Stringid(id,2)},  --"特殊召唤"
				{b2,aux.Stringid(id,3)},  --"盖放"
				{true,aux.Stringid(id,4)})  --"不选择效果"
			if op==1 then
				-- 中断当前效果处理，使特殊召唤与送去墓地视为不同时处理
				Duel.BreakEffect()
				-- 向玩家显示提示信息：请选择要特殊召唤的卡
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				local tg=sg:FilterSelect(tp,s.spfilter,1,1,nil,e,tp)
				if tg:GetCount()>0 then
					-- 把选择的1只怪兽特殊召唤到自己场上（表侧表示）
					Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP)
				end
			elseif op==2 then
				-- 中断当前效果处理，使盖放与送去墓地视为不同时处理
				Duel.BreakEffect()
				-- 向玩家显示提示信息：请选择要盖放的卡
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
				local tg=sg:FilterSelect(tp,s.setfilter,1,1,nil,tp)
				local tc=tg:GetFirst()
				if tc then
					-- 把选择的1张魔法·陷阱卡在自己场上盖放
					Duel.SSet(tp,tc)
					if tc:IsType(TYPE_TRAP+TYPE_QUICKPLAY) then
						-- 把速攻魔法·陷阱卡盖放的场合，那张卡在盖放的回合也能发动。
						local e1=Effect.CreateEffect(e:GetHandler())
						e1:SetDescription(aux.Stringid(id,5))  --"适用「卖骸乌鸦」的效果来发动"
						e1:SetType(EFFECT_TYPE_SINGLE)
						e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
						if tc:IsType(TYPE_TRAP) then
							e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
						else
							e1:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
						end
						e1:SetReset(RESET_EVENT+RESETS_STANDARD)
						tc:RegisterEffect(e1)
					end
				end
			end
		end
	end
end
