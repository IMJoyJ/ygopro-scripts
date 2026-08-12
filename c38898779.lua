--ギガンテック・ファイター／バスター
-- 效果：
-- 这张卡不能通常召唤。「爆裂模式」的效果才能特殊召唤。只要这张卡在场上表侧表示存在，全部对方怪兽的攻击力下降自己墓地存在的战士族怪兽数量×100的数值。这张卡特殊召唤成功时，可以从自己卡组选择最多2只战士族怪兽送去墓地。此外，场上存在的这张卡被破坏时，可以把自己墓地存在的1只「巨人斗士」特殊召唤。
function c38898779.initial_effect(c)
	-- 记录该卡具有「爆裂模式」效果的卡片编号
	aux.AddCodeList(c,80280737)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 限制该卡只能通过「爆裂模式」的效果特殊召唤
	e1:SetValue(aux.AssaultModeLimit)
	c:RegisterEffect(e1)
	-- 这张卡特殊召唤成功时，可以从自己卡组选择最多2只战士族怪兽送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(38898779,0))  --"送墓"
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetTarget(c38898779.tgtg)
	e2:SetOperation(c38898779.tgop)
	c:RegisterEffect(e2)
	-- 只要这张卡在场上表侧表示存在，全部对方怪兽的攻击力下降自己墓地存在的战士族怪兽数量×100的数值。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetValue(c38898779.atkval)
	c:RegisterEffect(e3)
	-- 场上存在的这张卡被破坏时，可以把自己墓地存在的1只「巨人斗士」特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(38898779,1))  --"特殊召唤「巨人斗士」"
	e4:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCondition(c38898779.spcon)
	e4:SetTarget(c38898779.sptg)
	e4:SetOperation(c38898779.spop)
	c:RegisterEffect(e4)
end
c38898779.assault_name=23693634
-- 过滤函数，用于筛选可以送去墓地的战士族怪兽
function c38898779.tgfilter(c)
	return c:IsRace(RACE_WARRIOR) and c:IsAbleToGrave()
end
-- 设置效果发动时的处理目标，检查是否满足发动条件
function c38898779.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查场上是否存在满足条件的战士族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c38898779.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，表示将要处理送去墓地的效果
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 执行效果处理，选择并送去墓地
function c38898779.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组中选择1到2张战士族怪兽
	local g=Duel.SelectMatchingCard(tp,c38898779.tgfilter,tp,LOCATION_DECK,0,1,2,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 计算攻击力下降值，根据墓地战士族怪兽数量
function c38898779.atkval(e,c)
	-- 获取墓地战士族怪兽数量并乘以-100作为攻击力下降值
	return Duel.GetMatchingGroupCount(Card.IsRace,e:GetHandler():GetControler(),LOCATION_GRAVE,0,nil,RACE_WARRIOR)*-100
end
-- 判断该卡是否在破坏前位于场上
function c38898779.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤函数，用于筛选可以特殊召唤的「巨人斗士」
function c38898779.spfilter(c,e,tp)
	return c:IsCode(23693634) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果发动时的处理目标，检查是否满足发动条件
function c38898779.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c38898779.spfilter(chkc,e,tp) end
	-- 检查场上是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在满足条件的「巨人斗士」
		and Duel.IsExistingTarget(c38898779.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从墓地中选择1只「巨人斗士」作为特殊召唤目标
	local g=Duel.SelectTarget(tp,c38898779.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁操作信息，表示将要处理特殊召唤的效果
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行效果处理，将目标怪兽特殊召唤
function c38898779.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的处理目标
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
