--パンドラの宝具箱
-- 效果：
-- ←4 【灵摆】 4→
-- ①：自己的额外卡组没有卡存在的场合，以对方的灵摆区域1张卡为对象才能发动。那张卡破坏，灵摆区域的这张卡在对方的灵摆区域放置。
-- 【怪兽效果】
-- ①：只要自己的额外卡组没有卡存在并有这张卡在怪兽区域存在，自己抽卡阶段的通常抽卡变成2张。
function c15936370.initial_effect(c)
	-- 为灵摆怪兽添加灵摆怪兽属性，使其可以灵摆召唤和灵摆卡的发动
	aux.EnablePendulumAttribute(c)
	-- ①：自己的额外卡组没有卡存在的场合，以对方的灵摆区域1张卡为对象才能发动。那张卡破坏，灵摆区域的这张卡在对方的灵摆区域放置。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(15936370,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCondition(c15936370.pencon)
	e1:SetTarget(c15936370.pentg)
	e1:SetOperation(c15936370.penop)
	c:RegisterEffect(e1)
	-- ①：只要自己的额外卡组没有卡存在并有这张卡在怪兽区域存在，自己抽卡阶段的通常抽卡变成2张。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_DRAW_COUNT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(1,0)
	e2:SetValue(2)
	e2:SetCondition(c15936370.drcon)
	c:RegisterEffect(e2)
end
-- 判断自己的额外卡组是否没有卡存在
function c15936370.pencon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己的额外卡组是否没有卡存在
	return Duel.GetFieldGroupCount(tp,LOCATION_EXTRA,0)==0
end
-- 判断是否存在对方灵摆区域的卡作为效果对象
function c15936370.pentg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_PZONE) and chkc:IsControler(1-tp) end
	-- 提示玩家选择要破坏的卡
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_PZONE,1,nil) end
	-- 选择对方灵摆区域的一张卡作为效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 设置效果的破坏操作信息
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_PZONE,1,1,nil)
	-- 执行破坏操作并设置操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 将目标卡破坏并将其自身移动到对方灵摆区域
function c15936370.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 获取当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡是否有效并执行破坏操作
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 将自身移动到对方灵摆区域
		Duel.MoveToField(c,tp,1-tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
-- 判断自己的额外卡组是否没有卡存在
function c15936370.drcon(e)
	-- 判断自己的额外卡组是否没有卡存在
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_EXTRA,0)==0
end
