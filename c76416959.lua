--戦華の義－関雲
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：只有对方场上才有怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：只要这张卡在怪兽区域存在，自己场上的其他的「战华」怪兽不会成为对方的效果的对象。
-- ③：对方场上的怪兽数量比自己场上的怪兽多的场合，以对方场上1只怪兽为对象才能发动。那只怪兽破坏。
function c76416959.initial_effect(c)
	-- ①：只有对方场上才有怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(76416959,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c76416959.spcon)
	e1:SetTarget(c76416959.sptg)
	e1:SetOperation(c76416959.spop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，自己场上的其他的「战华」怪兽不会成为对方的效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c76416959.etlimit)
	-- 设置抗性效果的判定，使其仅对对方的效果生效（不会成为对方的效果的对象）
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- 这个卡名的③的效果1回合只能使用1次。③：对方场上的怪兽数量比自己场上的怪兽多的场合，以对方场上1只怪兽为对象才能发动。那只怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(76416959,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,76416959)
	e3:SetCondition(c76416959.descon)
	e3:SetTarget(c76416959.destg)
	e3:SetOperation(c76416959.desop)
	c:RegisterEffect(e3)
end
-- ①号效果（手卡特殊召唤）的发动条件判定函数
function c76416959.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检测自己场上没有怪兽且对方场上有怪兽存在
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 and Duel.GetFieldGroupCount(1-tp,LOCATION_MZONE,0)>0
end
-- ①号效果（手卡特殊召唤）的发动准备与合法性检测函数
function c76416959.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检测自己场上是否有可用的怪兽区域，且自身是否可以特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理中的操作信息为特殊召唤这张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①号效果（手卡特殊召唤）的效果处理函数
function c76416959.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤出自己场上除自身以外的表侧表示「战华」怪兽作为抗性适用对象
function c76416959.etlimit(e,c)
	return c~=e:GetHandler() and c:IsFaceup() and c:IsSetCard(0x137)
end
-- ③号效果（破坏怪兽）的发动条件判定函数
function c76416959.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检测对方场上的怪兽数量是否比自己场上的怪兽多
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)<Duel.GetFieldGroupCount(1-tp,LOCATION_MZONE,0)
end
-- ③号效果（破坏怪兽）的对象选择与合法性检测函数
function c76416959.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 在发动阶段，检测对方场上是否存在可以作为效果对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 在客户端提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择对方场上1只怪兽作为效果对象并进行锁定
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁处理中的操作信息为破坏选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ③号效果（破坏怪兽）的效果处理函数
function c76416959.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将作为效果对象的怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
