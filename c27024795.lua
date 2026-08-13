--極星霊アルヴィース
-- 效果：
-- 这个卡名的②的效果在决斗中只能使用1次。
-- ①：「极星」连接怪兽的效果只让这张卡被除外的场合才能发动。等级合计直到10的「极星」怪兽从自己场上1只，从卡组2只送去墓地。那之后，从额外卡组把1只「极神」怪兽特殊召唤。
-- ②：自己的「极神」怪兽因战斗以外的方法被对方送去墓地的场合，把墓地的这张卡除外才能发动。同名卡不在自己墓地的1只「极神」怪兽从额外卡组特殊召唤。
function c27024795.initial_effect(c)
	-- ①：「极星」连接怪兽的效果只让这张卡被除外的场合才能发动。等级合计直到10的「极星」怪兽从自己场上1只，从卡组2只送去墓地。那之后，从额外卡组把1只「极神」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27024795,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_REMOVE)
	e1:SetRange(LOCATION_REMOVED)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(c27024795.spcon)
	e1:SetTarget(c27024795.sptg)
	e1:SetOperation(c27024795.spop)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果在决斗中只能使用1次。②：自己的「极神」怪兽因战斗以外的方法被对方送去墓地的场合，把墓地的这张卡除外才能发动。同名卡不在自己墓地的1只「极神」怪兽从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(27024795,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,27024795+EFFECT_COUNT_CODE_DUEL)
	e2:SetCondition(c27024795.spcon2)
	-- 为②效果设置发动代价：将墓地中的这张卡除外作为发动COST。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c27024795.sptg2)
	e2:SetOperation(c27024795.spop2)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件：除外事件中只有这张卡被除外，且该除外是由‘极星’连接怪兽的效果发动的。
function c27024795.spcon(e,tp,eg,ep,ev,re,r,rp)
	return #eg==1 and eg:GetFirst()==e:GetHandler() and re and re:IsActiveType(TYPE_LINK) and re:GetHandler():IsSetCard(0x42)
end
-- 定义可作为①效果送墓素材的‘极星’怪兽：卡名含有‘极星’的怪兽卡，且为表侧表示或位于卡组，等级至少为1。
function c27024795.matfilter(c)
	return c:IsSetCard(0x42) and c:IsType(TYPE_MONSTER) and (c:IsFaceup() or c:IsLocation(LOCATION_DECK)) and c:IsLevelAbove(1)
end
-- 判断选出的3张‘极星’怪兽是否满足：其中2张来自卡组，等级合计为10，并且额外卡组存在可特殊召唤的‘极神’怪兽且送墓后仍有额外怪兽区空格。
function c27024795.fgoal(sg,e,tp)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)==2 and sg:GetSum(Card.GetLevel)==10
		-- 额外卡组中存在满足spfilter的‘极神’怪兽，且将选中的送墓组移离后仍有可用的额外怪兽区。
		and Duel.IsExistingMatchingCard(c27024795.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,sg)
end
-- 定义①效果可特招的‘极神’怪兽：属于‘极神’，能被效果特殊召唤，且在选中的送墓组离场后仍有额外怪兽区空格。
function c27024795.spfilter(c,e,tp,mg)
	-- 判断目标怪兽是‘极神’、可被当前效果特殊召唤，并且若将送墓组移离后仍有可用额外怪兽区。
	return c:IsSetCard(0x4b) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mg,c)>0
end
-- ①效果的发动条件判定与操作信息登记：检查可否选出3张‘极星’怪兽（卡组2只+场上1只，等级合计10）并能特殊召唤1只‘极神’；若可，则登记送墓3张和特招1张的操作信息。
function c27024795.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取己方场上表侧表示和卡组中所有满足matfilter条件的‘极星’怪兽，作为①效果可选择的送墓候选组。
		local mg=Duel.GetMatchingGroup(c27024795.matfilter,tp,LOCATION_DECK+LOCATION_MZONE,0,nil)
		return mg:CheckSubGroup(c27024795.fgoal,3,3,e,tp)
	end
	-- 登记①效果的操作信息：预定把己方卡组或怪兽区的3张卡送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,3,tp,LOCATION_DECK+LOCATION_MZONE)
	-- 登记①效果的操作信息：预定从己方额外卡组将1只怪兽特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ①效果处理：从候选组中选出满足条件的3张‘极星’怪兽并送去墓地；若3张全部送墓成功，再从额外卡组选1只‘极神’怪兽，在断开连锁后特殊召唤。
function c27024795.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时获取己方场上表侧表示和卡组中所有满足matfilter条件的‘极星’怪兽，供本次处理选择。
	local mg=Duel.GetMatchingGroup(c27024795.matfilter,tp,LOCATION_DECK+LOCATION_MZONE,0,nil)
	-- 显示‘请选择要送去墓地的卡’的提示，引导玩家从候选组中选择3张‘极星’怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg=mg:SelectSubGroup(tp,c27024795.fgoal,false,3,3,e,tp)
	-- 若玩家成功选出了3张‘极星’怪兽且全部以效果原因送入墓地，才继续执行后续的特殊召唤。
	if sg and Duel.SendtoGrave(sg,REASON_EFFECT)==3 then
		-- 显示‘请选择要特殊召唤的卡’的提示，引导玩家选择要特殊召唤的‘极神’怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从己方额外卡组中选择1只满足spfilter条件的‘极神’怪兽作为特殊召唤对象。
		local tg=Duel.SelectMatchingCard(tp,c27024795.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil)
		if tg:GetCount()>0 then
			-- 中断当前效果处理，使随后的特殊召唤与前段的送墓处理不视为同时进行，以避免错过时点。
			Duel.BreakEffect()
			-- 将选中的‘极神’怪兽以表侧表示特殊召唤到己方场上，不检查召唤条件也不检查苏生限制。
			Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 定义②效果的事件过滤：用于判断被送去墓地的怪兽是否原本由己方控制且是‘极神’怪兽。
function c27024795.cfilter(c,tp)
	return c:IsPreviousSetCard(0x4b) and c:IsPreviousControler(tp)
end
-- ②效果的发动条件：存在由对方原因从己方场上送去墓地的己方‘极神’怪兽，满足时②可在墓地发动。
function c27024795.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp and eg:IsExists(c27024795.cfilter,1,nil,tp)
end
-- 定义②效果可特殊召唤的‘极神’怪兽：是‘极神’、能被效果特殊召唤、有额外怪兽区空格，且自己墓地没有同名卡。
function c27024795.spfilter2(c,e,tp)
	-- 判断候选‘极神’怪兽满足卡名、可特殊召唤，并有额外怪兽区空格。
	return c:IsSetCard(0x4b) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
		-- 确认自己墓地中不存在与候选怪兽同名的卡，即‘同名卡不在自己墓地’的限制。
		and not Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,c:GetCode())
end
-- ②效果的发动条件判定与操作信息登记：检查额外卡组中是否存在可特殊召唤的‘极神’怪兽；若存在，登记从额外卡组特殊召唤1只怪兽。
function c27024795.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时点确认阶段，检查额外卡组是否有符合spfilter2条件的‘极神’怪兽可供特殊召唤。
	if chk==0 then return Duel.IsExistingMatchingCard(c27024795.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 登记②效果的操作信息：预定从己方额外卡组将1只怪兽特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ②效果处理：从额外卡组选择1只符合条件的‘极神’怪兽并表侧表示特殊召唤到己方场上。
function c27024795.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 显示‘请选择要特殊召唤的卡’的提示，引导玩家选择要特殊召唤的‘极神’怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从己方额外卡组中选择1只满足spfilter2条件的‘极神’怪兽作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c27024795.spfilter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选中的‘极神’怪兽以表侧表示特殊召唤到己方场上，不检查召唤条件也不检查苏生限制。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
