--地縛神 スカーレッド・ノヴァ
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：「地缚神」怪兽在场上只能有1只表侧表示存在。
-- ②：自己·对方的主要阶段，把手卡·墓地的这张卡除外才能发动。从自己的手卡·场上（表侧表示）把1只「地缚神」怪兽或「红莲魔龙」送去墓地。那之后，可以从以下效果让1个适用。
-- ●从卡组·额外卡组把1只「地缚」怪兽特殊召唤。
-- ●从额外卡组把1只「真红莲新星龙」当作同调召唤作特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，注册卡名列表、场上只能存在1只「地缚神」怪兽的唯一限制，以及手卡·墓地除外的②效果(e1)
function s.initial_effect(c)
	-- 记录这张卡文本中记述了「红莲魔龙」(70902743)和「真红莲新星龙」(97489701)卡名的事实
	aux.AddCodeList(c,70902743,97489701)
	-- 设置双方怪兽区域表侧表示的「地缚神」怪兽场上只能同时存在1只
	c:SetUniqueOnField(1,1,aux.FilterBoolFunction(Card.IsSetCard,0x1021),LOCATION_MZONE)
	-- 这个卡名的②的效果1回合只能使用1次。②：自己·对方的主要阶段，把手卡·墓地的这张卡除外才能发动。从自己的手卡·场上（表侧表示）把1只「地缚神」怪兽或「红莲魔龙」送去墓地。那之后，可以从以下效果让1个适用。●从卡组·额外卡组把1只「地缚」怪兽特殊召唤。●从额外卡组把1只「真红莲新星龙」当作同调召唤作特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
-- ②效果的Condition函数，限定只能在自己或对方的主要阶段1或主要阶段2发动
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前游戏阶段是否为主要阶段1或主要阶段2
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- ②效果的Cost函数，将手卡·墓地中的这张卡作为代价除外
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	-- 将这张卡作为发动代价以表侧表示除外
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
-- 过滤函数，筛选手卡或场上表侧表示、可送去墓地的「红莲魔龙」或「地缚神」怪兽
function s.tgfilter(c)
	return c:IsFaceupEx() and c:IsAbleToGrave() and (c:IsCode(70902743) or (c:IsSetCard(0x1021) and c:IsType(TYPE_MONSTER)))
end
-- ②效果的Target函数，检查自己手卡·场上存在除这张卡以外满足tgfilter的卡，并设置送去墓地操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检测时，检查自己手卡·场上是否存在除这张卡以外至少1张满足tgfilter条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,e:GetHandler()) end
	-- 设置操作信息，声明将把1张己方怪兽送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_MZONE)
end
-- 过滤函数，筛选卡组可特招的「地缚」怪兽，或额外卡组中可特招的「地缚」怪兽及可当作同调召唤特招的「真红莲新星龙」
function s.spfilter(c,e,tp)
	-- 若卡片在卡组中，检查自己场上是否有可用的主要怪兽区域空格
	return (c:IsLocation(LOCATION_DECK) and Duel.GetMZoneCount(tp)>0
			-- 或者若卡片在额外卡组中，检查自己场上是否有可供其从额外卡组特殊召唤的格子
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
		and ((c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsSetCard(0x21))
			-- 或者卡片为「真红莲新星龙」(97489701)且满足没有必须作为同调素材的限制条件
			or (c:IsCode(97489701) and aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL)
				and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)))
end
-- ②效果的Operation函数，将1只「地缚神」怪兽或「红莲魔龙」送去墓地，之后可选从卡组·额外卡组特招「地缚」怪兽或当作同调召唤特招「真红莲新星龙」
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 向自己发送选择提示信息：“请选择要送去墓地的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让自己在自己手卡·场上选择1张满足tgfilter条件的卡
	local tc=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil):GetFirst()
	-- 以效果将选中的卡tc送去墓地，并确认其已成功送入墓地
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE)
		-- 检查自己卡组·额外卡组是否存在至少1只满足spfilter条件可特殊召唤的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp)
		-- 询问自己是否适用后续的特殊召唤效果（“是否特殊召唤？”）
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否特殊召唤？"
		-- 向自己发送选择提示信息：“请选择要特殊召唤的卡”
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让自己在卡组·额外卡组中选择1只满足spfilter条件的怪兽
		local spc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
		if spc then
			if spc:IsCode(97489701) then
				-- 若选中的是「真红莲新星龙」，则当作同调召唤以表侧表示特殊召唤并检测是否成功
				if Duel.SpecialSummon(spc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)>0 then
					spc:CompleteProcedure()
				end
			else
				-- 若选中的是「地缚」怪兽，则将其以普通特殊召唤方式表侧表示特殊召唤到自己场上
				Duel.SpecialSummon(spc,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
