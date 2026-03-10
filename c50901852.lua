--機巧菟－稻羽之淤岐素
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡召唤成功时才能发动。攻击力和守备力的数值相同的1只机械族怪兽从手卡守备表示特殊召唤。
-- ②：把墓地的这张卡除外，以自己场上1只攻击力和守备力的数值相同的机械族怪兽为对象才能发动。这个回合，自己不用那只怪兽不能攻击宣言，那只怪兽的攻击力·守备力变成自己场上的攻击力和守备力的数值相同的机械族怪兽的原本攻击力合计数值。
function c50901852.initial_effect(c)
	-- ①：这张卡召唤成功时才能发动。攻击力和守备力的数值相同的1只机械族怪兽从手卡守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(50901852,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c50901852.sptg)
	e1:SetOperation(c50901852.spop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己场上1只攻击力和守备力的数值相同的机械族怪兽为对象才能发动。这个回合，自己不用那只怪兽不能攻击宣言，那只怪兽的攻击力·守备力变成自己场上的攻击力和守备力的数值相同的机械族怪兽的原本攻击力合计数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(50901852,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	-- 将此卡除外作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetCountLimit(1,50901852)
	e2:SetTarget(c50901852.atktg)
	e2:SetOperation(c50901852.atkop)
	c:RegisterEffect(e2)
end
-- 过滤函数：检查手牌中是否满足条件的机械族怪兽（攻击等于守备且可特殊召唤）
function c50901852.spfilter(c,e,tp)
	-- 检查目标怪兽的攻击是否等于守备且为机械族
	return aux.AtkEqualsDef(c) and c:IsRace(RACE_MACHINE)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果发动时的check阶段：判断场上是否有空位并是否存在满足条件的怪兽
function c50901852.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手牌中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c50901852.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：准备特殊召唤1只机械族怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理函数：选择并特殊召唤符合条件的怪兽
function c50901852.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否还有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌中选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c50901852.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上（守备表示）
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 过滤函数：检查场上是否满足条件的机械族怪兽（攻击等于守备且表侧表示）
function c50901852.atkfilter(c)
	-- 检查目标怪兽是否为表侧表示、攻击等于守备且为机械族
	return c:IsFaceup() and aux.AtkEqualsDef(c) and c:IsRace(RACE_MACHINE)
end
-- 过滤函数：检查目标怪兽是否不等于指定攻击力和守备力
function c50901852.cfilter(c,atk)
	return c50901852.atkfilter(c) and not (c:IsAttack(atk) and c:IsDefense(atk))
end
-- 效果发动时的check阶段：获取场上满足条件的怪兽并选择目标对象
function c50901852.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取场上所有满足条件的怪兽（攻击等于守备且为机械族）
	local g=Duel.GetMatchingGroup(c50901852.atkfilter,tp,LOCATION_MZONE,0,nil)
	local atk=0
	if g:GetCount()>0 then atk=g:GetSum(Card.GetBaseAttack) end
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c50901852.cfilter(chkc,atk) end
	-- 判断是否存在满足条件的目标怪兽
	if chk==0 then return g:GetCount()>0 and Duel.IsExistingTarget(c50901852.cfilter,tp,LOCATION_MZONE,0,1,nil,atk) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 从场上选择满足条件的目标怪兽
	local g=Duel.SelectTarget(tp,c50901852.cfilter,tp,LOCATION_MZONE,0,1,1,nil,atk)
	-- 设置操作信息：准备将目标怪兽送入墓地
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 效果处理函数：设置目标怪兽的攻击力和守备力，并禁止其攻击宣言
function c50901852.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local atk=0
		-- 获取场上所有满足条件的怪兽（攻击等于守备且为机械族）
		local g=Duel.GetMatchingGroup(c50901852.atkfilter,tp,LOCATION_MZONE,0,nil)
		if g:GetCount()>0 then atk=g:GetSum(Card.GetBaseAttack) end
		-- 将目标怪兽的攻击力设置为场上满足条件的怪兽的原始攻击力总和
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		tc:RegisterEffect(e2)
		-- 创建一个禁止该怪兽攻击宣言的效果
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
		e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e3:SetTargetRange(LOCATION_MZONE,0)
		e3:SetTarget(c50901852.ftarget)
		e3:SetLabel(tc:GetFieldID())
		e3:SetReset(RESET_PHASE+PHASE_END)
		-- 注册禁止攻击宣言的效果
		Duel.RegisterEffect(e3,tp)
	end
end
-- 用于判断是否禁止某只怪兽攻击的函数
function c50901852.ftarget(e,c)
	return e:GetLabel()~=c:GetFieldID()
end
