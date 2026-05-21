--スカル・クラーケン
-- 效果：
-- 这张卡召唤成功时，可以选择对方场上表侧表示存在的1张魔法卡破坏。1回合1次，可以把这张卡的表示形式变更。
function c98649372.initial_effect(c)
	-- 这张卡召唤成功时，可以选择对方场上表侧表示存在的1张魔法卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(98649372,0))  --"魔法破坏"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c98649372.destg)
	e1:SetOperation(c98649372.desop)
	c:RegisterEffect(e1)
	-- 1回合1次，可以把这张卡的表示形式变更。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(98649372,1))  --"改变表示形式"
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetOperation(c98649372.posop)
	c:RegisterEffect(e2)
end
-- 过滤对方场上表侧表示的魔法卡
function c98649372.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL)
end
-- 召唤成功时破坏魔法卡效果的发动准备（选择对象与设置操作信息）
function c98649372.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c98649372.filter(chkc) end
	-- 检查对方场上是否存在可以作为对象的表侧表示魔法卡
	if chk==0 then return Duel.IsExistingTarget(c98649372.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张表侧表示的魔法卡作为效果对象
	local g=Duel.SelectTarget(tp,c98649372.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息，表示该效果的操作分类为破坏，数量为1
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 召唤成功时破坏魔法卡效果的实际处理（破坏选择的对象）
function c98649372.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果将目标卡片破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 变更自身表示形式效果的实际处理
function c98649372.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 改变这张卡的表示形式（表侧守备表示与表侧攻击表示之间切换）
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end
