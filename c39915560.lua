--スターヴ・ヴェノム・プレデター・フュージョン・ドラゴン
-- 效果：
-- 暗属性融合怪兽＋融合怪兽
-- 这个卡名在规则上也当作「捕食植物」卡使用。这个卡名的②的效果1回合只能使用1次。
-- ①：1回合1次，魔法·陷阱·怪兽的效果发动时才能发动。自己或者对方场上1只有捕食指示物放置的怪兽解放，那个发动无效。
-- ②：融合召唤的这张卡被对方送去墓地的场合，以自己墓地1只暗属性怪兽为对象才能发动。那只怪兽特殊召唤。
function c39915560.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用满足条件的暗属性怪兽和融合怪兽各1只为融合素材
	aux.AddFusionProcFun2(c,c39915560.fusmatfilter,aux.FilterBoolFunction(Card.IsFusionType,TYPE_FUSION),true)
	-- ①：1回合1次，魔法·陷阱·怪兽的效果发动时才能发动。自己或者对方场上1只有捕食指示物放置的怪兽解放，那个发动无效。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39915560,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_RELEASE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c39915560.negcon)
	e1:SetTarget(c39915560.negtg)
	e1:SetOperation(c39915560.negop)
	c:RegisterEffect(e1)
	-- ②：融合召唤的这张卡被对方送去墓地的场合，以自己墓地1只暗属性怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(39915560,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,39915560)
	e2:SetCondition(c39915560.spcon)
	e2:SetTarget(c39915560.sptg)
	e2:SetOperation(c39915560.spop)
	c:RegisterEffect(e2)
end
c39915560.mentioned_counter={
	[0x1041]=true,
}
-- 过滤函数，用于筛选满足融合条件的暗属性融合怪兽
function c39915560.fusmatfilter(c)
	return c:IsFusionAttribute(ATTRIBUTE_DARK) and c:IsFusionType(TYPE_FUSION)
end
-- 效果条件函数，判断连锁是否可以被无效且此卡未在战斗中被破坏
function c39915560.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断连锁是否可以被无效且此卡未在战斗中被破坏
	return Duel.IsChainNegatable(ev) and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 过滤函数，用于筛选场上正面表示、有捕食指示物且可因效果解放的怪兽
function c39915560.negcfilter(c)
	return c:IsFaceup() and c:GetCounter(0x1041)>0 and c:IsReleasableByEffect()
end
-- 效果目标设置函数，检查是否存在满足条件的怪兽并设置操作信息
function c39915560.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c39915560.negcfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取满足条件的怪兽数组
	local g=Duel.GetMatchingGroup(c39915560.negcfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置操作信息为使发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	-- 设置操作信息为解放指定怪兽
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,g,1,0,0)
end
-- 效果处理函数，提示选择要解放的怪兽并执行无效效果
function c39915560.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要解放的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c39915560.negcfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 判断是否成功解放了怪兽
	if #g>0 and Duel.Release(g,REASON_EFFECT)~=0 then
		-- 使连锁发动无效
		Duel.NegateActivation(ev)
	end
end
-- 效果触发条件函数，判断此卡是否为融合召唤且被对方送入墓地
function c39915560.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_FUSION) and rp==1-tp and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
end
-- 过滤函数，用于筛选满足特殊召唤条件的暗属性怪兽
function c39915560.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果目标设置函数，检查是否存在满足条件的墓地怪兽并设置操作信息
function c39915560.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c39915560.spfilter(chkc,e,tp) end
	-- 检查场上是否有足够的特殊召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在满足条件的怪兽
		and Duel.IsExistingTarget(c39915560.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的墓地怪兽作为目标
	local g=Duel.SelectTarget(tp,c39915560.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息为特殊召唤指定怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理函数，将目标怪兽特殊召唤
function c39915560.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
