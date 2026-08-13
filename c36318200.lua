--森の聖獣 ユニフォリア
-- 效果：
-- 自己墓地的怪兽只有兽族的场合，把这张卡解放才能发动。从自己的手卡·墓地选「森之圣兽 绿叶独角兽」以外的1只兽族怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合不能攻击。
function c36318200.initial_effect(c)
	-- 自己墓地的怪兽只有兽族的场合，把这张卡解放才能发动。从自己的手卡·墓地选「森之圣兽 绿叶独角兽」以外的1只兽族怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(36318200,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c36318200.spcon)
	e1:SetCost(c36318200.spcost)
	e1:SetTarget(c36318200.sptg)
	e1:SetOperation(c36318200.spop)
	c:RegisterEffect(e1)
end
-- 过滤函数：如果怪兽的种族不是兽族则返回true，用于判定墓地是否存在非兽族怪兽。
function c36318200.cfilter(c)
	return c:GetRace()~=RACE_BEAST
end
-- 发动条件：自己墓地有怪兽且所有怪兽均为兽族时才能发动。
function c36318200.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己墓地的所有怪兽卡组。
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_MONSTER)
	return g:GetCount()>0 and not g:IsExists(c36318200.cfilter,1,nil)
end
-- 发动代价：将这张卡自身解放作为发动费用的判定与执行。
function c36318200.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将这张卡解放送入墓地，作为发动代价（REASON_COST）。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 筛选可特殊召唤的卡：卡名不为「森之圣兽 绿叶独角兽」，种族为兽族，且能够被效果特殊召唤。
function c36318200.filter(c,e,tp)
	return not c:IsCode(36318200) and c:IsRace(RACE_BEAST) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动时选择目标的处理：检查能否至少选择1张符合条件的兽族怪兽，并预留特殊召唤的空间。
function c36318200.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查主要怪兽区域空格数是否大于-1，以允许解放后空出位置进行特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查手卡·墓地中是否存在至少1张满足特殊召唤条件的兽族怪兽。
		and Duel.IsExistingMatchingCard(c36318200.filter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp) end
	-- 登记本次效果将进行特殊召唤操作，预计从手卡·墓地特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
-- 效果处理：选择手卡·墓地中的1只兽族怪兽特殊召唤，并给该怪兽附加不能攻击的无效化效果。
function c36318200.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若主要怪兽区域没有空格则效果处理不进行。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家显示特殊召唤的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·墓地选择1张不受王家长眠之谷影响的符合条件的兽族怪兽（效果处理时选择）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c36318200.filter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 将选择的怪兽以表侧表示特殊召唤到自己的主要怪兽区域，若成功则继续赋予不能攻击效果。
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽在这个回合不能攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
	-- 完成连锁的特殊召唤处理，结算所有特殊召唤步骤。
	Duel.SpecialSummonComplete()
end
