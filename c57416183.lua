--ドラゴンメイドのお片付け
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：以自己场上1只龙族怪兽和对方的场上·墓地1张卡为对象才能发动。那些卡回到手卡。
-- ②：把墓地的这张卡除外才能发动。从自己的手卡·墓地把1只「半龙女仆」怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽在结束阶段回到手卡。
function c57416183.initial_effect(c)
	-- ①：以自己场上1只龙族怪兽和对方的场上·墓地1张卡为对象才能发动。那些卡回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(57416183,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,57416183)
	e1:SetTarget(c57416183.target)
	e1:SetOperation(c57416183.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。从自己的手卡·墓地把1只「半龙女仆」怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽在结束阶段回到手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(57416183,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,57416183)
	-- 把墓地的这张卡除外作为发动的代价（Cost）
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c57416183.sptg)
	e2:SetOperation(c57416183.spop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示存在、且能回到手卡的龙族怪兽
function c57416183.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsAbleToHand()
end
-- ①号效果的发动准备与目标选择
function c57416183.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己场上是否存在至少1只符合条件的龙族怪兽
	if chk==0 then return Duel.IsExistingTarget(c57416183.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上或墓地是否存在至少1张可以回到手卡的卡
		and Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择自己场上的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELF)  --"请选择自己的卡"
	-- 选择自己场上1只符合条件的龙族怪兽作为效果对象
	local g1=Duel.SelectTarget(tp,c57416183.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 提示玩家选择对方的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPPO)  --"请选择对方的卡"
	-- 优先从对方场上（若无则从墓地）选择1张可以回到手卡的卡作为效果对象
	local g2=aux.SelectTargetFromFieldFirst(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,1,nil)
	g1:Merge(g2)
	-- 设置连锁信息，表示该效果的操作分类为“回到手卡”，操作对象为选中的卡片组
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g1,g1:GetCount(),0,0)
end
-- ①号效果的实际处理（将选中的卡送回手卡）
function c57416183.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与该效果相关的对象卡片
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 将这些卡因效果回到持有者手卡
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
	end
end
-- 过滤条件：手卡或墓地中可以守备表示特殊召唤的「半龙女仆」怪兽
function c57416183.spfilter(c,e,tp)
	return c:IsSetCard(0x133) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ②号效果的发动准备与合法性检查
function c57416183.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的手卡或墓地是否存在至少1只符合特殊召唤条件的「半龙女仆」怪兽
		and Duel.IsExistingMatchingCard(c57416183.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	-- 设置连锁信息，表示该效果的操作分类为“特殊召唤”，操作范围为手卡和墓地
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- ②号效果的实际处理（特殊召唤并注册结束阶段回手卡的效果）
function c57416183.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若此时自己场上没有可用的怪兽区域空格，则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡或墓地选择1只符合条件的「半龙女仆」怪兽（受王家长眠之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c57416183.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的怪兽以表侧守备表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		local fid=e:GetHandler():GetFieldID()
		tc:RegisterFlagEffect(57416183,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 这个效果特殊召唤的怪兽在结束阶段回到手卡。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetCondition(c57416183.thcon)
		e1:SetOperation(c57416183.thop)
		-- 注册该全局延迟效果，使其在结束阶段触发
		Duel.RegisterEffect(e1,tp)
	end
end
-- 检查特殊召唤的怪兽是否仍具有相同的标记，若已不符则重置该延迟效果
function c57416183.thcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(57416183)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 结束阶段时，执行将该怪兽送回手卡的操作
function c57416183.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 将特殊召唤的怪兽因效果送回持有者手卡
	Duel.SendtoHand(e:GetLabelObject(),nil,REASON_EFFECT)
end
