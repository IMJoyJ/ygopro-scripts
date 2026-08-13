--バーサーカークラッシュ
-- 效果：
-- 把自己墓地存在的1只怪兽从游戏中除外发动。直到这个回合的结束阶段时，自己场上表侧表示存在的1只「羽翼栗子球」的攻击力·守备力变成和除外怪兽相同数值。
function c15471265.initial_effect(c)
	-- 把自己墓地存在的1只怪兽从游戏中除外发动。直到这个回合的结束阶段时，自己场上表侧表示存在的1只「羽翼栗子球」的攻击力·守备力变成和除外怪兽相同数值。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置效果发动条件，限定为伤害步骤且伤害计算前才能发动（伤害步骤中只能在此类时点发动）。
	e1:SetCondition(aux.dscon)
	e1:SetCost(c15471265.cost)
	e1:SetTarget(c15471265.target)
	e1:SetOperation(c15471265.activate)
	c:RegisterEffect(e1)
end
-- 定义代价筛选条件：该卡必须是怪兽且可以作为除外代价。
function c15471265.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 执行代价处理：确认墓地存在符合条件的怪兽，玩家选择其中1只，将其记录为代价对象，然后将其表侧除外。
function c15471265.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测阶段：检查自己墓地是否至少有1只满足cfilter的怪兽，若没有则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c15471265.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家发送选择提示消息“请选择要除外的卡”，用于后续选择卡片的界面提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1只满足cfilter的怪兽作为发动代价。
	local g=Duel.SelectMatchingCard(tp,c15471265.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	e:SetLabelObject(g:GetFirst())
	-- 将选择的代价怪兽以表侧表示除外，除外原因是作为代价（REASON_COST）。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 定义对象筛选条件：该卡必须表侧表示且卡名为「羽翼栗子球」（57116033）。
function c15471265.filter(c)
	return c:IsFaceup() and c:IsCode(57116033)
end
-- 效果发动时的对象处理：确认存在可选的「羽翼栗子球」，让玩家选择自己场上1只表侧表示的目标并设为对象。
function c15471265.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c15471265.filter(chkc) end
	-- 对象检测阶段：检查自己场上是否存在至少1只满足filter的「羽翼栗子球」，若没有则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c15471265.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家发送选择提示消息“请选择表侧表示的卡”，用于后续选择卡片的界面提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从自己场上表侧表示的怪兽中选择1只「羽翼栗子球」作为效果对象，并自动与当前连锁建立对象关系。
	local g=Duel.SelectTarget(tp,c15471265.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：取得对象怪兽和作为代价除外的怪兽，若对象仍在场上且表侧表示，则将对象怪兽的攻击力、守备力分别变为除外怪兽的记载数值，直到结束阶段。
function c15471265.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时的对象怪兽（即选择的「羽翼栗子球」）。
	local tc=Duel.GetFirstTarget()
	local rc=e:GetLabelObject()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 攻击力变成和除外怪兽相同数值
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(rc:GetTextAttack())
		tc:RegisterEffect(e1)
		-- 守备力变成和除外怪兽相同数值
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetValue(rc:GetTextDefense())
		tc:RegisterEffect(e2)
	end
end
