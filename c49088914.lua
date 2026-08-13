--電脳堺媛－瑞々
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡在手卡存在的场合，以自己场上1张「电脑堺」卡为对象才能发动。和那张卡种类（怪兽·魔法·陷阱）不同的1张「电脑堺」卡从卡组送去墓地，这张卡特殊召唤。那之后，可以把和作为对象的卡以及送去墓地的卡种类不同的1张「电脑堺媛-瑞瑞」以外的「电脑堺」卡从卡组加入手卡。这个回合，自己若非等级或者阶级是3以上的怪兽则不能特殊召唤。
function c49088914.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：这张卡在手卡存在的场合，以自己场上1张「电脑堺」卡为对象才能发动。和那张卡种类（怪兽·魔法·陷阱）不同的1张「电脑堺」卡从卡组送去墓地，这张卡特殊召唤。那之后，可以把和作为对象的卡以及送去墓地的卡种类不同的1张「电脑堺媛-瑞瑞」以外的「电脑堺」卡从卡组加入手卡。这个回合，自己若非等级或者阶级是3以上的怪兽则不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(49088914,0))  --"从手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,49088914)
	e1:SetTarget(c49088914.sptg)
	e1:SetOperation(c49088914.spop)
	c:RegisterEffect(e1)
end
-- 定义对象候选过滤函数：选择自己场上表侧表示且属于「电脑堺」的卡，同时卡组中必须存在与该卡种类不同的可送墓「电脑堺」卡，以保证取对象效果可能处理。
function c49088914.tfilter(c,tp)
	local type1=c:GetType()&0x7
	-- 具体判定：该卡为表侧表示的「电脑堺」卡，且卡组中存在满足tgfilter（与所选对象种类不同、可送去墓地）的「电脑堺」卡。
	return c:IsSetCard(0x14e) and c:IsFaceup() and Duel.IsExistingMatchingCard(c49088914.tgfilter,tp,LOCATION_DECK,0,1,nil,type1)
end
-- 定义送墓卡过滤函数：选择与对象卡种类（怪兽/魔法/陷阱掩码）不同、属于「电脑堺」且可以送去墓地的卡，用于从卡组挑选送去墓地的「电脑堺」卡。
function c49088914.tgfilter(c,type1)
	return not c:IsType(type1) and c:IsSetCard(0x14e) and c:IsAbleToGrave()
end
-- 定义检索过滤函数：选择与对象卡及已送墓卡种类都不同、属于「电脑堺」、卡名不是「电脑堺媛-瑞瑞」且可以加入手卡的卡，用于从卡组挑选加入手卡的「电脑堺」卡。
function c49088914.thfilter(c,type1)
	return not c:IsType(type1) and c:IsSetCard(0x14e) and not c:IsCode(49088914) and c:IsAbleToHand()
end
-- 发动条件与取对象处理：判定自己主要怪兽区有空位、此卡可以被特殊召唤、场上存在满足tfilter的「电脑堺」卡；满足后让玩家选择1张表侧「电脑堺」卡作为对象。
function c49088914.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c49088914.tfilter(chkc,tp) end
	-- 检查发动条件之一：自己场上主要怪兽区是否有空位，用于后续特殊召唤此卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查发动条件之一：自己场上是否存在满足tfilter的「电脑堺」卡可以作为效果对象（取对象效果，使用IsExistingTarget）。
		and Duel.IsExistingTarget(c49088914.tfilter,tp,LOCATION_ONFIELD,0,1,nil,tp) end
	-- 发出表侧表示卡的选择提示，用于引导玩家选择要取对象的「电脑堺」卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从自己场上将1张满足条件的表侧「电脑堺」卡选择为对象，并自动登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c49088914.tfilter,tp,LOCATION_ONFIELD,0,1,1,nil,tp)
	-- 登记操作信息：将会有1张卡组中的卡被送去墓地（送墓数量为1，位置为卡组），用于后续二速效果连锁的判定。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	-- 登记操作信息：这张卡（瑞瑞）将被特殊召唤，且特殊召唤的对象确定为卡片本身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：若对象卡仍与效果关联，则从卡组选1张与其种类不同的「电脑堺」卡送墓；送墓成功且瑞瑞仍关联时，将瑞瑞特殊召唤；随后可选检索，最后附加自肃。
function c49088914.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果持有者（瑞瑞）和发动时选择的对象卡，分别存储在c和tc中。
	local c,tc=e:GetHandler(),Duel.GetFirstTarget()
	local type1=tc:GetType()&0x7
	if tc:IsRelateToEffect(e) then
		-- 发送选择提示，要求玩家选择要送去墓地的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 从卡组选择1张满足tgfilter（与对象卡种类不同、可送墓的「电脑堺」卡）的卡。
		local g=Duel.SelectMatchingCard(tp,c49088914.tgfilter,tp,LOCATION_DECK,0,1,1,nil,type1)
		local tgc=g:GetFirst()
		-- 判断送墓是否成功且送墓卡确实在墓地，同时瑞瑞仍和效果保留关联；只有满足这些条件才继续处理特殊召唤。
		if tgc and Duel.SendtoGrave(tgc,REASON_EFFECT)~=0 and tgc:IsLocation(LOCATION_GRAVE) and c:IsRelateToEffect(e)
			-- 将瑞瑞以表侧攻击表示特殊召唤到自己场上，并判定特殊召唤是否成功（返回值非0）作为后续检索处理的前提。
			and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
			local type1=tgc:GetType()&0x7|type1
			-- 取得卡组中所有满足thfilter的「电脑堺」卡，作为可选的加入手卡候选集合，其中type1为对象卡和送墓卡种类的并集。
			local sg=Duel.GetMatchingGroup(c49088914.thfilter,tp,LOCATION_DECK,0,nil,type1)
			-- 若存在可加入手卡的候选卡，则询问玩家是否发动从卡组加入手卡的效果。
			if #sg>0 and Duel.SelectYesNo(tp,aux.Stringid(49088914,1)) then  --"是否从卡组把卡加入手卡？"
				-- 调用BreakEffect中断当前效果处理，使后续检索视为另一起处理，避免错过特殊召唤成功后的时点。
				Duel.BreakEffect()
				-- 发送选择提示，要求玩家选择要加入手卡的卡。
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
				local hg=sg:Select(tp,1,1,nil)
				if #hg>0 then
					-- 将玩家选择的卡加入其持有者的手卡（nil表示回持有者手卡），实际完成检索。
					Duel.SendtoHand(hg,nil,REASON_EFFECT)
					-- 向对方玩家展示加入手卡的卡片，以确认检索内容。
					Duel.ConfirmCards(1-tp,hg)
				end
			end
		end
	end
	-- 这个回合，自己若非等级或者阶级是3以上的怪兽则不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c49088914.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将不能特殊召唤等级和阶级都低于3的怪兽的自肃效果，作为影响玩家的场地效果注册到自己方，持续到回合结束。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃判定函数：若怪兽的等级和阶级都低于3（即不是3以上），则禁止该怪兽特殊召唤。
function c49088914.splimit(e,c)
	return not (c:IsLevelAbove(3) or c:IsRankAbove(3))
end
