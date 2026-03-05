--光虫異変
-- 效果：
-- 「光虫异变」在1回合只能发动1张。
-- ①：以自己墓地2只昆虫族·3星怪兽为对象才能发动。那些怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
-- ②：从自己墓地把这张卡和1只超量怪兽除外才能发动。自己场上的全部昆虫族·3星怪兽的等级直到回合结束时变成和除外的超量怪兽的阶级相同数值的等级。这个效果的发动后，直到回合结束时自己不是昆虫族怪兽不能特殊召唤。
function c10971759.initial_effect(c)
	-- ①：以自己墓地2只昆虫族·3星怪兽为对象才能发动。那些怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10971759,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,10971759+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c10971759.sptg)
	e1:SetOperation(c10971759.spop)
	c:RegisterEffect(e1)
	-- ②：从自己墓地把这张卡和1只超量怪兽除外才能发动。自己场上的全部昆虫族·3星怪兽的等级直到回合结束时变成和除外的超量怪兽的阶级相同数值的等级。这个效果的发动后，直到回合结束时自己不是昆虫族怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(10971759,1))  --"等级变更"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(c10971759.cost)
	e2:SetTarget(c10971759.target)
	e2:SetOperation(c10971759.operation)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断墓地中的怪兽是否满足特殊召唤条件（3星、昆虫族、可特殊召唤）
function c10971759.spfilter(c,e,tp)
	return c:IsLevel(3) and c:IsRace(RACE_INSECT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动时点处理函数，用于判断是否满足发动条件并选择目标
function c10971759.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c10971759.spfilter(chkc,e,tp) end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中：禁止该玩家同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 判断玩家场上是否有足够的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 判断玩家墓地是否存在至少2只满足条件的怪兽
		and Duel.IsExistingTarget(c10971759.spfilter,tp,LOCATION_GRAVE,0,2,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 选择满足条件的2只怪兽作为特殊召唤对象
	local g=Duel.SelectTarget(tp,c10971759.spfilter,tp,LOCATION_GRAVE,0,2,2,nil,e,tp)
	-- 设置效果处理信息，告知连锁将要特殊召唤2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,0,0)
end
-- 效果①的处理函数，执行特殊召唤及效果无效化
function c10971759.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中选择的目标怪兽组，并过滤出与当前效果相关的怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中：禁止该玩家同时特殊召唤2只以上怪兽
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<g:GetCount() or (g:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133)) then return end
	local tc=g:GetFirst()
	while tc do
		-- 特殊召唤一张怪兽到场上
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		-- 使特殊召唤的怪兽效果无效
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		-- 使特殊召唤的怪兽效果无效化（持续到回合结束）
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
		tc=g:GetNext()
	end
	-- 完成所有特殊召唤步骤
	Duel.SpecialSummonComplete()
end
-- 过滤函数，用于判断墓地中的超量怪兽是否满足除外条件（非3星、可除外）
function c10971759.cfilter(c,e,tp)
	return c:IsType(TYPE_XYZ) and c:GetRank()~=3 and c:IsAbleToRemoveAsCost()
end
-- 效果②的发动时点处理函数，用于判断是否满足发动条件并支付费用
function c10971759.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost()
		-- 判断玩家墓地是否存在至少1只满足条件的超量怪兽
		and Duel.IsExistingMatchingCard(c10971759.cfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要除外的超量怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	-- 选择满足条件的1只超量怪兽作为除外对象
	local g=Duel.SelectMatchingCard(tp,c10971759.cfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	e:SetLabel(g:GetFirst():GetRank())
	g:AddCard(e:GetHandler())
	-- 将选中的怪兽和此卡一同除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤函数，用于判断场上的怪兽是否满足等级变更条件（3星、昆虫族、表侧表示）
function c10971759.filter(c)
	return c:IsFaceup() and c:IsLevel(3) and c:IsRace(RACE_INSECT)
end
-- 效果②的发动时点处理函数，用于判断是否满足发动条件
function c10971759.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断玩家场上是否存在至少1只满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c10971759.filter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 效果②的处理函数，执行等级变更及特殊召唤限制
function c10971759.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取场上所有满足条件的怪兽组
	local g=Duel.GetMatchingGroup(c10971759.filter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 使场上的怪兽等级变为除外的超量怪兽的阶级
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
	-- 设置效果②的发动后限制，禁止玩家在本回合特殊召唤非昆虫族怪兽
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c10971759.splimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册效果②的发动后限制效果
	Duel.RegisterEffect(e2,tp)
end
-- 限制特殊召唤的过滤函数，判断是否为昆虫族怪兽
function c10971759.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_INSECT)
end
