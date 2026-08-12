--サイバー・ドラゴン・ネクステア
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：这张卡的卡名只要在场上·墓地存在当作「电子龙」使用。
-- ②：从手卡丢弃1只其他怪兽才能发动。这张卡从手卡特殊召唤。
-- ③：这张卡召唤·特殊召唤的场合，以攻击力或守备力是2100的自己墓地1只机械族怪兽为对象才能发动。那只怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是机械族怪兽不能特殊召唤。
function c1142880.initial_effect(c)
	-- 使该卡在场上或墓地时视为「电子龙」使用
	aux.EnableChangeCode(c,70095154,LOCATION_MZONE+LOCATION_GRAVE)
	-- ②：从手卡丢弃1只其他怪兽才能发动。这张卡从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1142880,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,1142880)
	e2:SetCost(c1142880.cost)
	e2:SetTarget(c1142880.sptg)
	e2:SetOperation(c1142880.spop)
	c:RegisterEffect(e2)
	-- ③：这张卡召唤·特殊召唤的场合，以攻击力或守备力是2100的自己墓地1只机械族怪兽为对象才能发动。那只怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是机械族怪兽不能特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(1142880,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCountLimit(1,1142881)
	e3:SetTarget(c1142880.sptg2)
	e3:SetOperation(c1142880.spop2)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
-- 过滤函数，用于判断手卡中是否存在可丢弃的怪兽
function c1142880.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsDiscardable()
end
-- 效果处理函数，用于支付丢弃1只怪兽的代价
function c1142880.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足丢弃1只怪兽的条件
	if chk==0 then return Duel.IsExistingMatchingCard(c1142880.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 执行丢弃1只怪兽的操作
	Duel.DiscardHand(tp,c1142880.cfilter,1,1,REASON_COST+REASON_DISCARD,e:GetHandler())
end
-- 效果处理函数，用于设置特殊召唤的条件
function c1142880.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的场地空间并确认该卡可被特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，表示将要特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理函数，用于执行特殊召唤操作
function c1142880.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将该卡特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤函数，用于筛选墓地中的机械族2100攻击力或守备力的怪兽
function c1142880.filter(c,e,tp)
	return c:IsRace(RACE_MACHINE) and (c:IsAttack(2100) or c:IsDefense(2100)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理函数，用于设置特殊召唤目标的条件
function c1142880.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c1142880.filter(chkc,e,tp) end
	-- 检查是否有足够的场地空间并确认存在符合条件的墓地怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 查找并选择一个符合条件的墓地怪兽作为目标
		and Duel.IsExistingTarget(c1142880.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,c1142880.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息，表示将要特殊召唤目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理函数，用于执行特殊召唤目标怪兽的操作
function c1142880.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 创建一个持续到回合结束的永续效果，禁止玩家特殊召唤非机械族怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c1142880.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册该禁止特殊召唤的效果到玩家场上
	Duel.RegisterEffect(e1,tp)
end
-- 限制特殊召唤的过滤函数，禁止非机械族怪兽被特殊召唤
function c1142880.splimit(e,c)
	return not c:IsRace(RACE_MACHINE)
end
