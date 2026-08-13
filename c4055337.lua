--オルフェゴール・トロイメア
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡不会被和连接怪兽的战斗破坏。
-- ②：把墓地的这张卡除外，以场上1只表侧表示怪兽为对象才能发动。从卡组把「自奏圣乐·梦幻崩影」以外的1只机械族·暗属性怪兽送去墓地，作为对象的怪兽的攻击力直到回合结束时上升送去墓地的怪兽的等级×100。这个效果的发动后，直到回合结束时自己不是暗属性怪兽不能特殊召唤。
function c4055337.initial_effect(c)
	-- ①：这张卡不会被和连接怪兽的战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(c4055337.indval)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：把墓地的这张卡除外，以场上1只表侧表示怪兽为对象才能发动。从卡组把「自奏圣乐·梦幻崩影」以外的1只机械族·暗属性怪兽送去墓地，作为对象的怪兽的攻击力直到回合结束时上升送去墓地的怪兽的等级×100。这个效果的发动后，直到回合结束时自己不是暗属性怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,4055337)
	e2:SetCondition(c4055337.atkcon1)
	-- 设置②效果的发动代价：从墓地除外这张卡（通过aux.bfgcost辅助函数实现）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c4055337.atktg)
	e2:SetOperation(c4055337.atkop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+TIMING_END_PHASE)
	e3:SetCondition(c4055337.atkcon2)
	c:RegisterEffect(e3)
end
-- 判定战斗对象是否为连接怪兽，若是则此卡不会被那次战斗破坏。
function c4055337.indval(e,c)
	return c:IsType(TYPE_LINK)
end
-- ②作为起动效果（1速）的发动条件：当前这张卡未被赋予二速发动能力时，才能以起动效果发动。
function c4055337.atkcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 返回真表示当前不处于“可作为二速效果发动”的状态，从而启用一速起动效果。
	return not aux.IsCanBeQuickEffect(e:GetHandler(),tp,90351981)
end
-- ②作为诱发即时效果（2速）的发动条件：满足伤害步骤限制条件，且这张卡被赋予在对方回合也能发动的二速能力。
function c4055337.atkcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 返回真要求：不在伤害步骤内（或伤害计算前）且卡片具有二速发动资格，以允许在自由时点发动。
	return aux.dscon(e,tp,eg,ep,ev,re,r,rp) and aux.IsCanBeQuickEffect(e:GetHandler(),tp,90351981)
end
-- 目标过滤条件：场上表侧表示怪兽。
function c4055337.tgfilter(c)
	return c:IsFaceup()
end
-- 卡组送墓的过滤条件：机械族·暗属性怪兽、可以送去墓地、卡名不是「自奏圣乐·梦幻崩影」。
function c4055337.filter(c)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToGrave() and not c:IsCode(4055337)
end
-- 效果发动目标的合法性检查和目标选择：需要场上存在表侧表示怪兽且卡组存在符合条件的机械族·暗属性怪兽。
function c4055337.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c4055337.tgfilter(chkc) end
	-- 发动时检查：场上是否存在至少1只表侧表示怪兽可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c4055337.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		-- 同时检查：卡组是否存在至少1只符合条件的机械族·暗属性怪兽可以送去墓地。
		and Duel.IsExistingMatchingCard(c4055337.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 向玩家发送选择提示：请选择表侧表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只表侧表示怪兽作为效果对象（取对象）。
	Duel.SelectTarget(tp,c4055337.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：本次效果包含从卡组将1张卡送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择符合条件的机械族·暗属性怪兽送去墓地，若成功且对象仍合法，则将对象的攻击力上升该怪兽等级×100；最后给自己附加暗属性以外不能特殊召唤的自肃。
function c4055337.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果处理阶段的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 向玩家发送选择提示：请选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组选择1张符合条件的机械族·暗属性怪兽（不取对象，处理时选择）。
	local g=Duel.SelectMatchingCard(tp,c4055337.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		local gc=g:GetFirst()
		-- 确认该卡确实被效果送入墓地且仍存在于墓地，同时对象怪兽仍与效果相关且表侧表示。
		if Duel.SendtoGrave(gc,REASON_EFFECT)~=0 and gc:IsLocation(LOCATION_GRAVE)
			and tc:IsRelateToEffect(e) and tc:IsFaceup() then
			local lv=gc:GetLevel()
			-- 作为对象的怪兽的攻击力直到回合结束时上升送去墓地的怪兽的等级×100。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e1:SetValue(lv*100)
			tc:RegisterEffect(e1)
		end
	end
	-- 这个效果的发动后，直到回合结束时自己不是暗属性怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c4055337.splimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 将“不是暗属性怪兽不能特殊召唤”的适用效果注册给当前玩家（持续到回合结束）。
	Duel.RegisterEffect(e2,tp)
end
-- 自肃判定：只要特殊召唤的怪兽不是暗属性，则不能进行该特殊召唤。
function c4055337.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_DARK)
end
