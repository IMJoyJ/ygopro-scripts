--ヴァルモニカ・ディサルモニア
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：给可以放置响鸣指示物的自己的灵摆区域1张卡放置1个响鸣指示物。那之后，从以下效果选1个适用。
-- ●自己回复500基本分。那之后，可以把「异响鸣的不调和」以外的自己的除外状态的1张「异响鸣」卡加入手卡。
-- ●自己受到500伤害。那之后，可以把「异响鸣的不调和」以外的自己墓地1张「异响鸣」卡加入手卡。
local s,id,o=GetID()
-- 初始化卡片效果：注册①魔法卡发动（放置响鸣指示物及回复LP回收除外/受伤害回收墓地二选一效果）
function s.initial_effect(c)
	-- ①：卡片发动效果：给可以放置响鸣指示物的自己灵摆区域1张卡放置1个响鸣指示物。之后，选择适用回复500基本分并回收除外区「异响鸣」卡，或受到500伤害并回收墓地「异响鸣」卡。
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
-- 指示物放置过滤条件：表侧表示且可添加响鸣指示物（0x6a）
function s.pfilter(c)
	return c:IsFaceup() and c:IsCanAddCounter(0x6a,1)
end
-- ①效果发动准备：检查灵摆区域是否存在可放置响鸣指示物的卡，并设置放置指示物操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：自己灵摆区域是否存在可放置响鸣指示物的卡
	if chk==0 then return not e:IsHasType(EFFECT_TYPE_ACTIVATE) or Duel.IsExistingMatchingCard(s.pfilter,tp,LOCATION_PZONE,0,1,nil) end
	-- 获取自己灵摆区域所有可放置响鸣指示物的卡
	local g=Duel.GetMatchingGroup(s.pfilter,tp,LOCATION_PZONE,0,nil)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 设置连锁操作信息：放置1个响鸣指示物
		Duel.SetOperationInfo(0,CATEGORY_COUNTER,g,1,0,0)
	end
end
-- 卡片回收过滤条件：同名以外的「异响鸣」卡且可加入手牌
function s.filter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x1a3) and c:IsAbleToHand() and not c:IsCode(id)
end
-- ①效果处理：给灵摆区域卡片放置1个响鸣指示物，之后由玩家二选一执行回复/伤害及回收卡片
function s.activate(e,tp,eg,ep,ev,re,r,rp,op)
	if op==nil then
		-- 灵摆区域无有效卡片时终止效果处理
		if not Duel.IsExistingMatchingCard(s.pfilter,tp,LOCATION_PZONE,0,1,nil) then return end
		-- 提示玩家选择要放置指示物的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)  --"请选择要放置指示物的卡"
		-- 从灵摆区域选择1张满足条件的卡
		local tc=Duel.SelectMatchingCard(tp,s.pfilter,tp,LOCATION_PZONE,0,1,1,nil):GetFirst()
		tc:AddCounter(0x6a,1)
		if tc:GetCounter(0x6a)==3 then
			-- 当响鸣指示物达到3个时触发自定义事件（用于异响鸣神灵摆召唤等联动）
			Duel.RaiseEvent(tc,EVENT_CUSTOM+39210885,e,0,tp,tp,0)
		end
		-- 提示玩家选择要适用的效果分支（1:回复LP+回收除外卡 / 2:受到伤害+回收墓地卡）
		op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))+1  --"自己回复500基本分/自己受到500伤害"
	end
	if op==1 then
		-- 执行回复500基本分处理，若回复失败则终止后续处理
		if Duel.Recover(tp,500,REASON_EFFECT)<1 then return end
		-- 获取自己除外区所有满足条件的「异响鸣」卡
		local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_REMOVED,0,nil)
		-- 询问玩家是否将除外的「异响鸣」卡加入手牌
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否回收除外状态的卡？"
			-- 提示玩家选择要加入手牌的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 连接块：分隔回复基本分与加入手牌的处理
			Duel.BreakEffect()
			-- 将选中的除外卡片加入手牌
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			-- 向对方确认加入手牌的卡
			Duel.ConfirmCards(1-tp,sg)
		end
	-- 执行给予自己500伤害处理，若受到伤害则继续后续处理
	elseif Duel.Damage(tp,500,REASON_EFFECT)>0 then
		-- 获取自己墓地所有满足条件的「异响鸣」卡
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter),tp,LOCATION_GRAVE,0,nil)
		-- 询问玩家是否将墓地的「异响鸣」卡加入手牌
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then  --"是否回收墓地的卡？"
			-- 提示玩家选择要加入手牌的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 连接块：分隔受到伤害与加入手牌的处理
			Duel.BreakEffect()
			-- 将选中的墓地卡片加入手牌
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			-- 向对方确认加入手牌的卡
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end
