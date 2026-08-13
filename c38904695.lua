--インフェルニティ・ヘル・デーモン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- ①：1回合1次，以场上1张表侧表示的卡为对象才能发动。那张卡的效果直到回合结束时无效。自己手卡是0张的场合，可以再把那张卡破坏。
-- ②：只要自己手卡是0张，这张卡用和对方怪兽的战斗给与对方的战斗伤害变成2倍。
-- ③：这张卡为同调素材的暗属性同调怪兽在同1次的战斗阶段中最多2次可以向怪兽攻击。
function c38904695.initial_effect(c)
	-- 为这张卡添加同调召唤手续：调整1只（无特别限定）＋调整以外的怪兽1只以上。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 对应效果原文“①：1回合1次，以场上1张表侧表示的卡为对象才能发动。那张卡的效果直到回合结束时无效。自己手卡是0张的场合，可以再把那张卡破坏。”
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
	-- 对应效果原文“②：只要自己手卡是0张，这张卡用和对方怪兽的战斗给与对方的战斗伤害变成2倍。”
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e2:SetCondition(c38904695.damcon)
	-- 设置伤害变更效果：将对方玩家受到的战斗伤害变为2倍（DOUBLE_DAMAGE），即这张卡给予对方的战斗伤害翻倍。
	e2:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	c:RegisterEffect(e2)
	-- 对应效果原文“③：这张卡为同调素材的暗属性同调怪兽在同1次的战斗阶段中最多2次可以向怪兽攻击。”
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e3:SetCondition(c38904695.exacon)
	e3:SetOperation(c38904695.exaop)
	c:RegisterEffect(e3)
end
-- 效果①发动时的选取对象处理：确认场上是否存在可被无效化的表侧表示卡，若存在则让玩家选择1张作为对象，并将“无效化”操作信息登记到连锁。
function c38904695.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 若是在连锁处理中的对象合适性检查（chkc不为空），则要求候选卡必须在场上且可以被无效化，满足才可作为对象。
	if chkc then return chkc:IsOnField() and aux.NegateAnyFilter(chkc) end
	-- 发动效果合法性判定：如果双方场上不存在至少1张能被无效化的表侧表示卡，则不能发动效果。
	if chk==0 then return Duel.IsExistingTarget(aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向发动玩家弹出“请选择要无效的卡”的选择提示信息，供选择卡片界面使用。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 让发动玩家从双方场上选择1张能被无效化的表侧表示卡，并将其作为本连锁的取对象目标。
	local g=Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 登记操作信息：声明本连锁将无效化1张对象卡（g），使相关卡片（如星尘龙等）能正确响应。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 效果①的发动处理：取出目标卡，确认其仍与效果关联且表侧表示并能被无效化后，令其效果无效（含陷阱怪兽），若自己手卡为0则询问是否破坏，选择是则破坏该卡。
function c38904695.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsCanBeDisabledByEffect(e,false) then
		-- 将与该对象卡相关的连锁都无效化，并设定在变里侧时重置该无效状态，防止其效果继续处理。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 对应效果原文“那张卡的效果直到回合结束时无效。”
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 对应效果原文“那张卡的效果直到回合结束时无效。”（无效其效果的发动与适用）
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			-- 对应效果原文“那张卡的效果直到回合结束时无效。”（对陷阱怪兽的无效处理）
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
		end
		-- 判断自己手卡是否为0，若是则询问玩家是否将对象卡也破坏，对应原文“自己手卡是0张的场合，可以再把那张卡破坏”。
		if Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==0 and Duel.SelectYesNo(tp,aux.Stringid(38904695,1)) then  --"是否破坏？"
			-- 中断当前效果处理，使随后的破坏处理作为独立处理，避免错失时点。
			Duel.BreakEffect()
			-- 以效果处理为原因将对象卡破坏。
			Duel.Destroy(tc,REASON_EFFECT)
		end
	end
end
-- 效果②的条件判断：这张卡正在进行战斗（存在战斗对象）并且这张卡的控制者手卡为0时，战斗伤害翻倍效果适用。
function c38904695.damcon(e)
	-- 判断“这张卡正与怪兽战斗”和“其控制者手卡为0”两个条件是否同时满足。
	return e:GetHandler():GetBattleTarget()~=nil and Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_HAND,0)==0
end
-- 效果③的触发条件：这张卡作为同调素材被使用，并且同调召唤出的怪兽为暗属性。
function c38904695.exacon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_SYNCHRO and e:GetHandler():GetReasonCard():IsAttribute(ATTRIBUTE_DARK)
end
-- 效果③的处理：为同调召唤出的暗属性同调怪兽附加“在1个战斗阶段中最多可以攻击2次”的效果（追加1次攻击），并随其离场等标准事件重置。
function c38904695.exaop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- 对应效果原文“③：这张卡为同调素材的暗属性同调怪兽在同1次的战斗阶段中最多2次可以向怪兽攻击。”
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
