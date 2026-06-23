--地縛神 スカーレッド・ノヴァ
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：「地缚神」怪兽在场上只能有1只表侧表示存在。
-- ②：自己·对方的主要阶段，把手卡·墓地的这张卡除外才能发动。从自己的手卡·场上（表侧表示）把1只「地缚神」怪兽或「红莲魔龙」送去墓地。那之后，可以从以下效果让1个适用。
-- ●从卡组·额外卡组把1只「地缚」怪兽特殊召唤。
-- ●从额外卡组把1只「真红莲新星龙」当作同调召唤作特殊召唤。
local s,id,o=GetID()
-- 初始化效果函数，注册卡名代码列表并设置场上唯一性条件
function s.initial_effect(c)
	-- 记录该卡与「地缚神」和「红莲魔龙」的关联
	aux.AddCodeList(c,70902743,97489701)
	-- 设置场上只能存在1只表侧表示的「地缚神」怪兽
	c:SetUniqueOnField(1,1,aux.FilterBoolFunction(Card.IsSetCard,0x1021),LOCATION_MZONE)
	-- 创建诱发即时效果，可在主要阶段发动，具有特殊召唤和送去墓地的分类
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
-- 判断是否处于主要阶段1或主要阶段2
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前阶段为主要阶段1或主要阶段2时效果可用
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 设置发动费用，将自身从手牌或墓地除外
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	-- 将自身从场上除外作为发动费用
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
-- 定义用于选择送去墓地的「地缚神」怪兽或「红莲魔龙」的过滤器
function s.tgfilter(c)
	return c:IsFaceupEx() and c:IsAbleToGrave() and (c:IsCode(70902743) or (c:IsSetCard(0x1021) and c:IsType(TYPE_MONSTER)))
end
-- 设置效果目标，检查是否存在满足条件的怪兽可被送去墓地
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足条件的怪兽可被送去墓地
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,e:GetHandler()) end
	-- 设置操作信息，表示将有1张卡被送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_MZONE)
end
-- 定义用于选择特殊召唤的「地缚」怪兽或「真红莲新星龙」的过滤器
function s.spfilter(c,e,tp)
	return ((c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsSetCard(0x21))
		or (c:IsCode(97489701) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)))
		-- 若目标在卡组且场上存在可用怪兽区则可特殊召唤
		and (c:IsLocation(LOCATION_DECK) and Duel.GetMZoneCount(tp)>0
			-- 若目标在额外卡组且满足特殊召唤条件则可特殊召唤
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
end
-- 主效果处理函数，执行送去墓地和特殊召唤操作
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的卡送去墓地
	local tc=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil):GetFirst()
	-- 确认所选卡已成功送去墓地并检查是否满足后续条件
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE)
		-- 检查是否存在可特殊召唤的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp)
		-- 询问玩家是否进行特殊召唤
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否特殊召唤？"
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的卡进行特殊召唤
		local spc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
		if spc then
			if spc:IsCode(97489701) then
				-- 以同调方式特殊召唤「真红莲新星龙」
				if Duel.SpecialSummon(spc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP) then
					spc:CompleteProcedure()
				end
			else
				-- 以通常方式特殊召唤其他「地缚」怪兽
				Duel.SpecialSummon(spc,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
