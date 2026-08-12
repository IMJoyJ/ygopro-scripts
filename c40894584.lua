--ジゴバイト
-- 效果：
-- ①：「电豪灵蜥」在自己场上只能有1张表侧表示存在。
-- ②：自己场上有魔法师族怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ③：这张卡被战斗·效果破坏送去墓地时才能发动。从卡组把「电豪灵蜥」以外的1只攻击力1500/守备力200的怪兽特殊召唤。
function c40894584.initial_effect(c)
	c:SetUniqueOnField(1,0,40894584)
	-- ②：自己场上有魔法师族怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c40894584.spcon)
	c:RegisterEffect(e1)
	-- ③：这张卡被战斗·效果破坏送去墓地时才能发动。从卡组把「电豪灵蜥」以外的1只攻击力1500/守备力200的怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(40894584,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c40894584.condition)
	e2:SetTarget(c40894584.target)
	e2:SetOperation(c40894584.operation)
	c:RegisterEffect(e2)
end
-- 检查场上是否存在正面表示的魔法师族怪兽
function c40894584.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER)
end
-- 判断是否满足特殊召唤条件：有空场且己方场上存在魔法师族怪兽
function c40894584.spcon(e,c)
	if c==nil then return true end
	-- 判断己方场上是否有空位
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 判断己方场上是否存在魔法师族怪兽
		and Duel.IsExistingMatchingCard(c40894584.cfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
-- 判断此卡是否因战斗或效果破坏而进入墓地
function c40894584.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY) and e:GetHandler():IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- 筛选攻击力为1500、守备力为200且不是电豪灵蜥的怪兽
function c40894584.filter(c,e,tp)
	return c:IsAttack(1500) and c:IsDefense(200) and not c:IsCode(40894584) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足发动条件：己方场上存在空位且卡组存在符合条件的怪兽
function c40894584.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断己方场上是否存在空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断卡组中是否存在符合条件的怪兽
		and Duel.IsExistingMatchingCard(c40894584.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表示将从卡组特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 执行特殊召唤操作：从卡组选择符合条件的怪兽并特殊召唤
function c40894584.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 判断己方场上是否还有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择一只符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c40894584.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽正面表示特殊召唤到己方场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
