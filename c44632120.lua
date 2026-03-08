--クリバー
-- 效果：
-- 这个卡名在规则上也当作「栗子球」卡使用。这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡或者自己的「栗子球」怪兽被战斗破坏时才能发动。从卡组把「栗子丸」以外的1只攻击力300/守备力200的怪兽特殊召唤。
-- ②：把场上的这张卡和自己的手卡·场上的「栗子团」「栗子圆」「栗子珠」「栗子球」各1只解放才能发动。从自己的手卡·卡组·墓地选1只「巴比伦栗子」特殊召唤。
function c44632120.initial_effect(c)
	-- 注册该卡名在规则上也当作「栗子球」卡使用
	aux.AddCodeList(c,71036835,7021574,34419588,40640057)
	-- ①：这张卡或者自己的「栗子球」怪兽被战斗破坏时才能发动。从卡组把「栗子丸」以外的1只攻击力300/守备力200的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44632120,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCountLimit(1,44632120)
	e1:SetTarget(c44632120.sptg)
	e1:SetOperation(c44632120.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c44632120.spcon)
	c:RegisterEffect(e2)
	-- ②：把场上的这张卡和自己的手卡·场上的「栗子团」「栗子圆」「栗子珠」「栗子球」各1只解放才能发动。从自己的手卡·卡组·墓地选1只「巴比伦栗子」特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(44632120,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c44632120.spcost2)
	e3:SetTarget(c44632120.sptg2)
	e3:SetOperation(c44632120.spop2)
	c:RegisterEffect(e3)
end
-- 创建一个用于检查是否为指定卡名的条件函数数组
c44632120.spchecks=aux.CreateChecks(Card.IsCode,{71036835,7021574,34419588,40640057})
-- 过滤函数：筛选攻击力为300、守备力为200且不是栗子丸的怪兽
function c44632120.spfilter(c,e,tp)
	return c:IsDefense(200) and c:IsAttack(300) and not c:IsCode(44632120) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理时的条件判断：检查场上是否有足够的召唤位置且卡组中是否存在满足条件的怪兽
function c44632120.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c44632120.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息：准备特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数：从卡组选择满足条件的怪兽并特殊召唤
function c44632120.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有足够的召唤位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c44632120.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数：判断是否为「栗子球」系列的怪兽
function c44632120.cfilter(c,tp)
	return c:IsControler(tp) and c:IsPreviousControler(tp) and c:IsPreviousSetCard(0xa4)
end
-- 效果触发条件函数：判断是否有「栗子球」系列怪兽被战斗破坏
function c44632120.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c44632120.cfilter,1,nil,tp)
end
-- 过滤函数：筛选「栗子团」「栗子圆」「栗子珠」「栗子球」系列的怪兽
function c44632120.rlfilter(c,tp)
	return c:IsCode(71036835,7021574,34419588,40640057) and (c:IsControler(tp) or c:IsFaceup())
end
-- 检查函数：判断是否可以满足解放条件并召唤怪兽
function c44632120.rlcheck(sg,c,tp)
	local g=sg:Clone()
	g:AddCard(c)
	-- 检查是否可以满足解放条件并召唤怪兽
	return Duel.GetMZoneCount(tp,g)>0 and Duel.CheckReleaseGroupEx(tp,aux.IsInGroup,#g,REASON_COST,true,nil,g)
end
-- 效果处理函数：支付解放代价并特殊召唤怪兽
function c44632120.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取玩家可解放的「栗子球」系列怪兽
	local g=Duel.GetReleaseGroup(tp,true):Filter(c44632120.rlfilter,c,tp)
	if chk==0 then return c:IsReleasable() and g:CheckSubGroupEach(c44632120.spchecks,c44632120.rlcheck,c,tp) end
	-- 提示玩家选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local rg=g:SelectSubGroupEach(tp,c44632120.spchecks,false,c44632120.rlcheck,c,tp)
	-- 使用额外的解放次数
	aux.UseExtraReleaseCount(rg,tp)
	rg:AddCard(c)
	-- 将选中的卡进行解放
	Duel.Release(rg,REASON_COST)
end
-- 过滤函数：筛选「巴比伦栗子」怪兽
function c44632120.spfilter2(c,e,tp)
	return c:IsCode(70914287) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理时的条件判断：检查手卡·墓地·卡组中是否存在满足条件的怪兽
function c44632120.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡·墓地·卡组中是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c44632120.spfilter2,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息：准备特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK)
end
-- 效果处理函数：从手卡·墓地·卡组中选择满足条件的怪兽并特殊召唤
function c44632120.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有足够的召唤位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·墓地·卡组中选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c44632120.spfilter2),tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
