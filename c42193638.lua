--ヴァルモニカ・ヴェルサーレ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从以下效果选1个适用。自己的灵摆区域没有「异响鸣」卡存在的场合，适用的效果由对方来选。
-- ●自己回复500基本分。那之后，可以直到「异响鸣」卡出现为止从自己卡组上面翻卡。那个场合，翻开的「异响鸣」卡加入手卡，剩余回到卡组。
-- ●自己受到500伤害。那之后，可以从卡组把「异响鸣的倒水」以外的1张「异响鸣」卡送去墓地。
local s,id,o=GetID()
-- 创建并注册卡牌效果，设置为自由时点发动，发动次数限制为1次
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_RECOVER+CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_DAMAGE+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 定义过滤函数，用于筛选可以送去墓地的「异响鸣」卡（不包括自身）
function s.filter(c)
	return c:IsSetCard(0x1a3) and c:IsAbleToGrave() and not c:IsCode(id)
end
-- 主效果处理函数，根据选择的选项执行回复LP或受到伤害的效果
function s.activate(e,tp,eg,ep,ev,re,r,rp,op)
	if op==nil then
		-- 判断灵摆区是否存在「异响鸣」卡，若无则由对方选择效果
		local p=Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_PZONE,0,1,nil,0x1a3) and tp or 1-tp
		op=aux.SelectFromOptions(p,{true,aux.Stringid(id,1)},{true,aux.Stringid(id,2)})  --"自己回复500基本分/自己受到500伤害"
	end
	if op==1 then
		-- 使玩家回复500基本分
		if Duel.Recover(tp,500,REASON_EFFECT)<1
			-- 检查卡组中是否存在可以翻开的「异响鸣」卡
			or not Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_DECK,0,1,nil)
			-- 询问玩家是否从卡组翻卡
			or not Duel.SelectYesNo(tp,aux.Stringid(id,3)) then return end  --"是否从卡组翻卡？"
		-- 获取卡组中所有「异响鸣」卡的卡片组
		local g=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_DECK,0,nil,0x1a3)
		-- 获取玩家卡组的总数量
		local dct=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
		local seq=-1
		local hc
		-- 遍历所有「异响鸣」卡，找出序列号最大的那张
		for tc in aux.Next(g) do
			local sq=tc:GetSequence()
			if sq>seq then
				seq=sq
				hc=tc
			end
		end
		-- 中断当前效果处理，防止时点错乱
		Duel.BreakEffect()
		if seq>-1 then
			-- 确认卡组最上方的卡
			Duel.ConfirmDecktop(tp,dct-seq)
			-- 禁用后续操作的洗卡检测
			Duel.DisableShuffleCheck()
			if hc:IsAbleToHand() then
				-- 将符合条件的卡加入手卡
				Duel.SendtoHand(hc,nil,REASON_EFFECT)
				-- 向对方确认翻开的卡
				Duel.ConfirmCards(1-tp,hc)
				-- 洗切玩家手卡
				Duel.ShuffleHand(tp)
			else
				-- 将不符合条件的卡送去墓地
				Duel.SendtoGrave(hc,REASON_RULE)
			end
		else
			-- 确认卡组最上方的卡
			Duel.ConfirmDecktop(tp,dct)
		end
		-- 若翻开的卡数量大于1，则洗切卡组
		if dct-seq>1 then Duel.ShuffleDeck(tp) end
	-- 执行受到500伤害的效果
	elseif Duel.Damage(tp,500,REASON_EFFECT)>0 then
		-- 获取卡组中所有符合条件的「异响鸣」卡
		local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
		-- 检查是否有可选择的卡，并询问玩家是否送去墓地
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then  --"是否从卡组把卡送去墓地？"
			-- 提示玩家选择要送去墓地的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 中断当前效果处理，防止时点错乱
			Duel.BreakEffect()
			-- 将选择的卡送去墓地
			Duel.SendtoGrave(sg,REASON_EFFECT)
		end
	end
end
