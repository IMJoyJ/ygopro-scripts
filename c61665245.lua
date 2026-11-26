--サモン・ソーサレス
-- 效果：
-- 衍生物以外的相同种族的怪兽2只以上
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡连接召唤的场合才能发动。从手卡把1只怪兽效果无效在作为这张卡所连接区的对方场上守备表示特殊召唤。那之后，可以把和这个效果特殊召唤的怪兽相同种族的1只怪兽从卡组效果无效守备表示特殊召唤。这个效果从卡组特殊召唤过的回合，自己不是原本种族和从卡组特殊召唤的那只怪兽相同的怪兽不能特殊召唤。
function c61665245.initial_effect(c)
	-- 注册连接召唤手续，需要衍生物以外的相同种族怪兽2只以上作为连接素材
	aux.AddLinkProcedure(c,aux.NOT(aux.FilterBoolFunction(Card.IsLinkType,TYPE_TOKEN)),2,99,c61665245.lcheck)
	c:EnableReviveLimit()
	-- 这个卡名的效果1回合只能使用1次。 ①：这张卡连接召唤的场合才能发动。从手卡把1只怪兽效果无效在作为这张卡所连接区的对方场上守备表示特殊召唤。那之后，可以把和这个效果特殊召唤的怪兽相同种族的1只怪兽从卡组效果无效守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(61665245,0))  --"从手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,61665245)
	e1:SetCondition(c61665245.spcon)
	e1:SetTarget(c61665245.sptg)
	e1:SetOperation(c61665245.spop)
	c:RegisterEffect(e1)
end
-- 连接素材组合检查函数，确认所有连接素材怪兽具有相同的种族
function c61665245.lcheck(g)
	-- 检查素材组中所有怪兽的连接种族是否存在共同交集
	return aux.SameValueCheck(g,Card.GetLinkRace)
end
-- 发动条件检查，确认这张卡是以连接召唤方式出场的
function c61665245.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 过滤函数，检查手卡怪兽是否可被特殊召唤到对方场上指定连接区并表侧守备表示放置
function c61665245.spfilter1(c,e,tp,zone)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,1-tp,zone)
end
-- 检查对方场上此卡所连接区是否有空位且自己手卡存在可特殊召唤的怪兽，并设置操作信息
function c61665245.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local zone=e:GetHandler():GetLinkedZone(1-tp)
	-- 检查对方场上位于此卡连接端点的怪兽区是否有可用空位
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)>0
		-- 检查自己手卡是否存在至少1只可特殊召唤至对方连接区的怪兽
		and Duel.IsExistingMatchingCard(c61665245.spfilter1,tp,LOCATION_HAND,0,1,nil,e,tp,zone) end
	-- 设置从自己手卡特殊召唤1只怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 过滤函数，检查是否为卡组中指定种族且可表侧守备表示特殊召唤的怪兽
function c61665245.spfilter2(c,e,tp,rac)
	return c:IsRace(rac) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果处理，从手卡把1只怪兽效果无效守备表示特召至对方连接区，之后可从卡组特召同种族1只怪兽并限制本回合特召种族
function c61665245.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local zone=c:GetLinkedZone(1-tp)
	-- 若对方场上位于此卡连接端点的怪兽区已无可用空位则结束处理
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)<=0 then return end
	-- 提示控制者从手卡选择要特殊召唤到对方场上的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己手卡选择1只可特殊召唤至对方连接区的怪兽
	local tc=Duel.SelectMatchingCard(tp,c61665245.spfilter1,tp,LOCATION_HAND,0,1,1,nil,e,tp,zone):GetFirst()
	-- 以分步方式开始将选中的手卡怪兽表侧守备表示特殊召唤到对方连接区
	if tc and Duel.SpecialSummonStep(tc,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE,zone) then
		-- 从手卡把1只怪兽效果无效在作为这张卡所连接区的对方场上守备表示特殊召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 从手卡把1只怪兽效果无效在作为这张卡所连接区的对方场上守备表示特殊召唤。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		-- 完成手卡怪兽向对方连接区的分步特殊召唤处理
		Duel.SpecialSummonComplete()
		-- 获取自己卡组中与刚特殊召唤怪兽相同种族且可守备表示特殊召唤的怪兽
		local g=Duel.GetMatchingGroup(c61665245.spfilter2,tp,LOCATION_DECK,0,nil,e,tp,tc:GetRace())
		-- 若卡组存在同种族怪兽且自己怪兽区有空位，询问控制者是否从卡组特殊召唤
		if #g>0 and Duel.GetMZoneCount(tp)>0 and Duel.SelectYesNo(tp,aux.Stringid(61665245,1)) then  --"是否从卡组特殊召唤？"
			-- 中断当前效果处理，使后续从卡组特殊召唤与前面的手卡特殊召唤视为不同时处理
			Duel.BreakEffect()
			-- 提示控制者从卡组选择要特殊召唤的同种族怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sc=g:Select(tp,1,1,nil):GetFirst()
			-- 以分步方式开始将选中的卡组怪兽在自己场上表侧守备表示特殊召唤
			if Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
				-- 把和这个效果特殊召唤的怪兽相同种族的1只怪兽从卡组效果无效守备表示特殊召唤。
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				sc:RegisterEffect(e1)
				-- 把和这个效果特殊召唤的怪兽相同种族的1只怪兽从卡组效果无效守备表示特殊召唤。
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				e2:SetValue(RESET_TURN_SET)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				sc:RegisterEffect(e2)
				-- 这个效果从卡组特殊召唤过的回合，自己不是原本种族和从卡组特殊召唤的那只怪兽相同的怪兽不能特殊召唤。
				local e3=Effect.CreateEffect(c)
				e3:SetType(EFFECT_TYPE_FIELD)
				e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
				e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
				e3:SetTargetRange(1,0)
				e3:SetTarget(c61665245.splimit)
				e3:SetLabel(sc:GetOriginalRace())
				e3:SetReset(RESET_PHASE+PHASE_END)
				-- 为自己注册持续至回合结束的特殊召唤原本种族限制效果
				Duel.RegisterEffect(e3,tp)
				-- 完成卡组怪兽向自己场上的分步特殊召唤处理
				Duel.SpecialSummonComplete()
			end
		end
	end
end
-- 限制条件，禁止特殊召唤原本种族与从卡组特召怪兽不同的怪兽
function c61665245.splimit(e,c)
	return c:GetOriginalRace()&e:GetLabel()==0
end
