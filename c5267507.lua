--地縛神 スカーレッド・ノヴァ
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：「地缚神」怪兽在场上只能有1只表侧表示存在。
-- ②：自己·对方的主要阶段，把手卡·墓地的这张卡除外才能发动。从自己的手卡·场上（表侧表示）把1只「地缚神」怪兽或「红莲魔龙」送去墓地。那之后，可以从以下效果让1个适用。
-- ●从卡组·额外卡组把1只「地缚」怪兽特殊召唤。
-- ●从额外卡组把1只「真红莲新星龙」当作同调召唤作特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果：登记记载的卡名、设置「地缚神」怪兽场上只能有1只表侧表示存在的唯一性限制，并注册②效果（手卡·墓地发动的诱发即时特殊召唤效果）
function s.initial_effect(c)
	-- 登记这张卡上记载着「红莲魔龙」（70902743）和「真红莲新星龙」（97489701）的卡名
	aux.AddCodeList(c,70902743,97489701)
	-- 设置场上唯一性限制：「地缚神」怪兽（0x1021系列）在自己场上主要怪兽区只能有1只表侧表示存在
	c:SetUniqueOnField(1,1,aux.FilterBoolFunction(Card.IsSetCard,0x1021),LOCATION_MZONE)
	-- ②：自己·对方的主要阶段，把手卡·墓地的这张卡除外才能发动。从自己的手卡·场上（表侧表示）把1只「地缚神」怪兽或「红莲魔龙」送去墓地。那之后，可以从以下效果让1个适用。●从卡组·额外卡组把1只「地缚」怪兽特殊召唤。●从额外卡组把1只「真红莲新星龙」当作同调召唤作特殊召唤。（这个卡名的②的效果1回合只能使用1次）
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
-- ②效果的发动条件函数：判断当前是否为主要阶段
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前阶段是主要阶段1或主要阶段2时才能发动
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- ②效果的代价函数：检查并支付代价（把手卡·墓地的这张卡除外）
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	-- 作为代价把这张卡以表侧表示除外
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
-- 送去墓地对象的过滤函数：表侧表示（含手卡）、可以送去墓地、且是「红莲魔龙」或「地缚神」怪兽的卡
function s.tgfilter(c)
	return c:IsFaceupEx() and c:IsAbleToGrave() and (c:IsCode(70902743) or (c:IsSetCard(0x1021) and c:IsType(TYPE_MONSTER)))
end
-- ②效果的目标函数：确认存在可送去墓地的对象卡并设置送去墓地的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手卡·场上是否存在至少1张满足条件的卡（可送去墓地的「地缚神」怪兽或「红莲魔龙」，这张卡自身除外）
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,e:GetHandler()) end
	-- 设置操作信息：将把1张卡送去墓地（效果处理时确定对象，故targets为nil）
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_MZONE)
end
-- 特殊召唤对象的过滤函数：满足召唤条件的「地缚」怪兽（0x21系列），或可以当作同调召唤特殊召唤的「真红莲新星龙」，且对应区域有可用怪兽区
function s.spfilter(c,e,tp)
	return ((c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsSetCard(0x21))
		or (c:IsCode(97489701) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)))
		-- 若该卡在卡组，则自己场上必须有可用的主要怪兽区
		and (c:IsLocation(LOCATION_DECK) and Duel.GetMZoneCount(tp)>0
			-- 若该卡在额外卡组，则自己场上必须有能让额外卡组怪兽出场的可用怪兽区
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
end
-- ②效果的处理函数：选1只「地缚神」怪兽或「红莲魔龙」送去墓地，之后可以选择从卡组·额外卡组把1只「地缚」怪兽特殊召唤，或把「真红莲新星龙」当作同调召唤作特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让自己从自己的手卡·场上选择1只满足条件的「地缚神」怪兽或「红莲魔龙」
	local tc=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil):GetFirst()
	-- 把选择的卡送去墓地，且确认该卡确实被送去墓地（作为后续特殊召唤处理的前提）
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE)
		-- 确认自己的卡组·额外卡组存在至少1只可以特殊召唤的满足条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp)
		-- 询问玩家是否进行特殊召唤（对应效果原文的「可以」）
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否特殊召唤？"
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让自己从卡组·额外卡组选择1只满足条件的怪兽作为特殊召唤对象
		local spc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
		if spc then
			if spc:IsCode(97489701) then
				-- 若选择的是「真红莲新星龙」，则把它当作同调召唤以表侧表示特殊召唤，成功后执行召唤手续完毕处理
				if Duel.SpecialSummon(spc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)>0 then
					spc:CompleteProcedure()
				end
			else
				-- 若选择的是「地缚」怪兽，则把它以表侧表示特殊召唤到自己场上
				Duel.SpecialSummon(spc,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
