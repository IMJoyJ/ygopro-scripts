--忍法 影縫いの術
-- 效果：
-- 把自己场上1只名字带有「忍者」的怪兽解放才能发动。选择对方场上1只怪兽从游戏中除外。只要那只怪兽从游戏中除外中，那个怪兽卡区域不能使用。这张卡从场上离开时，这个效果除外的怪兽以相同表示形式回到原本的怪兽卡区域。
function c13629812.initial_effect(c)
	-- 把自己场上1只名字带有「忍者」的怪兽解放才能发动。选择对方场上1只怪兽从游戏中除外。只要那只怪兽从游戏中除外中，那个怪兽卡区域不能使用。
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
-- 发动代价：从自己场上选择并解放1只名字带有「忍者」的怪兽。
function c13629812.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动合法性检查时，确认自己场上是否存在至少1只可解放的「忍者」怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsSetCard,1,nil,0x2b) end
	-- 让玩家从自己场上选择1只名字带有「忍者」的怪兽作为解放对象。
	local g=Duel.SelectReleaseGroup(tp,Card.IsSetCard,1,1,nil,0x2b)
	-- 将选择的「忍者」怪兽解放，作为发动代价。
	Duel.Release(g,REASON_COST)
end
-- 过滤器：判断卡片是否可以被除外（满足可除外条件）。
function c13629812.filter(c)
	return c:IsAbleToRemove()
end
-- 效果发动时的对象选择：选择对方场上1只怪兽作为除外对象。
function c13629812.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c13629812.filter(chkc) end
	-- 在发动合法性检查时，确认对方场上是否存在至少1只可以成为对象的怪兽。
	if chk==0 then return Duel.IsExistingTarget(c13629812.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要除外的卡片，弹出选择消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从对方场上选择1只怪兽，并设置为效果对象。
	local g=Duel.SelectTarget(tp,c13629812.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息：本次处理将进行1只怪兽的除外。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果处理：将对象怪兽暂时除外，并封印其原本的怪兽区域。
function c13629812.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得效果处理时选择的1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 计算对象怪兽所在怪兽区域的格子位置，转换为全局区域掩码，用于后续无效该区域。
	local val=aux.SequenceToGlobal(tc:GetControler(),LOCATION_MZONE,tc:GetSequence())
	-- 确认对象仍然关联此效果且能被除外，执行暂时除外；若成功且对象在除外区，则继续封印区域。
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 and tc:IsLocation(LOCATION_REMOVED) then
		c:SetCardTarget(tc)
		-- 只要那只怪兽从游戏中除外中，那个怪兽卡区域不能使用。
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
-- 无效区域效果的发动条件：只要此卡仍有通过效果关联的被除外的怪兽，就持续封印该区域。
function c13629812.discon(e)
	return e:GetHandler():GetCardTargetCount()>0
end
-- 离场回场效果的触发条件：此卡离场时，存在因本卡效果被除外且仍在除外区的对象怪兽。
function c13629812.retcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_REMOVED) then
		e:SetLabelObject(tc)
		tc:CreateEffectRelation(e)
		return true
	else return false end
end
-- 离场回场效果处理：将被除外的对象怪兽以离场前的形式返回其原本的怪兽区域。
function c13629812.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	if tc:IsRelateToEffect(e) then
		local zone=0x1<<tc:GetPreviousSequence()
		-- 将对象怪兽返回场上，表示形式取离场前的形式，并且只允许回到其原来的怪兽格子。
		Duel.ReturnToField(tc,tc:GetPreviousPosition(),zone)
	end
end
