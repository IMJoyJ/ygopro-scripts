--デーモンの巨神
-- 效果：
-- ①：怪兽区域的这张卡被效果破坏的场合，可以作为代替而支付500基本分。这个效果只在这张卡在场上表侧表示存在能使用1次。
-- ②：这张卡被效果破坏送去墓地的场合才能发动。从手卡把1只「恶魔」怪兽特殊召唤。
function c84341431.initial_effect(c)
	-- ①：怪兽区域的这张卡被效果破坏的场合，可以作为代替而支付500基本分。这个效果只在这张卡在场上表侧表示存在能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_NO_TURN_RESET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c84341431.reptg)
	e1:SetCountLimit(1)
	c:RegisterEffect(e1)
	-- ②：这张卡被效果破坏送去墓地的场合才能发动。从手卡把1只「恶魔」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(84341431,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCondition(c84341431.condition)
	e2:SetTarget(c84341431.target)
	e2:SetOperation(c84341431.operation)
	c:RegisterEffect(e2)
end
-- 代替破坏效果的目标与处理函数：检查是否因效果破坏、是否能支付500基本分，并由玩家选择是否支付500基本分代替破坏
function c84341431.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在chk==0时，检查自身是否因效果破坏、不属于代替破坏事件、且玩家能支付500基本分
	if chk==0 then return e:GetHandler():IsReason(REASON_EFFECT) and not e:GetHandler():IsReason(REASON_REPLACE) and Duel.CheckLPCost(tp,500) end
	-- 询问玩家是否发动代替破坏的效果
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		-- 玩家支付500基本分作为代替破坏的代价
		Duel.PayLPCost(tp,500)
		return true
	else return false end
end
-- 检查发动条件：这张卡是否因效果破坏并送去墓地
function c84341431.condition(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(e:GetHandler():GetReason(),0x41)==0x41
end
-- 过滤条件：手卡中属于「恶魔」字段且可以特殊召唤的怪兽
function c84341431.filter(c,e,tp)
	return c:IsSetCard(0x45) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果2的发动准备：检查自身怪兽区域是否有空位，以及手卡中是否存在满足条件的「恶魔」怪兽，并设置特殊召唤的操作信息
function c84341431.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在chk==0时，检查自身场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在至少1只可以特殊召唤的「恶魔」怪兽
		and Duel.IsExistingMatchingCard(c84341431.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置当前连锁的操作信息：从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果2的效果处理：从手卡选择1只「恶魔」怪兽特殊召唤到场上
function c84341431.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自身场上是否有可用的怪兽区域空格，若无则结束处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家发送提示信息：请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只满足条件的「恶魔」怪兽
	local g=Duel.SelectMatchingCard(tp,c84341431.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
