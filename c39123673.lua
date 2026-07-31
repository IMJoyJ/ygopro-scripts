--魔力到達
local s,id,o=GetID()
-- 创建并注册魔力到達的发动效果
function s.initial_effect(c)
	-- 魔力到達：支付1个指示物，选择场上1张卡破坏，使该卡的效果无效并破坏
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
-- 判断卡片是否拥有指定指示物
function Auxiliary.HasMentionedCounter(c,counter)
	return c.mentioned_counter and c.mentioned_counter[counter] or false
end
-- 检索满足条件的卡片组，包括未被王家长眠之谷影响且拥有指示物的卡
function s.thfilter(c)
	-- 过滤函数，用于筛选拥有指示物且能加入手牌的卡
	return not c:IsCode(id) and Auxiliary.HasMentionedCounter(c,0x1) and c:IsAbleToHand()
end
-- 设置魔力到達的效果目标，检查是否存在满足条件的卡
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件，即场上存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置连锁操作信息，指定将要处理的卡组为手牌或墓地中的卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 过滤函数，用于筛选满足条件的怪兽卡
function s.cfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x12a) and c:GetOriginalType()&TYPE_MONSTER>0
		and (c:IsType(TYPE_MONSTER) and c:IsLevelAbove(7)
		or not c:IsType(TYPE_MONSTER) and c:GetOriginalLevel()>=7)
end
-- 魔力到達的效果处理函数，执行检索、确认、移除指示物和无效化效果等操作
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡加入手牌
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	-- 判断是否成功将卡加入手牌
	if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 then
		-- 确认对方查看所选卡
		Duel.ConfirmCards(1-tp,g)
		-- 检查己方场上是否存在符合条件的怪兽卡
		if Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
			-- 检查是否能移除己方场上的指示物
			and Duel.IsCanRemoveCounter(tp,1,0,0x1,1,REASON_EFFECT)
			-- 检查对方场上是否存在可被无效化的卡
			and Duel.IsExistingMatchingCard(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil)
			-- 询问玩家是否继续执行后续操作
			and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			-- 获取对方场上可被无效化的卡的数量
			local ct=Duel.GetMatchingGroupCount(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,nil)
			local ctt={}
			local pc=1
			for i=1,ct do
				-- 判断是否可以移除指定数量的指示物并记录可选数量
				if Duel.IsCanRemoveCounter(tp,1,0,0x1,i,REASON_EFFECT) then ctt[i]=nil ctt[pc]=i pc=pc+1 end
			end
			ctt[pc]=nil
			-- 提示玩家选择要移除的指示物数量
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
			-- 让玩家宣言要移除的指示物数量
			local rt=Duel.AnnounceNumber(tp,table.unpack(ctt))
			-- 移除指定数量的指示物
			Duel.RemoveCounter(tp,1,0,0x1,rt,REASON_EFFECT)
			-- 提示玩家选择要无效的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
			-- 选择满足条件的卡进行无效化处理
			local sg=Duel.SelectMatchingCard(tp,aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,rt,rt,nil)
			if sg:GetCount()>0 then
				-- 显示所选卡作为对象的动画效果
				Duel.HintSelection(sg)
				local ng=Group.CreateGroup()
				-- 遍历所选卡组，对每张卡执行无效化和破坏操作
				for tc in aux.Next(sg) do
					if tc:IsCanBeDisabledByEffect(e,false) then
						ng:AddCard(tc)
						-- 使与该卡相关的连锁无效化
						Duel.NegateRelatedChain(tc,RESET_TURN_SET)
						-- 使目标卡的效果无效
						local e1=Effect.CreateEffect(c)
						e1:SetType(EFFECT_TYPE_SINGLE)
						e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
						e1:SetCode(EFFECT_DISABLE)
						e1:SetReset(RESET_EVENT+RESETS_STANDARD)
						tc:RegisterEffect(e1)
						-- 使目标卡的效果无效并重置
						local e2=Effect.CreateEffect(c)
						e2:SetType(EFFECT_TYPE_SINGLE)
						e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
						e2:SetCode(EFFECT_DISABLE_EFFECT)
						e2:SetValue(RESET_TURN_SET)
						e2:SetReset(RESET_EVENT+RESETS_STANDARD)
						tc:RegisterEffect(e2)
						if tc:IsType(TYPE_TRAPMONSTER) then
							-- 使陷阱怪兽的效果无效
							local e3=Effect.CreateEffect(c)
							e3:SetType(EFFECT_TYPE_SINGLE)
							e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
							e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
							e3:SetReset(RESET_EVENT+RESETS_STANDARD)
							tc:RegisterEffect(e3)
						end
					end
				end
				-- 刷新场上卡牌的无效状态
				Duel.AdjustInstantly()
				if ng:GetCount()>0 then
					-- 将满足条件的卡破坏
					Duel.Destroy(ng,REASON_EFFECT)
				end
			end
		end
	end
end
