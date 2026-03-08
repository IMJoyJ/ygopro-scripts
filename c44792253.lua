--D.D.デストロイヤー
-- 效果：
-- 场上存在的这张卡从游戏中除外时，可以选择对方场上表侧表示存在的1张卡破坏。
function c44792253.initial_effect(c)
	-- 创建一个诱发选发效果，效果原文：对方场上表侧表示存在的1张卡破坏
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44792253,0))  --"对方场上表侧表示存在的1张卡破坏"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_REMOVE)
	e1:SetCondition(c44792253.descon)
	e1:SetTarget(c44792253.destg)
	e1:SetOperation(c44792253.desop)
	c:RegisterEffect(e1)
end
-- 效果发动条件：这张卡在场上表侧表示存在且从场上离开
function c44792253.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsFaceup() and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 筛选条件：目标怪兽必须表侧表示
function c44792253.filter(c)
	return c:IsFaceup()
end
-- 效果处理目标选择：选择对方场上表侧表示的1张卡作为破坏对象
function c44792253.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c44792253.filter(chkc) end
	-- 判断是否能选择目标：对方场上是否存在表侧表示的怪兽
	if chk==0 then return Duel.IsExistingTarget(c44792253.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上表侧表示的1张卡作为破坏对象
	local g=Duel.SelectTarget(tp,c44792253.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息：将选择的卡作为破坏对象
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理执行：破坏选择的卡
function c44792253.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡以效果原因破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
