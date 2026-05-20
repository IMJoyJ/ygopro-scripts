--インフィニティ・ダーク
-- 效果：
-- 这张卡在墓地或者场上表侧表示存在的场合，当作通常怪兽使用。场上表侧表示存在的这张卡可以作当成通常召唤使用的再度召唤，这张卡变成当作效果怪兽使用并得到以下效果。
-- ●这张卡的攻击宣言时，可以把对方场上存在的1只表侧表示怪兽的表示形式改变。
function c76520646.initial_effect(c)
	-- 初始化二重怪兽属性，使其在场上·墓地当作通常怪兽，并允许再度召唤
	aux.EnableDualAttribute(c)
	-- ●这张卡的攻击宣言时，可以把对方场上存在的1只表侧表示怪兽的表示形式改变。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(76520646,0))  --"改变表示形式"
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	-- 设置效果发动条件为自身处于再度召唤状态（二重状态）
	e1:SetCondition(aux.IsDualState)
	e1:SetTarget(c76520646.postg)
	e1:SetOperation(c76520646.posop)
	c:RegisterEffect(e1)
end
-- 过滤对方场上表侧表示且可以改变表示形式的怪兽
function c76520646.filter(c)
	return c:IsFaceup() and c:IsCanChangePosition()
end
-- 效果发动的目标选择与检测函数，用于确认是否存在合法对象并进行取对象选择
function c76520646.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c76520646.filter(chkc) end
	-- 在效果发动阶段，检测对方场上是否存在至少1只可以改变表示形式的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c76520646.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向发动效果的玩家提示选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 让玩家选择对方场上1只表侧表示怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c76520646.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息，声明该效果包含改变表示形式的操作，涉及1张卡
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 效果处理的执行函数，用于改变目标怪兽的表示形式
function c76520646.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 将目标怪兽的表示形式改变（表侧攻击表示与表侧守备表示互相转换）
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,0,POS_FACEUP_ATTACK,0)
	end
end
