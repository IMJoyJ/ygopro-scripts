--サモン・ソーサレス
-- 效果：
-- 衍生物以外的相同种族的怪兽2只以上
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡连接召唤的场合才能发动。从手卡把1只怪兽效果无效在作为这张卡所连接区的对方场上守备表示特殊召唤。那之后，可以把和这个效果特殊召唤的怪兽相同种族的1只怪兽从卡组效果无效守备表示特殊召唤。这个效果从卡组特殊召唤过的回合，自己不是原本种族和从卡组特殊召唤的那只怪兽相同的怪兽不能特殊召唤。
function c61665245.initial_effect(c)
	-- 设置连接召唤手续：需要2只以上非衍生物的相同种族的怪兽
	aux.AddLinkProcedure(c,aux.NOT(aux.FilterBoolFunction(Card.IsLinkType,TYPE_TOKEN)),2,99,c61665245.lcheck)
	c:EnableReviveLimit()
	-- ①：这张卡连接召唤的场合才能发动。从手卡把1只怪兽效果无效在作为这张卡所连接区的对方场上守备表示特殊召唤。那之后，可以把和这个效果特殊召唤的怪兽相同种族的1只怪兽从卡组效果无效守备表示特殊召唤。这个效果从卡组特殊召唤过的回合，自己不是原本种族和从卡组特殊召唤的那只怪兽相同的怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(61665245,0))  --"从手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,61665245)
	e1:SetCondition(c61665245.spcon)
	e1:SetTarget(c61665245.sptg)
	e1:SetOperation(c61665245.spop)
	c:RegisterEffect(e1)
end
-- 连接素材的检查函数：用于判断作为连接素材的怪兽种族是否全部相同
function c61665245.lcheck(g)
	-- 检查连接素材怪兽的种族是否全部相同
	return aux.SameValueCheck(g,Card.GetLinkRace)
end
-- 效果发动条件：这张卡是连接召唤成功的场合
function c61665245.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 过滤函数1：筛选手卡中可以守备表示特殊召唤到对方场上指定连接区域的怪兽
function c61665245.spfilter1(c,e,tp,zone)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,1-tp,zone)
end
-- 效果发动时的目标选择与合法性检查
function c61665245.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local zone=e:GetHandler():GetLinkedZone(1-tp)
	-- 检查对方场上该卡连接端所指向的区域是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)>0
		-- 检查自己手卡中是否存在可以特殊召唤到该区域的怪兽
		and Duel.IsExistingMatchingCard(c61665245.spfilter1,tp,LOCATION_HAND,0,1,nil,e,tp,zone) end
	-- 设置特殊召唤的操作信息，表示将从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 过滤函数2：筛选卡组中与特殊召唤的怪兽相同种族、且可以守备表示特殊召唤的怪兽
function c61665245.spfilter2(c,e,tp,rac)
	return c:IsRace(rac) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果处理的核心逻辑：先从手卡特殊召唤1只怪兽到对方场上并无效其效果，之后可选择从卡组特殊召唤同种族怪兽并施加特殊召唤限制
function c61665245.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local zone=c:GetLinkedZone(1-tp)
	-- 检查对方场上该卡连接端所指向的区域是否仍有空位，若无则不处理效果
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从手卡选择1只满足条件的怪兽
	local tc=Duel.SelectMatchingCard(tp,c61665245.spfilter1,tp,LOCATION_HAND,0,1,1,nil,e,tp,zone):GetFirst()
	-- 若成功选出怪兽，则尝试将其守备表示特殊召唤到对方场上的指定连接区域
	if tc and Duel.SpecialSummonStep(tc,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE,zone) then
		-- 效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 效果无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		-- 完成手卡怪兽的特殊召唤流程
		Duel.SpecialSummonComplete()
		-- 获取卡组中与刚刚特殊召唤的怪兽相同种族且可以特殊召唤的怪兽组
		local g=Duel.GetMatchingGroup(c61665245.spfilter2,tp,LOCATION_DECK,0,nil,e,tp,tc:GetRace())
		-- 若卡组有符合条件的怪兽、自己场上有空位，且玩家选择发动后续效果
		if #g>0 and Duel.GetMZoneCount(tp)>0 and Duel.SelectYesNo(tp,aux.Stringid(61665245,1)) then  --"是否从卡组特殊召唤？"
			-- 中断当前效果处理，使前后的特殊召唤处理不视为同时进行
			Duel.BreakEffect()
			-- 提示玩家选择从卡组特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sc=g:Select(tp,1,1,nil):GetFirst()
			-- 尝试将选中的卡组怪兽守备表示特殊召唤到自己场上
			if Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
				-- 效果无效
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				sc:RegisterEffect(e1)
				-- 效果无效
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
				-- 给玩家注册特殊召唤限制的全局效果
				Duel.RegisterEffect(e3,tp)
				-- 完成卡组怪兽的特殊召唤流程
				Duel.SpecialSummonComplete()
			end
		end
	end
end
-- 限制函数：禁止特殊召唤原本种族与从卡组特殊召唤的怪兽不同的怪兽
function c61665245.splimit(e,c)
	return c:GetOriginalRace()&e:GetLabel()==0
end
