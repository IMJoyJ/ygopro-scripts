--真紅眼の不屍竜
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡的攻击力·守备力上升双方的场上·墓地的不死族怪兽数量×100。
-- ②：这张卡以外的不死族怪兽被战斗破坏时才能发动。选自己或者对方的墓地1只不死族怪兽在自己场上特殊召唤。
function c28240337.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和1只调整以外的怪兽参与同调
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡的攻击力·守备力上升双方的场上·墓地的不死族怪兽数量×100。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c28240337.atkval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	-- ②：这张卡以外的不死族怪兽被战斗破坏时才能发动。选自己或者对方的墓地1只不死族怪兽在自己场上特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYED)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,28240337)
	e3:SetCondition(c28240337.spcon)
	e3:SetTarget(c28240337.sptg)
	e3:SetOperation(c28240337.spop)
	c:RegisterEffect(e3)
end
-- 计算双方场上和墓地的不死族怪兽数量并乘以100作为攻击力和守备力的增加量
function c28240337.atkval(e,c)
	-- 返回双方场上和墓地的不死族怪兽数量乘以100的结果
	return Duel.GetMatchingGroupCount(Card.IsRace,c:GetControler(),LOCATION_GRAVE+LOCATION_MZONE,LOCATION_GRAVE+LOCATION_MZONE,nil,RACE_ZOMBIE)*100
end
-- 判断怪兽在被破坏前是否为不死族
function c28240337.cfilter(c)
	return c:GetPreviousRaceOnField()&RACE_ZOMBIE~=0
end
-- 检查被战斗破坏的怪兽中是否存在不死族怪兽
function c28240337.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c28240337.cfilter,1,nil)
end
-- 筛选可以特殊召唤的不死族怪兽
function c28240337.spfilter(c,e,tp)
	return c:IsRace(RACE_ZOMBIE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤效果的发动条件和目标
function c28240337.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有足够的召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家墓地是否存在满足条件的不死族怪兽
		and Duel.IsExistingMatchingCard(c28240337.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp) end
	-- 设置连锁操作信息，表示将要特殊召唤一张不死族怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 执行特殊召唤效果，从墓地选择不死族怪兽特殊召唤到场上
function c28240337.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有足够的召唤区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从墓地选择一张满足条件的不死族怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c28240337.spfilter),tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
	if #g>0 then
		-- 将选中的不死族怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
