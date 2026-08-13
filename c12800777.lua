--風の精霊 ガルーダ
-- 效果：
-- 这张卡不能通常召唤。从自己墓地把1只风属性怪兽除外的场合可以特殊召唤。
-- ①：对方结束阶段，以对方场上1只表侧表示怪兽为对象才能发动。那只对方的表侧表示怪兽的表示形式变更。
function c12800777.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。从自己墓地把1只风属性怪兽除外的场合可以特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c12800777.spcon)
	e1:SetTarget(c12800777.sptg)
	e1:SetOperation(c12800777.spop)
	c:RegisterEffect(e1)
	-- ①：对方结束阶段，以对方场上1只表侧表示怪兽为对象才能发动。那只对方的表侧表示怪兽的表示形式变更。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(12800777,0))  --"改变表示形式"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCondition(c12800777.poscon)
	e2:SetTarget(c12800777.postg)
	e2:SetOperation(c12800777.posop)
	c:RegisterEffect(e2)
end
-- 过滤函数：判定卡片是否可作为特殊召唤的代价从墓地除外，要求该卡是风属性且满足可作为代价除外的条件。
function c12800777.spfilter(c)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsAbleToRemoveAsCost()
end
-- 特殊召唤条件判定：若c为空则返回true；否则检查自己场上是否有可用怪兽区域，以及自己墓地是否存在至少1张可作为代价除外的风属性怪兽，满足即可进行特殊召唤。
function c12800777.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否存在可用的主要怪兽区域空格，用于放置要特殊召唤的这张卡。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1张满足spfilter条件的卡（风属性且可作为代价除外），作为除外的素材。
		and Duel.IsExistingMatchingCard(c12800777.spfilter,tp,LOCATION_GRAVE,0,1,nil)
end
-- 选择作为特殊召唤代价的卡：获取所有符合条件的墓地风属性怪兽，提示玩家选择1张要除外的卡，并把选中的卡记录到效果对象中；选择成功则允许发动特殊召唤。
function c12800777.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己墓地中所有满足spfilter条件的风属性怪兽，构成可选择的卡组。
	local g=Duel.GetMatchingGroup(c12800777.spfilter,tp,LOCATION_GRAVE,0,nil)
	-- 向玩家显示选择提示消息，要求其选择一张要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤处理：在特殊召唤成功时，将之前记录在效果LabelObject中的那张卡从墓地除外，完成特殊召唤代价。
function c12800777.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将从墓地选定的1张风属性怪兽以表侧表示除外，作为特殊召唤的代价。
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
end
-- ①效果的发动条件判定：判断当前是否为对方回合（通过当前回合玩家不是本卡控制者），从而满足“对方结束阶段”的发动时机。
function c12800777.poscon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否不是本卡的控制者，即处于对方回合，对应效果原文中的“对方结束阶段”。
	return Duel.GetTurnPlayer()~=tp
end
-- 过滤函数：判断怪兽是否为表侧表示且可以用效果变更表示形式，用于选择①效果的对象。
function c12800777.filter(c)
	return c:IsFaceup() and c:IsCanChangePosition()
end
-- ①效果的发动条件和目标选择：若指定对象则验证对象合法；否则在发动确认阶段检查对方场上是否有合法目标，并选择1只对方场上的表侧表示且可变更表示形式的怪兽作为对象，同时设置操作信息为变更表示形式。
function c12800777.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c12800777.filter(chkc) end
	-- 在发动确认阶段（chk==0）时，检查对方场上是否存在至少1只可作为对象的表侧表示且可变更表示形式的怪兽，若无则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c12800777.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家显示选择提示消息，要求其选择要变更表示形式的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 让玩家从对方场上选择1只符合条件的怪兽作为效果对象，并自动将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c12800777.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设定本连锁操作信息：将执行变更表示形式分类的效果，目标为所选择的1张卡，用于其他效果对该连锁的识别和回应。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- ①效果处理：取出对象怪兽，若该卡仍存在于场上且与效果关联，并保持表侧表示，则将其表示形式反转（表侧攻击与表侧守备互换）。
function c12800777.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的对象卡（此处只有1张对象，所以取第一张）。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 变更对象怪兽的表示形式：若其当前是表侧攻击表示则变为表侧守备表示，若当前是表侧守备表示则变为表侧攻击表示，实现“表示形式变更”。
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,0,POS_FACEUP_ATTACK,0)
	end
end
