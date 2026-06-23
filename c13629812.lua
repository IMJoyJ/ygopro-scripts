--忍法 影縫いの術
-- 效果：
-- 把自己场上1只名字带有「忍者」的怪兽解放才能发动。选择对方场上1只怪兽从游戏中除外。只要那只怪兽从游戏中除外中，那个怪兽卡区域不能使用。这张卡从场上离开时，这个效果除外的怪兽以相同表示形式回到原本的怪兽卡区域。
function c13629812.initial_effect(c)
	-- 发动时支付代价：解放1只名字带有「忍者」的怪兽。选择对方场上1只怪兽从游戏中除外。只要那只怪兽从游戏中除外中，那个怪兽卡区域不能使用。这张卡从场上离开时，这个效果除外的怪兽以相同表示形式回到原本的怪兽卡区域。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCost(c13629812.cost)
	e1:SetTarget(c13629812.target)
	e1:SetOperation(c13629812.operation)
	c:RegisterEffect(e1)
	-- 这张卡从场上离开时，这个效果除外的怪兽以相同表示形式回到原本的怪兽卡区域。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(13629812,0))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCondition(c13629812.retcon)
	e2:SetOperation(c13629812.retop)
	c:RegisterEffect(e2)
end
-- 检查玩家场上是否存在至少1张名字带有「忍者」的可解放的怪兽
function c13629812.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否存在至少1张名字带有「忍者」的可解放的怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsSetCard,1,nil,0x2b) end
	-- 让玩家从场上选择1张名字带有「忍者」的可解放的怪兽
	local g=Duel.SelectReleaseGroup(tp,Card.IsSetCard,1,1,nil,0x2b)
	-- 以支付代价的形式解放选择的怪兽
	Duel.Release(g,REASON_COST)
end
-- 过滤函数，用于判断目标怪兽是否可以被除外
function c13629812.filter(c)
	return c:IsAbleToRemove()
end
-- 选择对方场上1只可以被除外的怪兽作为效果对象
function c13629812.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c13629812.filter(chkc) end
	-- 检查对方场上是否存在至少1只可以被除外的怪兽
	if chk==0 then return Duel.IsExistingTarget(c13629812.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家提示“请选择要除外的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从对方场上选择1只可以被除外的怪兽
	local g=Duel.SelectTarget(tp,c13629812.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息，确定要除外的怪兽数量为1
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 处理效果的发动，将目标怪兽除外并设置无效区域效果
function c13629812.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 将目标怪兽的位置信息转换为全局位掩码值
	local val=aux.SequenceToGlobal(tc:GetControler(),LOCATION_MZONE,tc:GetSequence())
	-- 判断目标怪兽是否仍然在连锁效果中且成功被除外
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 and tc:IsLocation(LOCATION_REMOVED) then
		c:SetCardTarget(tc)
		-- 创建一个无效区域效果，用于阻止目标怪兽所在区域被使用
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_DISABLE_FIELD)
		e1:SetRange(LOCATION_SZONE)
		e1:SetCondition(c13629812.discon)
		e1:SetValue(val)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end
-- 无效区域效果的触发条件，当此卡有目标怪兽时触发
function c13629812.discon(e)
	return e:GetHandler():GetCardTargetCount()>0
end
-- 判断此卡的效果是否在场且目标怪兽处于除外状态
function c13629812.retcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_REMOVED) then
		e:SetLabelObject(tc)
		tc:CreateEffectRelation(e)
		return true
	else return false end
end
-- 将目标怪兽以原表示形式返回到其原本的怪兽卡区域
function c13629812.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	if tc:IsRelateToEffect(e) then
		local zone=0x1<<tc:GetPreviousSequence()
		-- 将目标怪兽以原表示形式返回到其原本的怪兽卡区域
		Duel.ReturnToField(tc,tc:GetPreviousPosition(),zone)
	end
end
