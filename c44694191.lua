--仮初の幻臉師
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次，③的效果在决斗中只能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1只恶魔族·幻想魔族·魔法师族怪兽送去墓地。那之后，可以把这张卡的种族变成和这个效果送去墓地的怪兽的原本种族相同。
-- ②：这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏。
-- ③：这张卡在墓地存在的场合，从自己墓地把1张魔法卡除外才能发动。这张卡特殊召唤。
local s,id,o=GetID()
-- 创建并注册该卡的4个效果，包括①②③效果的触发条件和处理函数
function s.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1只恶魔族·幻想魔族·魔法师族怪兽送去墓地。那之后，可以把这张卡的种族变成和这个效果送去墓地的怪兽的原本种族相同。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"送去墓地"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(s.indtg)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- ③：这张卡在墓地存在的场合，从自己墓地把1张魔法卡除外才能发动。这张卡特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,id+EFFECT_COUNT_CODE_DUEL)
	e4:SetCost(s.spcost)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
-- 过滤函数，用于筛选卡组中种族为恶魔族、幻想魔族或魔法师族且能被送去墓地的怪兽
function s.tgfilter(c)
	return c:IsRace(RACE_FIEND+RACE_ILLUSION+RACE_SPELLCASTER) and c:IsAbleToGrave()
end
-- 效果发动时的处理函数，检查是否满足条件并设置操作信息
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示将要将1张卡从卡组送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，选择并送去墓地的卡，并根据条件改变自身种族
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	-- 将选中的卡送去墓地
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)~=0
		and tc:IsLocation(LOCATION_GRAVE)
		and c:IsRelateToChain() and c:IsFaceup() then
		local race=tc:GetOriginalRace()
		-- 判断是否需要改变种族并询问玩家
		if not c:IsRace(race) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否改变种族？"
			-- 中断当前效果，使后续效果处理视为不同时处理
			Duel.BreakEffect()
			-- 改变自身种族的效果
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_RACE)
			e1:SetValue(race)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			c:RegisterEffect(e1)
		end
	end
end
-- 战斗破坏免疫效果的目标筛选函数，用于判断是否为自身或战斗对象
function s.indtg(e,c)
	local tc=e:GetHandler()
	return c==tc or c==tc:GetBattleTarget()
end
-- 过滤函数，用于筛选墓地中可作为除外费用的魔法卡
function s.costfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToRemoveAsCost()
end
-- ③效果的发动费用处理函数，选择并除外1张魔法卡
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	-- 将选中的卡除外作为费用
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ③效果的发动条件判断函数，检查是否有足够的召唤位置和特殊召唤资格
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，表示将要特殊召唤这张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ③效果的处理函数，判断是否满足条件并特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断是否满足特殊召唤条件
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将自身特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
