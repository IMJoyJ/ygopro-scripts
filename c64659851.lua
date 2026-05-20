--宇宙の法則
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：对方可以从自身的手卡·卡组选1张陷阱卡在自身的魔法与陷阱区域盖放。盖放的场合，自己从卡组把1只「人造人-念力震慑者」特殊召唤。没盖放的场合，自己把1只「人造人-念力震慑者」或者1只有那个卡名记述的怪兽从卡组加入手卡。
function c64659851.initial_effect(c)
	-- 在卡片关系中注册「人造人-念力震慑者」的卡号，以便进行相关卡名的检索判定
	aux.AddCodeList(c,77585513)
	-- 这个卡名的卡在1回合只能发动1张。①：对方可以从自身的手卡·卡组选1张陷阱卡在自身的魔法与陷阱区域盖放。盖放的场合，自己从卡组把1只「人造人-念力震慑者」特殊召唤。没盖放的场合，自己把1只「人造人-念力震慑者」或者1只有那个卡名记述的怪兽从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(64659851,0))  --"是否把陷阱卡盖放让对方特殊召唤？"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,64659851+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c64659851.target)
	e1:SetOperation(c64659851.activate)
	c:RegisterEffect(e1)
end
-- 过滤卡组中可以特殊召唤的「人造人-念力震慑者」的条件函数
function c64659851.spfilter(c,e,tp)
	return c:IsCode(77585513) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤卡组中可以加入手牌的「人造人-念力震慑者」或记述了该卡名的怪兽的条件函数
function c64659851.thfilter(c)
	-- 检查卡片是否为「人造人-念力震慑者」或记述了其卡名的怪兽，且能加入手牌
	return (c:IsCode(77585513) or aux.IsCodeListed(c,77585513) and c:IsType(TYPE_MONSTER)) and c:IsAbleToHand()
end
-- 效果发动时的合法性检测（Target函数）
function c64659851.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查自己场上是否有怪兽区域空位，且卡组中是否存在可以特殊召唤的「人造人-念力震慑者」
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(c64659851.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
			-- 或者检查卡组中是否存在可以加入手牌的「人造人-念力震慑者」或记述了该卡名的怪兽
			or Duel.IsExistingMatchingCard(c64659851.thfilter,tp,LOCATION_DECK,0,1,nil)
	end
end
-- 过滤对方手牌或卡组中可以盖放的陷阱卡的条件函数
function c64659851.setfilter(c)
	return c:IsType(TYPE_TRAP) and c:IsSSetable(true)
end
-- 效果处理的执行函数（Activate/Operation函数）
function c64659851.activate(e,tp,eg,ep,ev,re,r,rp)
	local sel=1
	-- 获取对方手牌和卡组中所有满足盖放条件的陷阱卡组
	local g=Duel.GetMatchingGroup(c64659851.setfilter,tp,0,LOCATION_HAND+LOCATION_DECK,nil)
	-- 给对方玩家发送提示信息，询问是否盖放陷阱卡
	Duel.Hint(HINT_SELECTMSG,1-tp,aux.Stringid(64659851,0))  --"是否把陷阱卡盖放让对方特殊召唤？"
	-- 判断对方手牌或卡组中是否存在可盖放的陷阱卡，且对方魔陷区是否有空位
	if g:GetCount()>0 and Duel.GetLocationCount(1-tp,LOCATION_SZONE)>0 then
		-- 让对方玩家选择“是”（盖放）或“否”（不盖放）
		sel=Duel.SelectOption(1-tp,1213,1214)
	else
		-- 若无法盖放，则对方只能选择“否”（不盖放），并将选择结果设为1
		sel=Duel.SelectOption(1-tp,1214)+1
	end
	if sel==0 then
		-- 提示对方玩家选择要盖放的卡片
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SET)  --"请选择要盖放的卡"
		local sg=g:Select(1-tp,1,1,nil)
		-- 如果对方成功盖放了卡片，且自己场上有怪兽区域空位
		if Duel.SSet(1-tp,sg)~=0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
			-- 提示自己选择要特殊召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 让自己从卡组选择1只「人造人-念力震慑者」
			local pg=Duel.SelectMatchingCard(tp,c64659851.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
			if pg:GetCount()>0 then
				-- 将选中的「人造人-念力震慑者」在自己场上表侧表示特殊召唤
				Duel.SpecialSummon(pg,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	else
		-- 提示自己选择要加入手牌的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让自己从卡组选择1只「人造人-念力震慑者」或记述了该卡名的怪兽
		local hg=Duel.SelectMatchingCard(tp,c64659851.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if hg:GetCount()>0 then
			-- 将选中的怪兽加入手牌
			Duel.SendtoHand(hg,nil,REASON_EFFECT)
			-- 给对方玩家确认加入手牌的卡片
			Duel.ConfirmCards(1-tp,hg)
		end
	end
end
