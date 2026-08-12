--E・HERO ブラック・ネオス
-- 效果：
-- 「元素英雄 新宇侠」＋「新空间侠·黑暗豹」
-- 把自己场上存在的上记的卡回到卡组的场合才能从额外卡组特殊召唤（不需要「融合」）。可以选择场上表侧表示存在的1只效果怪兽。只要这张卡在自己场上表侧表示存在，选择的怪兽直到从场上离开效果无效化（这个效果可以选择的怪兽最多1只）。结束阶段时这张卡回到额外卡组。
function c28677304.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用卡号为89943723和43237273的两只怪兽作为融合素材
	aux.AddFusionProcCode2(c,89943723,43237273,false,false)
	-- 添加接触融合特殊召唤规则，要求将场上符合条件的素材怪兽送回卡组作为召唤条件
	aux.AddContactFusionProcedure(c,Card.IsAbleToDeckOrExtraAsCost,LOCATION_ONFIELD,0,aux.ContactFusionSendToDeck(c))
	-- 特殊召唤条件：此卡不能从额外卡组特殊召唤，必须从其他位置特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c28677304.splimit)
	c:RegisterEffect(e1)
	-- 注册结束阶段返回卡组效果，使此卡在结束阶段回到额外卡组
	aux.EnableNeosReturn(c,c28677304.retop)
	-- 起动效果：选择场上表侧表示存在的1只效果怪兽，只要此卡在场上存在，选择的怪兽效果无效
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(28677304,1))  --"效果无效"
	e5:SetCategory(CATEGORY_DISABLE)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetCondition(c28677304.discon)
	e5:SetTarget(c28677304.distg)
	e5:SetOperation(c28677304.disop)
	c:RegisterEffect(e5)
end
c28677304.material_setcode=0x8
-- 返回卡组效果的触发条件：此卡必须在场上且处于表侧表示状态
function c28677304.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA)
end
-- 结束阶段返回卡组操作：将此卡送回卡组并洗牌
function c28677304.retop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) or e:GetHandler():IsFacedown() then return end
	-- 将此卡送回卡组并洗牌
	Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
-- 效果无效化条件：此卡未选择目标怪兽时才能发动
function c28677304.discon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetCardTargetCount()==0
end
-- 筛选目标怪兽：选择场上表侧表示的效果怪兽
function c28677304.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT)
end
-- 选择目标怪兽：选择场上表侧表示的效果怪兽作为效果无效化对象
function c28677304.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c28677304.filter(chkc) end
	-- 判断是否能选择目标怪兽：场上存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c28677304.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择目标怪兽：请选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择目标怪兽：从场上选择1只表侧表示的效果怪兽
	local g=Duel.SelectTarget(tp,c28677304.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息：确定要使目标怪兽效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 效果无效化操作：将目标怪兽的效果无效化
function c28677304.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		c:SetCardTarget(tc)
		-- 注册效果无效化效果：使目标怪兽的效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetCondition(c28677304.rcon)
		tc:RegisterEffect(e1,true)
	end
end
-- 效果无效化条件：当目标怪兽离开场上的时候效果无效
function c28677304.rcon(e)
	return e:GetOwner():IsHasCardTarget(e:GetHandler())
end
