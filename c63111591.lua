--躯売りのカラス
local s,id,o=GetID()
-- 初始化卡片效果：注册卡片发动、堆墓及后续特召/盖放魔陷的效果
function s.initial_effect(c)
	-- ①：这张卡发动。从卡组上面把最多有双方墓地的陷阱卡种类+1数量（最多4张）的卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 发动准备：检查是否能够从卡组顶将卡送去墓地
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：玩家是否能将卡组顶端的卡送去墓地
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
	-- 设置连锁操作信息：从卡组顶把卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 特召过滤条件：可以特殊召唤的怪兽
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 盖放过滤条件：除同名卡外的可盖放魔法·陷阱卡
function s.setfilter(c,tp)
	return not c:IsCode(id) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
		-- 盖放位置检查：魔陷区域有空位或是场地魔法
		and (Duel.GetLocationCount(tp,LOCATION_SZONE)>0 or c:IsType(TYPE_FIELD))
end
-- 效果处理：宣言堆墓数量，堆墓后选择特召怪兽、盖放魔陷或不处理
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方墓地中所有的陷阱卡
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,TYPE_TRAP)
	local ct=g:GetClassCount(Card.GetCode)+1
	if ct>4 then ct=4 end
	local st={}
	if ct>1 then
		for i=ct,1,-1 do
			-- 检查是否能将i张卡送去墓地
			if Duel.IsPlayerCanDiscardDeck(tp,i) then
				table.insert(st,i)
			end
		end
		-- 提示玩家选择宣言的数字
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
		-- 让玩家选择并宣言要送去墓地的卡片数量
		ct=Duel.AnnounceNumber(tp,table.unpack(st))
	end
	-- 从卡组顶把选定数量的卡送去墓地
	if Duel.DiscardDeck(tp,ct,REASON_EFFECT)~=0 then
		-- 获取本次操作实际送去墓地且受王谷影响的卡片组
		local sg=Duel.GetOperatedGroup():Filter(aux.NecroValleyFilter(Card.IsLocation),nil,LOCATION_GRAVE)
		if sg:GetCount()>0 then
			-- 刷新当前场地与状态信息
			Duel.AdjustAll()
			-- 特召分支检查：怪兽区有空位且送墓卡中包含可特召怪兽
			local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
				and sg:IsExists(s.spfilter,1,nil,e,tp)
			local b2=sg:IsExists(s.setfilter,1,nil,tp)
			-- 提供分支选项供玩家选择：特殊召唤、盖放魔陷或不处理
			local op=aux.SelectFromOptions(tp,
				{b1,aux.Stringid(id,2)},
				{b2,aux.Stringid(id,3)},
				{true,aux.Stringid(id,4)})
			if op==1 then
				-- 中断连锁效果处理（连接堆墓与后续操作）
				Duel.BreakEffect()
				-- 提示玩家选择要特殊召唤的卡
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				local tg=sg:FilterSelect(tp,s.spfilter,1,1,nil,e,tp)
				if tg:GetCount()>0 then
					-- 将选中的怪兽表侧表示特殊召唤
					Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP)
				end
			elseif op==2 then
				-- 中断连锁效果处理（连接堆墓与后续操作）
				Duel.BreakEffect()
				-- 提示玩家选择要盖放的卡
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
				local tg=sg:FilterSelect(tp,s.setfilter,1,1,nil,tp)
				local tc=tg:GetFirst()
				if tc then
					-- 将选中的魔法·陷阱卡盖放到场上
					Duel.SSet(tp,tc)
					if tc:IsType(TYPE_TRAP+TYPE_QUICKPLAY) then
						-- 这个效果盖放的速攻魔法·陷阱卡在盖放的回合也能发动。
						local e1=Effect.CreateEffect(e:GetHandler())
						e1:SetDescription(aux.Stringid(id,5))
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
