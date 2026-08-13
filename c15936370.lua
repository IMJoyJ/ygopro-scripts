--パンドラの宝具箱
-- 效果：
-- ←4 【灵摆】 4→
-- ①：自己的额外卡组没有卡存在的场合，以对方的灵摆区域1张卡为对象才能发动。那张卡破坏，灵摆区域的这张卡在对方的灵摆区域放置。
-- 【怪兽效果】
-- ①：只要自己的额外卡组没有卡存在并有这张卡在怪兽区域存在，自己抽卡阶段的通常抽卡变成2张。
function c15936370.initial_effect(c)
	-- 为这张卡添加灵摆召唤及灵摆卡发动所需的基础属性，使其能作为灵摆怪兽正常使用。
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
	-- 【怪兽效果】①：只要自己的额外卡组没有卡存在并有这张卡在怪兽区域存在，自己抽卡阶段的通常抽卡变成2张。
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
-- 定义灵摆效果的发动条件判定函数，该函数用于检查自己额外卡组中是否没有卡。
function c15936370.pencon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查本方额外卡组的卡片数量是否为0，作为灵摆效果能否发动的条件。
	return Duel.GetFieldGroupCount(tp,LOCATION_EXTRA,0)==0
end
-- 定义灵摆效果的发动时处理函数：进行取对象合法性检查，并从对方灵摆区域选择1张卡作为对象。
function c15936370.pentg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_PZONE) and chkc:IsControler(1-tp) end
	-- 在效果发动的合法检查阶段，确认对方灵摆区域是否存在至少1张可以选择为对象的卡。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_PZONE,1,nil) end
	-- 向当前玩家发送“请选择要破坏的卡”的选择提示消息，用于后续的选择操作。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从对方的灵摆区域选择1张卡作为效果对象，并将其注册为当前连锁的处理对象。
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_PZONE,1,1,nil)
	-- 设置本次效果处理的破坏分类操作信息，将选中的对象卡作为破坏对象，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 定义灵摆效果处理时的执行函数：破坏对象卡，成功后把这张灵摆怪兽放置到对方灵摆区域。
function c15936370.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 获取当前连锁中记录的第一张对象卡，即对方灵摆区域被选择的卡。
	local tc=Duel.GetFirstTarget()
	-- 确认对象卡仍与本次效果关联后，将其以效果原因破坏；若破坏成功则继续后续处理。
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 将这张灵摆卡以表侧表示移动到对方玩家的灵摆区域，并使其效果立即适用。
		Duel.MoveToField(c,tp,1-tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
-- 定义怪兽效果（抽卡数增加）的适用条件判定函数，用于检查自己额外卡组没有卡存在。
function c15936370.drcon(e)
	-- 检查效果持有者（控制者）的额外卡组卡片数量是否为0，作为抽卡阶段通常抽卡数变为2张的适用条件。
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_EXTRA,0)==0
end
