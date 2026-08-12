--未来の柱－キアノス
-- 效果：
-- 这个卡名在规则上也当作「闪刀」卡使用。这个卡名的①②③的效果1回合各能使用1次。
-- ①：从手卡丢弃1张魔法卡才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合才能发动。从自己的卡组·墓地把1只「闪刀姬-露世」特殊召唤。这个回合，自己不是机械族怪兽不能从额外卡组特殊召唤。
-- ③：把墓地的这张卡除外才能发动。选自己的墓地·除外状态的1只「闪刀姬-露世」加入手卡或特殊召唤。
local s,id,o=GetID()
-- 注册卡片的三个效果：①从手卡丢弃魔法卡特殊召唤、②召唤/特殊召唤时从卡组/墓地特殊召唤闪刀姬-露世并限制非机械族怪兽不能从额外卡组特殊召唤、③把墓地的自己除外发动，选择墓地或除外状态的闪刀姬-露世加入手卡或特殊召唤。
function s.initial_effect(c)
	-- ①：从手卡丢弃1张魔法卡才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"从手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1,id)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤的场合才能发动。从自己的卡组·墓地把1只「闪刀姬-露世」特殊召唤。这个回合，自己不是机械族怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"从卡组·墓地特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ③：把墓地的这张卡除外才能发动。选自己的墓地·除外状态的1只「闪刀姬-露世」加入手卡或特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"加入手卡或特殊召唤"
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_ACTION+CATEGORY_GRAVE_SPSUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GRAVE)
	-- 效果发动时，将自身从游戏中除外作为代价。
	e4:SetCost(aux.bfgcost)
	e4:SetCountLimit(1,id+o*2)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
end
-- 定义丢弃的卡牌过滤条件：必须是魔法卡且可被丢弃。
function s.costfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsDiscardable()
end
-- 效果发动时，检查玩家手牌是否存在满足条件的魔法卡，若存在则丢弃一张。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家手牌是否存在满足条件的魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 执行丢弃操作，丢弃一张满足条件的魔法卡。
	Duel.DiscardHand(tp,s.costfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 设置效果的发动目标，检查是否满足特殊召唤条件。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查玩家场上是否存在空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息，表示将特殊召唤此卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 执行效果操作，将此卡特殊召唤到场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将此卡以特殊召唤方式加入场上。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 定义特殊召唤的卡牌过滤条件：必须是闪刀姬-露世且可特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsCode(37351133) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果的发动目标，检查是否满足特殊召唤闪刀姬-露世的条件。
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否存在空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家卡组或墓地是否存在满足条件的闪刀姬-露世。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表示将特殊召唤闪刀姬-露世。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 执行效果操作，选择并特殊召唤闪刀姬-露世，并设置后续限制效果。
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否存在空位。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的闪刀姬-露世。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的卡特殊召唤到场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 设置限制效果，禁止非机械族怪兽从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将限制效果注册到全局环境。
	Duel.RegisterEffect(e1,tp)
end
-- 定义限制效果的过滤条件：非机械族且在额外卡组的怪兽不能特殊召唤。
function s.splimit(e,c)
	return not c:IsRace(RACE_MACHINE) and c:IsLocation(LOCATION_EXTRA)
end
-- 定义选择目标的过滤条件：闪刀姬-露世且可加入手卡或特殊召唤。
function s.thfilter(c,e,tp)
	return c:IsCode(37351133) and (c:IsAbleToHand() or c:IsCanBeSpecialSummoned(e,0,tp,false,false)) and c:IsFaceupEx()
end
-- 设置效果的发动目标，检查是否满足选择目标的条件。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家墓地或除外状态是否存在满足条件的闪刀姬-露世。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
end
-- 执行效果操作，选择目标并决定将其加入手卡或特殊召唤。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 选择满足条件的闪刀姬-露世作为目标。
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp):GetFirst()
	if tc then
		-- 判断是否可以特殊召唤该目标，若不能或玩家选择回手，则回手。
		if not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) or Duel.SelectOption(tp,1190,1152)==0 then
			-- 将目标卡加入玩家手牌。
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 向对方确认该卡的加入手牌操作。
			Duel.ConfirmCards(1-tp,tc)
		else
			-- 将目标卡特殊召唤到场上。
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
