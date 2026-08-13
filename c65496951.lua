--ヴァルモニカ・ディサルモニア
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：给可以放置响鸣指示物的自己的灵摆区域1张卡放置1个响鸣指示物。那之后，从以下效果选1个适用。
-- ●自己回复500基本分。那之后，可以把「异响鸣的不调和」以外的自己的除外状态的1张「异响鸣」卡加入手卡。
-- ●自己受到500伤害。那之后，可以把「异响鸣的不调和」以外的自己墓地1张「异响鸣」卡加入手卡。
local s,id,o=GetID()
-- 注册魔法卡的发动效果：设置效果描述、效果分类（回复+回手牌+伤害+指示物+墓地行动）、发动类型为魔陷发动、自由时点、同名卡1回合只能发动1次的誓约次数限制，并绑定目标与处理函数
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：给可以放置响鸣指示物的自己的灵摆区域1张卡放置1个响鸣指示物。那之后，从以下效果选1个适用。●自己回复500基本分。那之后，可以把「异响鸣的不调和」以外的自己的除外状态的1张「异响鸣」卡加入手卡。●自己受到500伤害。那之后，可以把「异响鸣的不调和」以外的自己墓地1张「异响鸣」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_RECOVER+CATEGORY_TOHAND+CATEGORY_DAMAGE+CATEGORY_COUNTER+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.mentioned_counter={
	[0x6a]=true,
}
-- 过滤函数：表侧表示且可以放置1个响鸣指示物的卡
function s.pfilter(c)
	return c:IsFaceup() and c:IsCanAddCounter(0x6a,1)
end
-- 目标函数：发动时需确认自己的灵摆区域存在可以放置响鸣指示物的卡，并取得这些卡的组合设置放置指示物的操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检测：若不是卡的发动，或自己的灵摆区域存在至少1张可以放置响鸣指示物的卡，则可以发动
	if chk==0 then return not e:IsHasType(EFFECT_TYPE_ACTIVATE) or Duel.IsExistingMatchingCard(s.pfilter,tp,LOCATION_PZONE,0,1,nil) end
	-- 取得自己灵摆区域所有满足条件的卡（表侧表示且可以放置响鸣指示物）
	local g=Duel.GetMatchingGroup(s.pfilter,tp,LOCATION_PZONE,0,nil)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 设置操作信息：宣言本次连锁将对灵摆区域的卡进行放置指示物的处理
		Duel.SetOperationInfo(0,CATEGORY_COUNTER,g,1,0,0)
	end
end
-- 过滤函数：表侧或里侧除外的「异响鸣」卡中可以加入手牌、且不是「异响鸣的不调和」的卡
function s.filter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x1a3) and c:IsAbleToHand() and not c:IsCode(id)
end
-- 效果处理：先给自己灵摆区域1张可以放置响鸣指示物的卡放置1个响鸣指示物（若放置后指示物达到3个则触发自定义时点），然后从「回复500基本分」和「受到500伤害」中选1个适用，之后可以将对应位置（除外状态或墓地）的1张「异响鸣」卡加入手牌
function s.activate(e,tp,eg,ep,ev,re,r,rp,op)
	if op==nil then
		-- 若自己灵摆区域不存在可以放置响鸣指示物的卡，则中断处理
		if not Duel.IsExistingMatchingCard(s.pfilter,tp,LOCATION_PZONE,0,1,nil) then return end
		-- 提示玩家选择要放置指示物的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)  --"请选择要放置指示物的卡"
		-- 让玩家从自己灵摆区域选择1张可以放置响鸣指示物的卡
		local tc=Duel.SelectMatchingCard(tp,s.pfilter,tp,LOCATION_PZONE,0,1,1,nil):GetFirst()
		tc:AddCounter(0x6a,1)
		if tc:GetCounter(0x6a)==3 then
			-- 当该卡的响鸣指示物达到3个时，触发对应的自定义事件时点
			Duel.RaiseEvent(tc,EVENT_CUSTOM+39210885,e,0,tp,tp,0)
		end
		-- 让玩家从「自己回复500基本分」和「自己受到500伤害」两个选项中选择1个适用
		op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))+1  --"自己回复500基本分/自己受到500伤害"
	end
	if op==1 then
		-- 自己回复500基本分，若未能实际回复则中断后续处理
		if Duel.Recover(tp,500,REASON_EFFECT)<1 then return end
		-- 取得自己除外状态中满足条件的「异响鸣」卡（可以加入手牌且非同名卡）
		local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_REMOVED,0,nil)
		-- 若存在可加入手牌的除外状态的「异响鸣」卡，则询问玩家是否将其回收
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否回收除外状态的卡？"
			-- 提示玩家选择要加入手牌的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 中断当前效果处理，使之后的加入手牌处理与回复视为不同时处理
			Duel.BreakEffect()
			-- 将选择的卡以效果原因加入手牌
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			-- 向对方玩家展示加入手牌的卡
			Duel.ConfirmCards(1-tp,sg)
		end
	-- 否则自己受到500伤害，若未实际受到伤害则不进行后续处理
	elseif Duel.Damage(tp,500,REASON_EFFECT)>0 then
		-- 取得自己墓地中满足条件且不受王家长眠之谷影响的「异响鸣」卡
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter),tp,LOCATION_GRAVE,0,nil)
		-- 若墓地存在可加入手牌的「异响鸣」卡，则询问玩家是否将其回收
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then  --"是否回收墓地的卡？"
			-- 提示玩家选择要加入手牌的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 中断当前效果处理，使之后的加入手牌处理与受到伤害视为不同时处理
			Duel.BreakEffect()
			-- 将选择的卡以效果原因加入手牌
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			-- 向对方玩家展示加入手牌的卡
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end
