--電脳堺媛－瑞々
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡在手卡存在的场合，以自己场上1张「电脑堺」卡为对象才能发动。和那张卡种类（怪兽·魔法·陷阱）不同的1张「电脑堺」卡从卡组送去墓地，这张卡特殊召唤。那之后，可以把和作为对象的卡以及送去墓地的卡种类不同的1张「电脑堺媛-瑞瑞」以外的「电脑堺」卡从卡组加入手卡。这个回合，自己若非等级或者阶级是3以上的怪兽则不能特殊召唤。
function c49088914.initial_effect(c)
	-- 效果原文内容：这个卡名的效果1回合只能使用1次。
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
-- 效果作用：检查目标场上「电脑堺」卡是否满足条件（存在种类不同的「电脑堺」卡可从卡组送去墓地）
function c49088914.tfilter(c,tp)
	local type1=c:GetType()&0x7
	-- 效果作用：判断目标卡为表侧表示且其种类对应卡组中存在不同种类的「电脑堺」卡
	return c:IsSetCard(0x14e) and c:IsFaceup() and Duel.IsExistingMatchingCard(c49088914.tgfilter,tp,LOCATION_DECK,0,1,nil,type1)
end
-- 效果作用：过滤出卡组中种类与指定类型不同的「电脑堺」卡并可送去墓地
function c49088914.tgfilter(c,type1)
	return not c:IsType(type1) and c:IsSetCard(0x14e) and c:IsAbleToGrave()
end
-- 效果作用：过滤出卡组中种类与指定类型不同的「电脑堺」卡且不是瑞瑞本身并可加入手牌
function c49088914.thfilter(c,type1)
	return not c:IsType(type1) and c:IsSetCard(0x14e) and not c:IsCode(49088914) and c:IsAbleToHand()
end
-- 效果原文内容：①：这张卡在手卡存在的场合，以自己场上1张「电脑堺」卡为对象才能发动。
function c49088914.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c49088914.tfilter(chkc,tp) end
	-- 效果作用：判断是否满足特殊召唤的场地条件
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 效果作用：判断是否满足选择目标卡的条件
		and Duel.IsExistingTarget(c49088914.tfilter,tp,LOCATION_ONFIELD,0,1,nil,tp) end
	-- 效果作用：提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 效果作用：选择场上符合条件的「电脑堺」卡作为对象
	local g=Duel.SelectTarget(tp,c49088914.tfilter,tp,LOCATION_ONFIELD,0,1,1,nil,tp)
	-- 效果作用：设置操作信息为将一张卡从卡组送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	-- 效果作用：设置操作信息为特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果原文内容：和那张卡种类（怪兽·魔法·陷阱）不同的1张「电脑堺」卡从卡组送去墓地，这张卡特殊召唤。
function c49088914.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前效果处理中的卡和目标卡
	local c,tc=e:GetHandler(),Duel.GetFirstTarget()
	local type1=tc:GetType()&0x7
	if tc:IsRelateToEffect(e) then
		-- 效果作用：提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 效果作用：从卡组中选择一张种类与目标卡不同的「电脑堺」卡
		local g=Duel.SelectMatchingCard(tp,c49088914.tgfilter,tp,LOCATION_DECK,0,1,1,nil,type1)
		local tgc=g:GetFirst()
		-- 效果作用：判断所选卡是否成功送去墓地且自身满足特殊召唤条件
		if tgc and Duel.SendtoGrave(tgc,REASON_EFFECT)~=0 and tgc:IsLocation(LOCATION_GRAVE) and c:IsRelateToEffect(e)
			-- 效果作用：将自身特殊召唤到场上
			and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
			local type1=tgc:GetType()&0x7|type1
			-- 效果作用：获取卡组中种类与目标卡和送去墓地的卡种类都不同的「电脑堺」卡
			local sg=Duel.GetMatchingGroup(c49088914.thfilter,tp,LOCATION_DECK,0,nil,type1)
			-- 效果作用：询问玩家是否要从卡组加入手牌
			if #sg>0 and Duel.SelectYesNo(tp,aux.Stringid(49088914,1)) then  --"是否从卡组把卡加入手卡？"
				-- 效果作用：中断当前连锁处理，使后续效果视为错时点处理
				Duel.BreakEffect()
				-- 效果作用：提示玩家选择要加入手牌的卡
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
				local hg=sg:Select(tp,1,1,nil)
				if #hg>0 then
					-- 效果作用：将所选卡加入手牌
					Duel.SendtoHand(hg,nil,REASON_EFFECT)
					-- 效果作用：确认对方查看所选卡
					Duel.ConfirmCards(1-tp,hg)
				end
			end
		end
	end
	-- 效果原文内容：这个回合，自己若非等级或者阶级是3以上的怪兽则不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c49088914.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 效果作用：注册一个全场效果，禁止玩家在本回合特殊召唤等级或阶级低于3的怪兽
	Duel.RegisterEffect(e1,tp)
end
-- 效果作用：判断目标怪兽是否等级或阶级低于3
function c49088914.splimit(e,c)
	return not (c:IsLevelAbove(3) or c:IsRankAbove(3))
end
