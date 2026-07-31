--魔力到達
local s,id,o=GetID()
-- 创建卡片的通常魔法/陷阱效果，注册到卡片上，设置效果描述、分类、类型、触发条件、次数限制、目标和处理函数
function s.initial_effect(c)
	-- 「1回合1次，自己场上有7星以上的「芳香」怪兽表侧表示存在的场合才能发动。从卡组·墓地选1张有「芳香」记述的卡加入手卡。那之后，可以移除1个「芳香」指示物，选择场上1张卡才能发动。那个卡的效果无效并破坏。」
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DESTROY+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.mentioned_counter={
	[0x1]=true,
}
-- 定义辅助函数，检查卡片是否拥有指定的指示物
function Auxiliary.HasMentionedCounter(c,counter)
	return c.mentioned_counter and c.mentioned_counter[counter] or false
end
-- 定义过滤器函数，筛选可以加入手牌的卡：不能是自身卡、必须拥有「芳香」指示物(0x1)、必须能加入手牌
function s.thfilter(c)
	-- 返回满足条件的卡：不是自身、有「芳香」指示物、可加入手牌
	return not c:IsCode(id) and Auxiliary.HasMentionedCounter(c,0x1) and c:IsAbleToHand()
end
-- 效果目标函数，检查是否有符合条件的卡并设置操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上的卡组或墓地是否存在满足thfilter条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息，宣告要执行的卡片加入手牌效果
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 定义场上「芳香」怪兽的过滤器函数：表侧表示、芳香系列、原类型包含怪兽、等级7以上或原等级7以上
function s.cfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x12a) and c:GetOriginalType()&TYPE_MONSTER>0
		and (c:IsType(TYPE_MONSTER) and c:IsLevelAbove(7)
		or not c:IsType(TYPE_MONSTER) and c:GetOriginalLevel()>=7)
end
-- 效果处理函数，选择要加入手牌的卡，若满足条件则执行后续的指示物移除和无效处理
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 发送提示信息让玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组或墓地选择1张满足条件的卡（受王家长眠之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	-- 若成功选择卡并加入手牌，则确认卡片
	if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 then
		-- 确认玩家选择的卡（对方也能看到）
		Duel.ConfirmCards(1-tp,g)
		-- 检查场上是否存在7星以上的「芳香」怪兽
		if Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
			-- 检查玩家是否可以移除1个「芳香」指示物
			and Duel.IsCanRemoveCounter(tp,1,0,0x1,1,REASON_EFFECT)
			-- 检查场上是否存在可以被无效的卡
			and Duel.IsExistingMatchingCard(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil)
			-- 玩家选择是否执行后续的指示物移除和无效效果
			and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			-- 获取场上可以被无效的卡的数量
			local ct=Duel.GetMatchingGroupCount(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,nil)
			local ctt={}
			local pc=1
			for i=1,ct do
				-- 遍历可移除的指示物数量，将可移除的数量存入数组
				if Duel.IsCanRemoveCounter(tp,1,0,0x1,i,REASON_EFFECT) then ctt[i]=nil ctt[pc]=i pc=pc+1 end
			end
			ctt[pc]=nil
			-- 发送提示信息让玩家选择要移除的指示物数量
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
			-- 玩家宣言要移除的指示物数量
			local rt=Duel.AnnounceNumber(tp,table.unpack(ctt))
			-- 执行移除指定数量的「芳香」指示物
			Duel.RemoveCounter(tp,1,0,0x1,rt,REASON_EFFECT)
			-- 发送提示信息让玩家选择要无效的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
			-- 玩家选择要无效的卡（数量与宣言的指示物数量相同）
			local sg=Duel.SelectMatchingCard(tp,aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,rt,rt,nil)
			if sg:GetCount()>0 then
				-- 显示被选中的卡片的动画效果
				Duel.HintSelection(sg)
				local ng=Group.CreateGroup()
				-- 遍历所有被选中的要无效的卡
				for tc in aux.Next(sg) do
					if tc:IsCanBeDisabledByEffect(e,false) then
						ng:AddCard(tc)
						-- 使与该卡相关的连锁无效化，重置为回合开始时状态
						Duel.NegateRelatedChain(tc,RESET_TURN_SET)
						-- 创建并注册使目标怪兽效果无效的怪兽效果
						local e1=Effect.CreateEffect(c)
						e1:SetType(EFFECT_TYPE_SINGLE)
						e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
						e1:SetCode(EFFECT_DISABLE)
						e1:SetReset(RESET_EVENT+RESETS_STANDARD)
						tc:RegisterEffect(e1)
						-- 创建并注册使目标怪兽的怪兽效果无效的永续效果
						local e2=Effect.CreateEffect(c)
						e2:SetType(EFFECT_TYPE_SINGLE)
						e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
						e2:SetCode(EFFECT_DISABLE_EFFECT)
						e2:SetValue(RESET_TURN_SET)
						e2:SetReset(RESET_EVENT+RESETS_STANDARD)
						tc:RegisterEffect(e2)
						if tc:IsType(TYPE_TRAPMONSTER) then
							-- 创建并注册使目标陷阱怪兽效果无效的永续效果
							local e3=Effect.CreateEffect(c)
							e3:SetType(EFFECT_TYPE_SINGLE)
							e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
							e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
							e3:SetReset(RESET_EVENT+RESETS_STANDARD)
							tc:RegisterEffect(e3)
						end
					end
				end
				-- 立即刷新场上所有卡的无效状态
				Duel.AdjustInstantly()
				if ng:GetCount()>0 then
					-- 将所有被无效的卡破坏
					Duel.Destroy(ng,REASON_EFFECT)
				end
			end
		end
	end
end
