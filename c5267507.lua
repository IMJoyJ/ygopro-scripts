--地縛神 スカーレッド・ノヴァ
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：「地缚神」怪兽在场上只能有1只表侧表示存在。
-- ②：自己·对方的主要阶段，把手卡·墓地的这张卡除外才能发动。从自己的手卡·场上（表侧表示）把1只「地缚神」怪兽或「红莲魔龙」送去墓地。那之后，可以从以下效果让1个适用。
-- ●从卡组·额外卡组把1只「地缚」怪兽特殊召唤。
-- ●从额外卡组把1只「真红莲新星龙」当作同调召唤作特殊召唤。
local s,id,o=GetID()
-- 初始化「地缚神 真红莲新星」(5267507)：记述「红莲魔龙」「真红莲新星龙」卡名、设置①场上「地缚神」表侧唯一限制，并注册②主要阶段除外自身触发的效果
function s.initial_effect(c)
	-- 记录这张卡的效果文本中记载了「红莲魔龙」(70902743)和「真红莲新星龙」(97489701)的卡名
	aux.AddCodeList(c,70902743,97489701)
	-- 设置唯一性限制：双方场上总共只能有1只表侧表示的「地缚神」(0x1021)怪兽存在
	c:SetUniqueOnField(1,1,aux.FilterBoolFunction(Card.IsSetCard,0x1021),LOCATION_MZONE)
	-- 这个卡名的②的效果1回合只能使用1次。②：自己·对方的主要阶段，把手卡·墓地的这张卡除外才能发动。从自己的手卡·场上（表侧表示）把1只「地缚神」怪兽或「红莲魔龙」送去墓地。那之后，可以从以下效果让1个适用。●从卡组·额外卡组把1只「地缚」怪兽特殊召唤。●从额外卡组把1只「真红莲新星龙」当作同调召唤作特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
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
-- 效果②的Condition函数：检查当前是否处于自己或对方的主要阶段1或主要阶段2
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否为主要阶段1(PHASE_MAIN1)或主要阶段2(PHASE_MAIN2)
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 效果②的Cost函数：检查手卡·墓地的这张卡是否可作为代价除外，并在发动时将其表侧除外
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	-- 将手卡·墓地的这张卡作为发动代价以表侧表示除外
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
-- 过滤函数：筛选手卡或场上表侧表示、可送去墓地的「红莲魔龙」(70902743)或「地缚神」(0x1021)怪兽
function s.tgfilter(c)
	return c:IsFaceupEx() and c:IsAbleToGrave() and (c:IsCode(70902743) or (c:IsSetCard(0x1021) and c:IsType(TYPE_MONSTER)))
end
-- 效果②的Target函数：检查手卡·场上是否存在除自身外可送墓的指定怪兽，并设置送去墓地的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检测时确认己方手卡·场上除这张卡外存在至少1只满足条件的「地缚神」怪兽或「红莲魔龙」
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,e:GetHandler()) end
	-- 设置将1只怪兽送去墓地的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_MZONE)
end
-- 过滤函数：筛选卡组·额外卡组中满足格子及召唤条件的可特召「地缚」(0x21)怪兽，或可当作同调召唤特召的「真红莲新星龙」(97489701)
function s.spfilter(c,e,tp)
	-- 若候选怪兽在卡组，检查己方主要怪兽区是否有可用空位
	return (c:IsLocation(LOCATION_DECK) and Duel.GetMZoneCount(tp)>0
			-- 若候选怪兽在额外卡组，检查己方能从额外卡组特召该怪兽的可用空位是否足够
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
		and ((c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsSetCard(0x21))
			-- 或者检查候选怪兽为「真红莲新星龙」(97489701)且未受到强制同调素材效果限制
			or (c:IsCode(97489701) and aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL)
				and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)))
end
-- 效果②的Operation函数：从手卡·场上把1只「地缚神」怪兽或「红莲魔龙」送墓，之后可选择从卡组·额外卡组特召1只「地缚」怪兽或当作同调召唤特召1只「真红莲新星龙」
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 向己方玩家发送选择要送去墓地的怪兽提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从己方手卡或场上表侧表示的卡中选择1只「地缚神」怪兽或「红莲魔龙」
	local tc=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil):GetFirst()
	-- 以效果将选中的怪兽送去墓地，并确认其成功进入墓地
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE)
		-- 检查己方卡组或额外卡组中是否存在至少1只满足条件的「地缚」怪兽或「真红莲新星龙」
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp)
		-- 询问己方玩家是否要适用从卡组·额外卡组特殊召唤怪兽的后续效果
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否特殊召唤？"
		-- 向己方玩家发送选择要特殊召唤的怪兽提示
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从己方卡组或额外卡组中选择1只符合条件的「地缚」怪兽或「真红莲新星龙」
		local spc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
		if spc then
			if spc:IsCode(97489701) then
				-- 若所选为「真红莲新星龙」，则以同调召唤方式将其表侧特殊召唤并完成正规召唤手续
				if Duel.SpecialSummon(spc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)>0 then
					spc:CompleteProcedure()
				end
			else
				-- 若所选为「地缚」怪兽，则将其以表侧表示特殊召唤到己方场上
				Duel.SpecialSummon(spc,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
