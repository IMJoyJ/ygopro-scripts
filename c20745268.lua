--魔弾－デスペラード
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有「魔弹」怪兽存在的场合，以场上1张表侧表示卡为对象才能发动。那张卡破坏。
function c20745268.initial_effect(c)
	-- 效果原文内容：①：自己场上有「魔弹」怪兽存在的场合，以场上1张表侧表示卡为对象才能发动。那张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,20745268+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c20745268.condition)
	e1:SetTarget(c20745268.target)
	e1:SetOperation(c20745268.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：检查目标怪兽是否为表侧表示且属于魔弹卡组
function c20745268.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x108)
end
-- 效果作用：判断自己场上是否存在魔弹怪兽
function c20745268.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：判断自己场上是否存在魔弹怪兽
	return Duel.IsExistingMatchingCard(c20745268.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果作用：设置发动时的选择目标
function c20745268.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc:IsFaceup() and chkc~=c end
	-- 效果作用：判断是否满足发动条件
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
	-- 效果作用：提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 效果作用：选择场上一张表侧表示的卡作为破坏对象
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c)
	-- 效果作用：设置破坏效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果作用：执行破坏效果
function c20745268.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 效果作用：将目标卡破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
