--ヴァルモニカ・ディサルモニア
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：给可以放置响鸣指示物的自己的灵摆区域1张卡放置1个响鸣指示物。那之后，从以下效果选1个适用。
-- ●自己回复500基本分。那之后，可以把「异响鸣的不调和」以外的自己的除外状态的1张「异响鸣」卡加入手卡。
-- ●自己受到500伤害。那之后，可以把「异响鸣的不调和」以外的自己墓地1张「异响鸣」卡加入手卡。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
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
-- 过滤条件：自己灵摆区域表侧表示且可以放置响鸣指示物的卡
function s.pfilter(c)
	return c:IsFaceup() and c:IsCanAddCounter(0x6a,1)
end
-- 效果发动的目标检查与设置函数
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查可行性：若作为卡片发动，则自己灵摆区域必须存在至少1张可以放置响鸣指示物的卡
	if chk==0 then return not e:IsHasType(EFFECT_TYPE_ACTIVATE) or Duel.IsExistingMatchingCard(s.pfilter,tp,LOCATION_PZONE,0,1,nil) end
	-- 获取自己灵摆区域所有可以放置响鸣指示物的卡片组
	local g=Duel.GetMatchingGroup(s.pfilter,tp,LOCATION_PZONE,0,nil)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 设置操作信息：在场上放置1个指示物
		Duel.SetOperationInfo(0,CATEGORY_COUNTER,g,1,0,0)
	end
end
-- 过滤条件：除外状态或墓地中，除「异响鸣的不调和」以外的「异响鸣」系列卡片，且能加入手牌
function s.filter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x1a3) and c:IsAbleToHand() and not c:IsCode(id)
end
-- 效果处理的执行函数
function s.activate(e,tp,eg,ep,ev,re,r,rp,op)
	if op==nil then
		-- 检查自己灵摆区域是否存在可以放置响鸣指示物的卡，若不存在则不处理
		if not Duel.IsExistingMatchingCard(s.pfilter,tp,LOCATION_PZONE,0,1,nil) then return end
		-- 提示玩家选择要放置指示物的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)  --"请选择要放置指示物的卡"
		-- 玩家选择自己灵摆区域1张可以放置响鸣指示物的卡
		local tc=Duel.SelectMatchingCard(tp,s.pfilter,tp,LOCATION_PZONE,0,1,1,nil):GetFirst()
		tc:AddCounter(0x6a,1)
		if tc:GetCounter(0x6a)==3 then
			-- 若该卡放置指示物后达到3个，触发特定的自定义事件（用于检测响鸣指示物满3个的诱发效果）
			Duel.RaiseEvent(tc,EVENT_CUSTOM+39210885,e,0,tp,tp,0)
		end
		-- 让玩家选择适用的效果分支（1：回复500基本分并回收除外卡；2：受到500伤害并回收墓地卡）
		op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))+1  --"自己回复500基本分/自己受到500伤害"
	end
	if op==1 then
		-- 自己回复500基本分，若实际回复量小于1则不进行后续处理
		if Duel.Recover(tp,500,REASON_EFFECT)<1 then return end
		-- 获取自己除外状态的满足条件的「异响鸣」卡片组
		local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_REMOVED,0,nil)
		-- 若存在可回收的除外卡，询问玩家是否将其加入手牌
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否回收除外状态的卡？"
			-- 提示玩家选择要加入手牌的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 中断当前效果处理，使后续的加入手牌处理与回复基本分不视为同时进行
			Duel.BreakEffect()
			-- 将选中的卡加入玩家手牌
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			-- 给对方玩家确认加入手牌的卡
			Duel.ConfirmCards(1-tp,sg)
		end
	-- 否则（选择分支2），自己受到500伤害，若实际受到伤害大于0则进行后续处理
	elseif Duel.Damage(tp,500,REASON_EFFECT)>0 then
		-- 获取自己墓地中满足条件且不受「王家长眠之谷」影响的「异响鸣」卡片组
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter),tp,LOCATION_GRAVE,0,nil)
		-- 若存在可回收的墓地卡，询问玩家是否将其加入手牌
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then  --"是否回收墓地的卡？"
			-- 提示玩家选择要加入手牌的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 中断当前效果处理，使后续的加入手牌处理与受到伤害不视为同时进行
			Duel.BreakEffect()
			-- 将选中的卡加入玩家手牌
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			-- 给对方玩家确认加入手牌的卡
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end
