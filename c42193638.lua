--ヴァルモニカ・ヴェルサーレ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从以下效果选1个适用。自己的灵摆区域没有「异响鸣」卡存在的场合，适用的效果由对方来选。
-- ●自己回复500基本分。那之后，可以直到「异响鸣」卡出现为止从自己卡组上面翻卡。那个场合，翻开的「异响鸣」卡加入手卡，剩余回到卡组。
-- ●自己受到500伤害。那之后，可以从卡组把「异响鸣的倒水」以外的1张「异响鸣」卡送去墓地。
local s,id,o=GetID()
-- 初始化该卡的效果：创建魔法卡发动效果e1，设置其效果描述、效果分类、发动类型（魔法卡发动）、发动时机（自由时点）、每回合1次发动限制（誓约次数），并注册到卡上。
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从以下效果选1个适用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_RECOVER+CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_DAMAGE+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 定义检索/堆墓的过滤条件：选择卡组中满足「异响鸣」字段、可以被送去墓地、并且不是本卡（异响鸣的倒水）的卡。
function s.filter(c)
	return c:IsSetCard(0x1a3) and c:IsAbleToGrave() and not c:IsCode(id)
end
-- 效果发动后的处理流程：若未指定选项，先根据自己灵摆区是否存在「异响鸣」卡决定由自己还是对方选择效果；选项1为回复500并翻卡检索，选项2为受到500伤害并从卡组选1张「异响鸣」卡送墓。
function s.activate(e,tp,eg,ep,ev,re,r,rp,op)
	if op==nil then
		-- 判断自己灵摆区域是否存在「异响鸣」卡：存在则由自己选择效果，不存在则由对方选择（p为实际进行选择的一方）。
		local p=Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_PZONE,0,1,nil,0x1a3) and tp or 1-tp
		op=aux.SelectFromOptions(p,{true,aux.Stringid(id,1)},{true,aux.Stringid(id,2)})  --"自己回复500基本分/自己受到500伤害"
	end
	if op==1 then
		-- 执行回复500基本分；若回复失败（例如被“回复变成伤害”等效果影响导致实际回复量小于1），则不继续处理翻卡部分。
		if Duel.Recover(tp,500,REASON_EFFECT)<1
			-- 确认卡组中是否存在至少1张可以加入手卡的卡；若不存在则无法执行后续“翻卡加入手卡”的处理。
			or not Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_DECK,0,1,nil)
			-- 询问玩家是否从卡组翻卡；若选择“否”则直接终止当前效果的后续处理。
			or not Duel.SelectYesNo(tp,aux.Stringid(id,3)) then return end  --"是否从卡组翻卡？"
		-- 获取自己卡组中所有「异响鸣」字段的卡（不取对象），用于找出卡组中最靠近顶部的那张「异响鸣」卡。
		local g=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_DECK,0,nil,0x1a3)
		-- 统计自己卡组的当前卡片总数dct，用于计算需要从顶部翻开的张数。
		local dct=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
		local seq=-1
		local hc
		-- 遍历卡组中的所有「异响鸣」卡，根据卡在卡组中的序号（从底部向上递增）找出位置最接近卡组顶部的一张（seq最大）。
		for tc in aux.Next(g) do
			local sq=tc:GetSequence()
			if sq>seq then
				seq=sq
				hc=tc
			end
		end
		-- 中断当前效果处理，使之后的操作视为不同时处理，避免错误时点。
		Duel.BreakEffect()
		if seq>-1 then
			-- 从自己卡组顶部确认翻开dct-seq张卡，即翻到那张最上方的「异响鸣」卡为止。
			Duel.ConfirmDecktop(tp,dct-seq)
			-- 禁用本次操作的自动洗牌检测，因为后续需要手动将剩余翻开的卡放回卡组并洗切。
			Duel.DisableShuffleCheck()
			if hc:IsAbleToHand() then
				-- 将翻到的那张「异响鸣」卡加入持有者的手卡。
				Duel.SendtoHand(hc,nil,REASON_EFFECT)
				-- 让对手确认那张被加入手卡的「异响鸣」卡，以符合公开信息的规则要求。
				Duel.ConfirmCards(1-tp,hc)
				-- 洗切手卡，避免对手通过之前确认的信息得知手卡顺序。
				Duel.ShuffleHand(tp)
			else
				-- 若翻到的「异响鸣」卡因效果不能加入手卡，则改为按规则将其送去墓地（作为无法加入手卡时的替代处理）。
				Duel.SendtoGrave(hc,REASON_RULE)
			end
		else
			-- 当卡组中不存在「异响鸣」卡时，确认整个卡组，表示翻卡翻到了最后仍没有出现「异响鸣」卡。
			Duel.ConfirmDecktop(tp,dct)
		end
		-- 如果翻开的卡不止一张，则将剩余翻开的非「异响鸣」卡洗回卡组并洗切。
		if dct-seq>1 then Duel.ShuffleDeck(tp) end
	-- 执行“自己受到500伤害”分支；若实际伤害大于0，才继续后续从卡组送墓「异响鸣」卡的处理。
	elseif Duel.Damage(tp,500,REASON_EFFECT)>0 then
		-- 获取卡组中满足s.filter条件的所有「异响鸣」卡（字段正确、可送墓、且不是本卡）。
		local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
		-- 若存在符合条件的「异响鸣」卡且玩家选择“是”，则继续选择要送去墓地的卡。
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then  --"是否从卡组把卡送去墓地？"
			-- 弹出选择提示，让玩家从符合条件的卡中选择1张送去墓地。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 中断当前效果，使送墓处理与之前的伤害处理错开时点。
			Duel.BreakEffect()
			-- 将玩家选择的「异响鸣」卡送去墓地。
			Duel.SendtoGrave(sg,REASON_EFFECT)
		end
	end
end
