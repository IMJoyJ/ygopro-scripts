--ハイ・スピード・リレベル
-- 效果：
-- ①：把自己墓地1只「疾行机人」怪兽除外，以自己场上1只同调怪兽为对象才能发动。那只怪兽直到回合结束时变成和除外的怪兽相同等级，攻击力上升除外的怪兽的等级×500。
function c15555120.initial_effect(c)
	-- ①：把自己墓地1只「疾行机人」怪兽除外，以自己场上1只同调怪兽为对象才能发动。那只怪兽直到回合结束时变成和除外的怪兽相同等级，攻击力上升除外的怪兽的等级×500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(c15555120.cost)
	e1:SetTarget(c15555120.target)
	e1:SetOperation(c15555120.activate)
	c:RegisterEffect(e1)
end
-- 定义墓地可用作代价的怪兽筛选函数：要求该怪兽是等级大于0的「疾行机人」怪兽、可以作为代价除外，并且场上已经存在1只与其等级不同的表侧同调怪兽可作为对象，确保发动时满足所有条件。
function c15555120.cfilter(c,tp)
	local lv=c:GetLevel()
	return lv>0 and c:IsSetCard(0x2016) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
		-- 追加检查：以该墓地怪兽的等级为参数，确认我方怪兽区至少有1只表侧表示且等级不同的同调怪兽能够成为这张卡的对象，保证除外后可以选择合法对象。
		and Duel.IsExistingTarget(c15555120.filter,tp,LOCATION_MZONE,0,1,nil,lv)
end
-- 代价处理：先确认墓地有满足条件的「疾行机人」怪兽；再提示玩家选择1只；将选择的怪兽表侧表示除外作为代价，并将其等级记录到效果e的Label中供后续target/activate使用。
function c15555120.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性check：当chk==0时，检查墓地是否存在至少1只满足cfilter的「疾行机人」怪兽（cfilter已包含对场上对象存在性的判断），有则可发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c15555120.cfilter,tp,LOCATION_GRAVE,0,1,nil,tp) end
	-- 发送选择提示：让玩家在除外选择框中看到“请选择要除外的卡”的提示信息，并指定选择消息类型为HINTMSG_REMOVE。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1只满足cfilter条件的「疾行机人」怪兽，作为发动代价要除外的卡片。
	local g=Duel.SelectMatchingCard(tp,c15555120.cfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	-- 将选中的卡以表侧表示除外，除外原因是代价REASON_COST，完成cost的支付。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:SetLabel(g:GetFirst():GetLevel())
end
-- 定义取对象目标的筛选条件：对象必须是我方场上的表侧表示同调怪兽，且其当前等级与作为代价除外的怪兽等级不同，否则不能成为对象。
function c15555120.filter(c,lv)
	return c:IsFaceup() and not c:IsLevel(lv) and c:IsType(TYPE_SYNCHRO)
end
-- 目标选择处理：在连锁确认对象时检查对象是否在我方怪兽区且满足filter；发动合法性check阶段直接返回true（cost已保证有合法对象）；然后提示玩家选择1只表侧表示同调怪兽，并用Duel.SelectTarget将其登记为效果对象。
function c15555120.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c15555120.filter(chkc,e:GetLabel()) end
	if chk==0 then return true end
	-- 发送选择提示：让玩家在选择对象时看到“请选择表侧表示的卡”的提示信息，并指定选择消息类型为HINTMSG_FACEUP。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- Duel.SelectTarget：让玩家从我方怪兽区选择1只满足filter的表侧表示同调怪兽作为对象，同时将这张卡标记为当前连锁的效果对象，后续可用Duel.GetFirstTarget取得。
	Duel.SelectTarget(tp,c15555120.filter,tp,LOCATION_MZONE,0,1,1,nil,e:GetLabel())
end
-- 效果处理：取出cost阶段记录的等级lv并取得对象；若对象仍与效果关联、表侧表示且当前等级不是lv，则给对象赋予等级变为lv和攻击力上升lv×500的两个效果，二者都在回合结束时及标准离场等情况下重置。
function c15555120.activate(e,tp,eg,ep,ev,re,r,rp)
	local lv=e:GetLabel()
	-- 通过Duel.GetFirstTarget取得发动时选择的对象卡（因为只选择1张，所以直接取第一张）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsLevel(lv) then
		-- 那只怪兽直到回合结束时变成和除外的怪兽相同等级。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(lv)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 攻击力上升除外的怪兽的等级×500。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(lv*500)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
