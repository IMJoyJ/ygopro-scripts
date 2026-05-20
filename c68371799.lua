--デーモンの将星
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次。
-- ①：自己场上有「恶魔」卡存在的场合，这张卡可以从手卡特殊召唤。这个回合，这张卡不能攻击。
-- ②：这张卡的①的方法特殊召唤成功的场合，以自己场上1张「恶魔」卡为对象发动。那张自己的「恶魔」卡破坏。
-- ③：这张卡上级召唤成功时，以自己墓地1只6星「恶魔」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
function c68371799.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：自己场上有「恶魔」卡存在的场合，这张卡可以从手卡特殊召唤。这个回合，这张卡不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,68371799+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c68371799.spcon)
	e1:SetOperation(c68371799.spop)
	e1:SetValue(SUMMON_VALUE_SELF)
	c:RegisterEffect(e1)
	-- ②：这张卡的①的方法特殊召唤成功的场合，以自己场上1张「恶魔」卡为对象发动。那张自己的「恶魔」卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(68371799,0))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c68371799.descon)
	e2:SetTarget(c68371799.destg)
	e2:SetOperation(c68371799.desop)
	c:RegisterEffect(e2)
	-- ③：这张卡上级召唤成功时，以自己墓地1只6星「恶魔」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(68371799,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCondition(c68371799.spcon2)
	e3:SetTarget(c68371799.sptg2)
	e3:SetOperation(c68371799.spop2)
	c:RegisterEffect(e3)
end
-- 过滤条件：场上表侧表示的「恶魔」卡
function c68371799.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x45)
end
-- 自身特殊召唤规则的判定条件
function c68371799.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否有可用的怪兽区域空格
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己场上是否存在表侧表示的「恶魔」卡
		and Duel.IsExistingMatchingCard(c68371799.filter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 自身特殊召唤规则的执行处理（添加不能攻击的效果）
function c68371799.spop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 这个回合，这张卡不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
-- 判定是否通过自身①的方法特殊召唤成功
function c68371799.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 过滤条件：自己场上表侧表示的「恶魔」卡
function c68371799.desfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x45)
end
-- 破坏效果的靶向选择（放入连锁）
function c68371799.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsOnField() and c68371799.desfilter(chkc) end
	if chk==0 then return true end
	-- 给玩家发送“选择要破坏的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上1张表侧表示的「恶魔」卡作为破坏对象
	local g=Duel.SelectTarget(tp,c68371799.desfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 设置当前连锁的操作信息为“破坏选中的卡”
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 破坏效果的执行处理
function c68371799.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 因效果破坏目标卡片
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 判定是否上级召唤成功
function c68371799.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 过滤条件：墓地中可以守备表示特殊召唤的6星「恶魔」怪兽
function c68371799.spfilter(c,e,tp)
	return c:IsLevel(6) and c:IsSetCard(0x45) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 特殊召唤效果的靶向选择（放入连锁）
function c68371799.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c68371799.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在满足条件的6星「恶魔」怪兽
		and Duel.IsExistingTarget(c68371799.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 给玩家发送“选择要特殊召唤的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的6星「恶魔」怪兽作为特殊召唤的对象
	local g=Duel.SelectTarget(tp,c68371799.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置当前连锁的操作信息为“特殊召唤选中的怪兽”
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤效果的执行处理
function c68371799.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否仍有可用的怪兽区域空格，若无则结束处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取当前连锁中被选为特殊召唤对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧守备表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
