--エンシェント・ゴッド・フレムベル
-- 效果：
-- 炎属性调整＋调整以外的炎族怪兽1只以上
-- 这张卡同调召唤成功时，选择最多有对方手卡数量的对方墓地存在的卡从游戏中除外。这张卡的攻击力上升这个效果除外的卡数量×200的数值。
function c26304459.initial_effect(c)
	-- 为这张卡添加同调召唤手续：调整必须为炎属性怪兽，调整以外的怪兽必须为炎族怪兽1只以上。
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_FIRE),aux.NonTuner(Card.IsRace,RACE_PYRO),1)
	c:EnableReviveLimit()
	-- 对应原效果：这张卡同调召唤成功时，选择最多有对方手卡数量的对方墓地存在的卡从游戏中除外。这张卡的攻击力上升这个效果除外的卡数量×200的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(26304459,0))  --"除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c26304459.remcon)
	e1:SetTarget(c26304459.remtg)
	e1:SetOperation(c26304459.remop)
	c:RegisterEffect(e1)
end
-- 同调召唤成功时，判断这张卡是否以同调召唤方式特殊召唤成功，是则满足必发效果的发动条件。
function c26304459.remcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 效果发动的判定阶段：该效果为必发且不取对象，满足条件即返回true；同时将本次连锁的操作信息预设为除外对方墓地的卡。
function c26304459.remtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：除外类别，目标预定为对方墓地，数量参数预置为1（实际数量在效果处理时按对方手牌数决定），因为不取对象故targets为nil。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_GRAVE)
end
-- 效果处理时：先获取对方手牌数作为最多可除外数，若为0则直接结束；然后提示玩家选择要除外的卡，并用选择函数从对方墓地选出1至该数量张可除外的卡；若选出了卡则将其除外，随后若这张卡仍在场上且与效果关联未被重置，则赋予它攻击力上升所选卡数×200的效果。
function c26304459.remop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方当前手牌数量，作为本次效果最多可除外的卡数上限。
	local ht=Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)
	if ht==0 then return end
	-- 向操作玩家发送选择提示，提示内容为“请选择要除外的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 由玩家从对方墓地选择1到对方手牌数量张满足除外条件的卡，返回选中的卡组（该选择在效果处理时进行）。
	local rg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,ht,nil)
	local c=e:GetHandler()
	if rg:GetCount()>0 then
		-- 将选择的卡以表侧表示从游戏中除外，除外原因为卡片效果。
		Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
		if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
		-- 对应原效果：这张卡的攻击力上升这个效果除外的卡数量×200的数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(rg:GetCount()*200)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
