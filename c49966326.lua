--電脳堺麟－麟々
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡在手卡存在的场合，以自己场上1张「电脑堺」卡为对象才能发动。和那张卡种类（怪兽·魔法·陷阱）不同的1张「电脑堺」卡从卡组送去墓地，这张卡特殊召唤。那之后，可以把和作为对象的卡以及送去墓地的卡种类不同的1张「电脑堺麟-麟麟」以外的「电脑堺」卡从卡组送去墓地。这个回合，自己若非等级或者阶级是3以上的怪兽则不能特殊召唤。
function c49966326.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：这张卡在手卡存在的场合，以自己场上1张「电脑堺」卡为对象才能发动。和那张卡种类（怪兽·魔法·陷阱）不同的1张「电脑堺」卡从卡组送去墓地，这张卡特殊召唤。那之后，可以把和作为对象的卡以及送去墓地的卡种类不同的1张「电脑堺麟-麟麟」以外的「电脑堺」卡从卡组送去墓地。这个回合，自己若非等级或者阶级是3以上的怪兽则不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(49966326,0))  --"从手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE+CATEGORY_DECKDES)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,49966326)
	e1:SetTarget(c49966326.sptg)
	e1:SetOperation(c49966326.spop)
	c:RegisterEffect(e1)
end
-- 定义对象筛选函数：候选卡必须是表侧表示且属于「电脑堺」字段，并且卡组中存在与它种类不同的「电脑堺」卡可供送去墓地。
function c49966326.tfilter(c,tp)
	local type1=c:GetType()&0x7
	-- 对象条件：c属于「电脑堺」字段、表侧表示，且卡组中有符合tgfilter的卡。
	return c:IsSetCard(0x14e) and c:IsFaceup() and Duel.IsExistingMatchingCard(c49966326.tgfilter,tp,LOCATION_DECK,0,1,nil,type1)
end
-- 定义卡组送墓筛选：选择与对象卡种类不同、属于「电脑堺」字段且能送去墓地的卡。
function c49966326.tgfilter(c,type1)
	return not c:IsType(type1) and c:IsSetCard(0x14e) and c:IsAbleToGrave()
end
-- 定义追加送墓筛选：选择与对象卡和第一张送墓卡种类均不同、卡名不是「电脑堺麟-麟麟」、属于「电脑堺」字段且能送去墓地的卡。
function c49966326.tgfilter2(c,type1)
	return not c:IsType(type1) and c:IsSetCard(0x14e) and not c:IsCode(49966326) and c:IsAbleToGrave()
end
-- 效果发动时的目标处理：选择对象并检查发动条件（有怪兽区空格、此卡可特殊召唤、存在符合条件的对象）。
function c49966326.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c49966326.tfilter(chkc,tp) end
	-- 发动条件检查：自己主要怪兽区必须存在可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查场上是否存在1张满足条件的「电脑堺」卡可以成为对象。
		and Duel.IsExistingTarget(c49966326.tfilter,tp,LOCATION_ONFIELD,0,1,nil,tp) end
	-- 给玩家显示“请选择表侧表示的卡”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1张表侧表示且符合条件的「电脑堺」卡作为效果对象。
	local g=Duel.SelectTarget(tp,c49966326.tfilter,tp,LOCATION_ONFIELD,0,1,1,nil,tp)
	-- 设定操作信息：效果处理时将从卡组把1张卡送去墓地（用于连锁判定）。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	-- 设定操作信息：效果处理时要把这张卡特殊召唤（用于连锁判定）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：将对象卡种类不同的1张「电脑堺」卡从卡组送墓，这张卡特殊召唤；成功后可追加把另1张符合条件的「电脑堺」卡从卡组送墓，并附加自肃。
function c49966326.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果持有者（手牌中的这张卡）和发动时选择的对象卡。
	local c,tc=e:GetHandler(),Duel.GetFirstTarget()
	local type1=tc:GetType()&0x7
	if tc:IsRelateToEffect(e) then
		-- 给玩家显示“请选择要送去墓地的卡”的提示消息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 从卡组选择1张与对象卡种类不同的「电脑堺」卡送去墓地。
		local g=Duel.SelectMatchingCard(tp,c49966326.tgfilter,tp,LOCATION_DECK,0,1,1,nil,type1)
		local tgc=g:GetFirst()
		-- 判定：选出的卡片确实成功送去墓地，且这张卡仍与本次效果关联（未被无效或离场）。
		if tgc and Duel.SendtoGrave(tgc,REASON_EFFECT)~=0 and tgc:IsLocation(LOCATION_GRAVE) and c:IsRelateToEffect(e)
			-- 判定：这张卡成功特殊召唤（特殊召唤处理成功才继续后续追加效果）。
			and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
			local type1=tgc:GetType()&0x7|type1
			-- 获取满足追加送墓条件的「电脑堺」卡集合。
			local sg=Duel.GetMatchingGroup(c49966326.tgfilter2,tp,LOCATION_DECK,0,nil,type1)
			-- 若存在可选卡片且玩家选择“是”，则进行追加送墓处理。
			if #sg>0 and Duel.SelectYesNo(tp,aux.Stringid(49966326,1)) then  --"是否从卡组把卡送去墓地？"
				-- 中断当前效果链，使后续追加送墓作为另一次效果处理，以免错过时点。
				Duel.BreakEffect()
				-- 再次提示玩家选择要送去墓地的卡。
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
				local g=sg:Select(tp,1,1,nil)
				if #g>0 then
					-- 将玩家选择的追加卡送去墓地。
					Duel.SendtoGrave(g,REASON_EFFECT)
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
	e1:SetTarget(c49966326.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃效果注册到当前玩家，持续到回合结束。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃判定：等级或阶级均不是3以上的怪兽不能特殊召唤（即非等级或阶级3以上则禁止特召）。
function c49966326.splimit(e,c)
	return not (c:IsLevelAbove(3) or c:IsRankAbove(3))
end
