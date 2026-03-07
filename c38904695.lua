--インフェルニティ・ヘル・デーモン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- ①：1回合1次，以场上1张表侧表示的卡为对象才能发动。那张卡的效果直到回合结束时无效。自己手卡是0张的场合，可以再把那张卡破坏。
-- ②：只要自己手卡是0张，这张卡用和对方怪兽的战斗给与对方的战斗伤害变成2倍。
-- ③：这张卡为同调素材的暗属性同调怪兽在同1次的战斗阶段中最多2次可以向怪兽攻击。
function c38904695.initial_effect(c)
	-- 为卡片添加同调召唤手续，要求1只调整，1只调整以外的怪兽作为同调素材
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：1回合1次，以场上1张表侧表示的卡为对象才能发动。那张卡的效果直到回合结束时无效。自己手卡是0张的场合，可以再把那张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(38904695,0))
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c38904695.distg)
	e1:SetOperation(c38904695.disop)
	c:RegisterEffect(e1)
	-- ②：只要自己手卡是0张，这张卡用和对方怪兽的战斗给与对方的战斗伤害变成2倍。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e2:SetCondition(c38904695.damcon)
	-- 设置战斗伤害为2倍
	e2:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	c:RegisterEffect(e2)
	-- ③：这张卡为同调素材的暗属性同调怪兽在同1次的战斗阶段中最多2次可以向怪兽攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e3:SetCondition(c38904695.exacon)
	e3:SetOperation(c38904695.exaop)
	c:RegisterEffect(e3)
end
-- 处理效果目标选择阶段，检查场上是否存在可作为无效化对象的卡片
function c38904695.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 判断当前是否为选择目标阶段，若是则返回场上卡片是否满足无效化条件
	if chkc then return chkc:IsOnField() and aux.NegateAnyFilter(chkc) end
	-- 判断是否满足发动条件，即场上是否存在满足无效化条件的卡片
	if chk==0 then return Duel.IsExistingTarget(aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向玩家提示选择要无效的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择场上满足无效化条件的1张卡作为目标
	local g=Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁操作信息，标记将要无效的卡
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 处理效果发动后的操作，包括无效目标卡的效果并可能破坏该卡
function c38904695.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsCanBeDisabledByEffect(e,false) then
		-- 使目标卡相关的连锁无效
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 使目标卡的效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 使目标卡的效果无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			-- 使目标卡的陷阱怪兽效果无效
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
		end
		-- 判断自己手牌为0且玩家选择是否破坏目标卡
		if Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==0 and Duel.SelectYesNo(tp,aux.Stringid(38904695,1)) then  --"是否破坏？"
			-- 中断当前效果处理，使后续效果视为不同时处理
			Duel.BreakEffect()
			-- 破坏目标卡
			Duel.Destroy(tc,REASON_EFFECT)
		end
	end
end
-- 判断是否满足效果发动条件，即自己手牌为0且有战斗中的对方怪兽
function c38904695.damcon(e)
	-- 判断自己手牌为0且有战斗中的对方怪兽
	return e:GetHandler():GetBattleTarget()~=nil and Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_HAND,0)==0
end
-- 判断是否满足效果发动条件，即该卡作为同调素材且其同调怪兽为暗属性
function c38904695.exacon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_SYNCHRO and e:GetHandler():GetReasonCard():IsAttribute(ATTRIBUTE_DARK)
end
-- 处理效果发动后的操作，使该卡的同调怪兽在同1次战斗阶段中可额外攻击1次
function c38904695.exaop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- 使该卡的同调怪兽在同1次战斗阶段中可额外攻击1次
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(38904695,2))  --"「永火地狱恶魔」为同调素材"
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
end
