--炎霊神パイロレクス
-- 效果：
-- 这张卡不能通常召唤。自己墓地的炎属性怪兽是5只的场合才能特殊召唤。这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡特殊召唤成功时，以对方场上1只怪兽为对象才能发动。那只怪兽破坏，双方玩家受到那只怪兽的原本攻击力一半数值的伤害。
-- ②：表侧表示的这张卡从场上离开的场合，下次的自己回合的战斗阶段跳过。
function c35842855.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 自己墓地的炎属性怪兽是5只的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c35842855.spcon)
	c:RegisterEffect(e2)
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡特殊召唤成功时，以对方场上1只怪兽为对象才能发动。那只怪兽破坏，双方玩家受到那只怪兽的原本攻击力一半数值的伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(35842855,0))  --"破坏并伤害"
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,35842855)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetTarget(c35842855.destg)
	e3:SetOperation(c35842855.desop)
	c:RegisterEffect(e3)
	-- ②：表侧表示的这张卡从场上离开的场合，下次的自己回合的战斗阶段跳过。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_LEAVE_FIELD_P)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetOperation(c35842855.leaveop)
	c:RegisterEffect(e4)
end
-- 定义炎灵神从手牌进行的特殊召唤手续条件：当效果询问能否特殊召唤时，若c为空则直接允许检查手续本身；否则要求有怪兽区空位，并且该控制者自己墓地的炎属性怪兽数量恰好为5只。
function c35842855.spcon(e,c)
	if c==nil then return true end
	-- 检查该卡的控制者场上是否有空余的怪兽区可供特殊召唤，返回怪兽区空位数大于0。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
		-- 统计该控制者自己墓地中炎属性怪兽的数量，必须正好等于5只，才满足特殊召唤条件。
		Duel.GetMatchingGroupCount(Card.IsAttribute,c:GetControler(),LOCATION_GRAVE,0,nil,ATTRIBUTE_FIRE)==5
end
-- 定义①效果的发动目标处理函数：在对象合法性检查时只允许选择对方场上怪兽；在发动时确认对方场上存在可选怪兽，随后选择对方场上1只怪兽为对象，并向连锁登记破坏与双方伤害的操作信息。
function c35842855.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 效果发动可行性检查：对方场上存在至少1只可被选择的怪兽时，本效果才能发动。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 向发动玩家显示选择提示，提示内容为‘请选择要破坏的卡’。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让发动玩家从对方场上选择1只怪兽，并将其登记为本连锁效果的对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 向连锁登记破坏信息：将已选择的1只怪兽作为将要被破坏的对象，破坏数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 向连锁登记伤害信息：伤害对象为双方玩家，具体数值在效果处理时根据对象怪兽的原本攻击力确定。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,0)
end
-- 定义①效果的伤害处理函数：取得对象怪兽；若对象仍与效果关联则将其用效果破坏；破坏成功时，以对象怪兽原本攻击力一半（向下取整）的数值，分别给本方和对方造成伤害，并完成伤害时点处理。
function c35842855.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本效果发动时选择的那1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认对象怪兽仍然与本次效果保持关联，且效果破坏实际成功破坏1张时，才继续执行后续伤害处理。
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)==1 then
		local atk=math.floor(tc:GetTextAttack()/2)
		if atk>0 then
			-- 给发动玩家本方造成相当于对象怪兽原本攻击力一半数值的伤害，使用分解步骤处理伤害。
			Duel.Damage(tp,atk,REASON_EFFECT,true)
			-- 给对方玩家造成与本方相同数值的伤害，也使用分解步骤处理。
			Duel.Damage(1-tp,atk,REASON_EFFECT,true)
			-- 完成伤害分解处理，触发与伤害相关的时点。
			Duel.RDComplete()
		end
	end
end
-- 定义②效果的处理函数：仅当这张卡表侧表示离开场上时继续处理；取得离场时的控制者，为其注册一个跳过战斗阶段的场上效果；若离场时是其自己的回合，则记录当前回合数并通过条件确保从下一次自己回合开始跳过；否则直接让该效果在下一次自己回合生效。
function c35842855.leaveop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsFacedown() then return end
	local effp=e:GetHandler():GetControler()
	-- ②：表侧表示的这张卡从场上离开的场合，下次的自己回合的战斗阶段跳过。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SKIP_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	-- 判断离场时的回合玩家是否为该卡的控制者，以决定跳过战斗阶段效果是否需要避免在当回合触发。
	if Duel.GetTurnPlayer()==effp then
		-- 将当前回合数记录到效果标签中，供后续条件判断回合数是否已经推进到下一次自己回合。
		e1:SetLabel(Duel.GetTurnCount())
		e1:SetCondition(c35842855.skipcon)
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
	else
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,1)
	end
	-- 以离场时的控制者为适用对象，将跳过战斗阶段的场上效果注册并开始持续生效。
	Duel.RegisterEffect(e1,effp)
end
-- 定义跳过战斗阶段效果的生效条件：当当前回合数不等于离场时记录的回合数时，效果才会生效。
function c35842855.skipcon(e)
	-- 判断当前回合数与记录值不一致，从而保证不是离场的当回合跳过战斗阶段，而是从随后的自己回合开始跳过。
	return Duel.GetTurnCount()~=e:GetLabel()
end
