--覇蛇大公ゴルゴンダ
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡在手卡·墓地存在，自己的场地区域有表侧表示卡存在的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
-- ②：只要场上有「大沙海 黄金戈尔工达」存在，这张卡的原本攻击力变成3000。
-- ③：场上的「大沙海 黄金戈尔工达」被效果破坏的场合，可以作为代替把自己墓地1只怪兽除外。
function c31042659.initial_effect(c)
	-- 记录该卡牌效果中涉及的另一张卡的卡号
	aux.AddCodeList(c,60884672)
	-- ①：这张卡在手卡·墓地存在，自己的场地区域有表侧表示卡存在的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31042659,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,31042659)
	e1:SetCondition(c31042659.spcon)
	e1:SetTarget(c31042659.sptg)
	e1:SetOperation(c31042659.spop)
	c:RegisterEffect(e1)
	-- ③：场上的「大沙海 黄金戈尔工达」被效果破坏的场合，可以作为代替把自己墓地1只怪兽除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,31042660)
	e2:SetTarget(c31042659.reptg)
	e2:SetValue(c31042659.repval)
	c:RegisterEffect(e2)
	-- ②：只要场上有「大沙海 黄金戈尔工达」存在，这张卡的原本攻击力变成3000。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_SET_BASE_ATTACK)
	e3:SetCondition(c31042659.atkcon)
	e3:SetValue(3000)
	c:RegisterEffect(e3)
end
-- 检查己方场地区域是否存在表侧表示的场地卡
function c31042659.spcon(e)
	-- 己方场地区域存在表侧表示的场地卡
	return Duel.IsExistingMatchingCard(Card.IsFaceup,e:GetHandlerPlayer(),LOCATION_FZONE,0,1,nil)
end
-- 判断特殊召唤的条件是否满足
function c31042659.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 己方场上存在可用怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作并设置效果
function c31042659.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认卡牌能被特殊召唤且成功召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 设置特殊召唤后该卡离开场上的处理方式为除外
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
-- 筛选场上的「大沙海 黄金戈尔工达」作为被破坏的目标
function c31042659.repfilter(c)
	return c:IsFaceup() and c:IsCode(60884672) and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- 筛选墓地中的怪兽用于除外
function c31042659.rmfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
-- 判断是否满足代替破坏的条件
function c31042659.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c31042659.repfilter,1,nil)
		-- 己方墓地存在可除外的怪兽
		and Duel.IsExistingMatchingCard(c31042659.rmfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 询问玩家是否发动效果
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		-- 提示玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 选择1只墓地中的怪兽除外
		local g=Duel.SelectMatchingCard(tp,c31042659.rmfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		-- 将选中的怪兽除外
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
		return true
	end
	return false
end
-- 返回代替破坏的条件是否满足
function c31042659.repval(e,c)
	return c31042659.repfilter(c)
end
-- 判断场地区域是否存在「大沙海 黄金戈尔工达」
function c31042659.atkcon(e)
	-- 场地区域存在「大沙海 黄金戈尔工达」
	return Duel.IsEnvironment(60884672)
end
