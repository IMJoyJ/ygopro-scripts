--宇宙の法則
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：对方可以从自身的手卡·卡组选1张陷阱卡在自身的魔法与陷阱区域盖放。盖放的场合，自己从卡组把1只「人造人-念力震慑者」特殊召唤。没盖放的场合，自己把1只「人造人-念力震慑者」或者1只有那个卡名记述的怪兽从卡组加入手卡。
function c64659851.initial_effect(c)
	-- 记录此卡效果文本中记述有「人造人-念力震慑者」的卡名
	aux.AddCodeList(c,77585513)
	-- 这个卡名的卡在1回合只能发动1张。①：对方可以从自身的手卡·卡组选1张陷阱卡在自身的魔法与陷阱区域盖放。盖放的场合，自己从卡组把1只「人造人-念力震慑者」特殊召唤。没盖放的场合，自己把1只「人造人-念力震慑者」或者1只有那个卡名记述的怪兽从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(64659851,0))  --"是否把陷阱卡盖放让对方特殊召唤？"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,64659851+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c64659851.target)
	e1:SetOperation(c64659851.activate)
	c:RegisterEffect(e1)
end
-- 过滤卡组中卡名为「人造人-念力震慑者」且可特殊召唤的怪兽
function c64659851.spfilter(c,e,tp)
	return c:IsCode(77585513) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤卡组中可加入手卡的「人造人-念力震慑者」或文本记载有该卡名的怪兽
function c64659851.thfilter(c)
	-- 判断卡片是否为「人造人-念力震慑者」或记载有该卡名的怪兽，且能够加入手卡
	return (c:IsCode(77585513) or aux.IsCodeListed(c,77585513) and c:IsType(TYPE_MONSTER)) and c:IsAbleToHand()
end
-- 发动前确认卡组存在可特召的「人造人-念力震慑者」（且怪兽区有空位），或存在可加入手卡的对应怪兽
function c64659851.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查己方怪兽区有空位且卡组存在可特召的「人造人-念力震慑者」
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(c64659851.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
			-- 或检查己方卡组存在可加入手卡的「人造人-念力震慑者」或其关联怪兽
			or Duel.IsExistingMatchingCard(c64659851.thfilter,tp,LOCATION_DECK,0,1,nil)
	end
end
-- 过滤属于陷阱卡且可盖放至魔法·陷阱区的卡片（忽略场地位置限制以便后续统一判断）
function c64659851.setfilter(c)
	return c:IsType(TYPE_TRAP) and c:IsSSetable(true)
end
-- 效果处理：询问对方是否从手卡·卡组盖放1张陷阱卡，若盖放则己方从卡组特召「人造人-念力震慑者」，否则己方从卡组检索「人造人-念力震慑者」或其关联怪兽
function c64659851.activate(e,tp,eg,ep,ev,re,r,rp)
	local sel=1
	-- 获取对方手卡和卡组中所有可盖放的陷阱卡
	local g=Duel.GetMatchingGroup(c64659851.setfilter,tp,0,LOCATION_HAND+LOCATION_DECK,nil)
	-- 向对方发送是否选择盖放陷阱卡的提示
	Duel.Hint(HINT_SELECTMSG,1-tp,aux.Stringid(64659851,0))  --"是否把陷阱卡盖放让对方特殊召唤？"
	-- 检查对方是否有可盖放的陷阱卡且对方魔法·陷阱区是否有空位
	if g:GetCount()>0 and Duel.GetLocationCount(1-tp,LOCATION_SZONE)>0 then
		-- 条件满足时让对方选择「是」或「否」以决定是否盖放陷阱卡
		sel=Duel.SelectOption(1-tp,1213,1214)
	else
		-- 无卡可盖放或魔陷区已满时，对方仅能选择「否」
		sel=Duel.SelectOption(1-tp,1214)+1
	end
	if sel==0 then
		-- 向对方发送选择要盖放到场上的陷阱卡的提示
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SET)  --"请选择要盖放的卡"
		local sg=g:Select(1-tp,1,1,nil)
		-- 让对方盖放选中的陷阱卡，并在成功盖放且己方怪兽区有空位时继续处理特召
		if Duel.SSet(1-tp,sg)~=0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
			-- 向己方发送从卡组选择要特殊召唤的「人造人-念力震慑者」的提示
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 让己方从卡组选择1只「人造人-念力震慑者」
			local pg=Duel.SelectMatchingCard(tp,c64659851.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
			if pg:GetCount()>0 then
				-- 将选中的「人造人-念力震慑者」以表侧表示特殊召唤到己方场上
				Duel.SpecialSummon(pg,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	else
		-- 向己方发送从卡组选择要加入手卡的怪兽的提示
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让己方从卡组选择1只「人造人-念力震慑者」或记载有其卡名的怪兽
		local hg=Duel.SelectMatchingCard(tp,c64659851.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if hg:GetCount()>0 then
			-- 将选中的怪兽以效果加入己方手卡
			Duel.SendtoHand(hg,nil,REASON_EFFECT)
			-- 向对方玩家展示加入手卡的怪兽进行确认
			Duel.ConfirmCards(1-tp,hg)
		end
	end
end
