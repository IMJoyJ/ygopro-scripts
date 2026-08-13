--E・HERO ブラック・ネオス
-- 效果：
-- 「元素英雄 新宇侠」＋「新空间侠·黑暗豹」
-- 把自己场上存在的上记的卡回到卡组的场合才能从额外卡组特殊召唤（不需要「融合」）。可以选择场上表侧表示存在的1只效果怪兽。只要这张卡在自己场上表侧表示存在，选择的怪兽直到从场上离开效果无效化（这个效果可以选择的怪兽最多1只）。结束阶段时这张卡回到额外卡组。
function c28677304.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡注册以「元素英雄 新宇侠」(89943723)和「新空间侠·黑暗豹」(43237273)为素材的融合召唤手续，满足素材要求即可进行融合召唤。
	aux.AddFusionProcCode2(c,89943723,43237273,false,false)
	-- 注册接触融合手续：把自己场上满足条件的怪兽作为融合素材，通过送回卡组·额外卡组的方式从额外卡组特殊召唤这张卡（不需要融合魔法），素材送回卡组并洗牌。
	aux.AddContactFusionProcedure(c,Card.IsAbleToDeckOrExtraAsCost,LOCATION_ONFIELD,0,aux.ContactFusionSendToDeck(c))
	-- 让自己场上的上记的卡回到卡组·额外卡组的场合才能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c28677304.splimit)
	c:RegisterEffect(e1)
	-- 调用通用函数注册②的结束阶段回额外效果：自己·对方的结束阶段，这张卡回到额外卡组；retop为具体执行回额外卡组的操作。
	aux.EnableNeosReturn(c,c28677304.retop)
	-- ①：以场上1只效果怪兽为对象才能发动。这只怪兽表侧表示存在期间，作为对象的怪兽的效果无效化（这个效果可以作为对象的怪兽最多1只）。
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
-- 特殊召唤条件限制：仅在从额外卡组进行特殊召唤时才被允许，相当于限制这张卡只能从额外卡组特殊召唤。
function c28677304.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA)
end
-- 结束阶段回额外卡组的处理函数：若这张卡仍与效果相关且表侧表示，则执行回额外卡组的操作，否则该处理不适用。
function c28677304.retop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) or e:GetHandler():IsFacedown() then return end
	-- 将这张卡送回持有者卡组并洗牌，作为结束阶段回额外卡组的实际结算。
	Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
-- ①效果的发动条件：这张卡当前没有正在无效化的对象，以此保证这个效果最多只能选择1只对象怪兽。
function c28677304.discon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetCardTargetCount()==0
end
-- 选择目标时的过滤条件：必须是场上表侧表示的效果怪兽。
function c28677304.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT)
end
-- ①效果的目标选择处理：效果发动时检查是否存在合法对象，并让玩家从双方场上选择1只表侧表示效果怪兽作为对象，同时登记无效化操作信息。
function c28677304.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c28677304.filter(chkc) end
	-- 效果发动可行性检查：场上存在至少1只表侧表示效果怪兽可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c28677304.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 给玩家弹出『请选择表侧表示的卡』的选卡提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从双方场上选择1只表侧表示效果怪兽，并将其设为当前连锁的取对象目标。
	local g=Duel.SelectTarget(tp,c28677304.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 登记本次操作信息：将「使效果无效」1只怪兽的处理类别写入连锁信息，供连锁判定和后续处理使用。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- ①效果处理：若此卡仍与效果相关、对象怪兽仍表侧且与效果相关、并且不免疫此效果，则将此卡设为对象怪兽的永续对象，并给对象怪兽赋予持续的效果无效化状态。
function c28677304.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得发动时所选择的1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		c:SetCardTarget(tc)
		-- 这只怪兽表侧表示存在期间，作为对象的怪兽的效果无效化。
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
-- 无效化持续条件：只有效果所有者（这张卡）仍将对象怪兽作为永续对象时，无效化效果才继续适用，对应『这张卡表侧表示存在期间』的限制。
function c28677304.rcon(e)
	return e:GetOwner():IsHasCardTarget(e:GetHandler())
end
