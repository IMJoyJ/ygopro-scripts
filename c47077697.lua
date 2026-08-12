--呪念の化身ウルボヌス
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：把自己场上1只爬虫类族怪兽解放才能发动。这张卡从手卡特殊召唤。
-- ②：只要这张卡在怪兽区域存在，对方场上的怪兽的攻击力·守备力下降300。
-- ③：把自己场上1只怪兽解放才能发动。对方场上的全部怪兽的攻击力·守备力直到回合结束时下降解放的怪兽的原本攻击力数值。
function c47077697.initial_effect(c)
	-- ①：把自己场上1只爬虫类族怪兽解放才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(47077697,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,47077697)
	e1:SetCost(c47077697.spcost)
	e1:SetTarget(c47077697.sptg)
	e1:SetOperation(c47077697.spop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，对方场上的怪兽的攻击力·守备力下降300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetValue(-300)
	c:RegisterEffect(e2)
	local e3=Effect.Clone(e2)
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- ③：把自己场上1只怪兽解放才能发动。对方场上的全部怪兽的攻击力·守备力直到回合结束时下降解放的怪兽的原本攻击力数值。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(47077697,1))
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,47077698)
	e4:SetCost(c47077697.thcost)
	e4:SetTarget(c47077697.thtg)
	e4:SetOperation(c47077697.thop)
	c:RegisterEffect(e4)
end
-- 检查场上是否存在满足条件的爬虫类族怪兽（可解放）
function c47077697.cfilter(c,tp)
	-- 检查场上是否存在满足条件的爬虫类族怪兽（可解放）
	return c:IsRace(RACE_REPTILE) and Duel.GetMZoneCount(tp,c)>0
		and (c:IsControler(tp) or c:IsFaceup())
end
-- 检索满足条件的爬虫类族怪兽组并解放
function c47077697.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的爬虫类族怪兽（可解放）
	if chk==0 then return Duel.CheckReleaseGroup(tp,c47077697.cfilter,1,nil,tp) end
	-- 提示玩家选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 选择满足条件的爬虫类族怪兽作为解放对象
	local g=Duel.SelectReleaseGroup(tp,c47077697.cfilter,1,1,nil,tp)
	-- 将选中的卡进行解放
	Duel.Release(g,REASON_COST)
end
-- 设置特殊召唤的处理目标
function c47077697.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 执行特殊召唤操作
function c47077697.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将卡片特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 检查场上是否存在满足条件的怪兽（可解放）
function c47077697.rfilter(c,tp)
	return c:GetTextAttack()>0 and (c:IsControler(tp) or c:IsFaceup())
end
-- 检索满足条件的怪兽组并解放
function c47077697.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的怪兽（可解放）
	if chk==0 then return Duel.CheckReleaseGroup(tp,c47077697.rfilter,1,nil,tp) end
	-- 提示玩家选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 选择满足条件的怪兽作为解放对象
	local g=Duel.SelectReleaseGroup(tp,c47077697.rfilter,1,1,nil,tp)
	-- 将选中的卡进行解放
	Duel.Release(g,REASON_COST)
	local tc=g:GetFirst()
	local atk=tc:GetBaseAttack()
	e:SetLabel(atk)
end
-- 筛选场上正面表示且具有攻击力或守备力的怪兽
function c47077697.adfilter(c)
	return c:IsFaceup() and c:GetAttack()>0 or c:GetDefense()>0
end
-- 设置效果处理的目标
function c47077697.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查对方场上是否存在正面表示的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c47077697.adfilter,tp,0,LOCATION_MZONE,1,nil) end
end
-- 对对方场上所有正面表示的怪兽造成攻击力和守备力下降效果
function c47077697.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local atk=e:GetLabel()
	-- 获取对方场上所有正面表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		-- 为选中的怪兽添加攻击力下降效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(-atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
end
