--混沌の戦士 カオス・ソルジャー
-- 效果：
-- 卡名不同的怪兽3只
-- ①：这张卡是已用7星以上的怪兽为素材作连接召唤的场合，这张卡不会被对方的效果破坏，对方不能把这张卡作为效果的对象。
-- ②：这张卡战斗破坏对方怪兽时，可以从以下效果选择1个发动。
-- ●这张卡的攻击力上升1500。
-- ●这张卡在下次的自己回合的战斗阶段中可以作2次攻击。
-- ●场上1张卡除外。
function c49202162.initial_effect(c)
	-- 为这张卡添加连接召唤手续，要求恰好3只卡名不同的怪兽作为连接素材（由lcheck过滤）。
	aux.AddLinkProcedure(c,nil,3,3,c49202162.lcheck)
	c:EnableReviveLimit()
	-- 这张卡是已用7星以上的怪兽为素材作连接召唤的场合
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c49202162.regcon)
	e1:SetOperation(c49202162.regop)
	c:RegisterEffect(e1)
	-- 这张卡是已用7星以上的怪兽为素材作连接召唤的场合
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c49202162.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	-- 对方不能把这张卡作为效果的对象。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c49202162.tgcon)
	-- 设定“不能成为效果对象”的判定函数，使对方的效果不能以这张卡为对象，己方效果不受影响。
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	-- 这张卡不会被对方的效果破坏
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c49202162.tgcon)
	-- 设定“不会被效果破坏”的判定函数，使对方的效果不能破坏这张卡。
	e4:SetValue(aux.indoval)
	c:RegisterEffect(e4)
	-- ②：这张卡战斗破坏对方怪兽时，可以从以下效果选择1个发动。●这张卡的攻击力上升1500。●这张卡在下次的自己回合的战斗阶段中可以作2次攻击。●场上1张卡除外。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(49202162,0))  --"选择效果发动"
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_BATTLE_DESTROYING)
	-- 设置②效果的发动条件：这张卡与对方怪兽战斗并将其破坏。
	e5:SetCondition(aux.bdocon)
	e5:SetTarget(c49202162.efftg)
	e5:SetOperation(c49202162.effop)
	c:RegisterEffect(e5)
end
-- 连接素材检查函数，要求素材怪兽的卡名各不相同，满足“卡名不同的怪兽3只”的召唤条件。
function c49202162.lcheck(g,lc)
	return g:GetClassCount(Card.GetLinkCode)==g:GetCount()
end
-- 判断这张卡是否以连接召唤方式成功召唤，并且素材检查标记为已使用7星以上怪兽（e:GetLabel()==1）。
function c49202162.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) and e:GetLabel()==1
end
-- 当条件满足时，给这张卡注册一个标志（49202162），用于后续抗性效果判断，并向客户端提示“使用7星以上的怪兽为素材连接召唤”。
function c49202162.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(49202162,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(49202162,4))  --"使用7星以上的怪兽为素材连接召唤"
end
-- 抗性效果的适用条件：这张卡拥有“已用7星以上素材连接召唤”的标志。
function c49202162.tgcon(e)
	return e:GetHandler():GetFlagEffect(49202162)>0
end
-- ②效果发动时点处理：根据“2次攻击”是否已用过以及场上是否存在可除外的卡，显示对应选项；玩家选择后存入效果标签供处理使用。
function c49202162.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local b2=c:GetFlagEffect(49202163)==0
	-- 检查双方场上是否存在至少1张可以被除外的卡，用于决定“场上1张卡除外”选项是否可选。
	local b3=Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	if chk==0 then return true end
	local op=0
	if b2 and b3 then
		-- 当“2次攻击”和“除外”选项都可用时，玩家从三个效果中选择1个发动，返回0/1/2分别对应攻击力上升、2次攻击、除外。
		op=Duel.SelectOption(tp,aux.Stringid(49202162,1),aux.Stringid(49202162,2),aux.Stringid(49202162,3))  --"攻击力上升/2次攻击/场上1张卡除外"
	elseif b2 then
		-- 当“除外”不可用但“2次攻击”可用时，玩家只能选择攻击力上升或2次攻击。
		op=Duel.SelectOption(tp,aux.Stringid(49202162,1),aux.Stringid(49202162,2))  --"攻击力上升/2次攻击"
	elseif b3 then
		-- 当“2次攻击”不可用但“除外”可用时，玩家从攻击力上升或除外中选择；乘以2使选项编号与三选项时一致（0=攻击力，2=除外）。
		op=Duel.SelectOption(tp,aux.Stringid(49202162,1),aux.Stringid(49202162,3))*2  --"攻击力上升/场上1张卡除外"
	else
		-- 当“2次攻击”和“除外”均不可用时，只有“攻击力上升”可选，直接选择0。
		op=Duel.SelectOption(tp,aux.Stringid(49202162,1))  --"攻击力上升"
	end
	e:SetLabel(op)
end
-- ②效果处理：根据玩家选择的选项执行对应效果——攻击力上升1500，或下次自己回合增加1次攻击，或除外场上1张卡。
function c49202162.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local op=e:GetLabel()
	if op==0 then
		if c:IsFaceup() and c:IsRelateToEffect(e) then
			-- ●这张卡的攻击力上升1500。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(1500)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			c:RegisterEffect(e1)
		end
	elseif op==1 then
		if c:IsFaceup() and c:IsRelateToEffect(e) then
			local tct=0
			-- 判断当前回合玩家是否为发动效果的一方，若是则“下次自己回合”的重置计数需要延长到下一个自己回合，所以tct设为1。
			if Duel.GetTurnPlayer()==tp then tct=1 end
			-- ●这张卡在下次的自己回合的战斗阶段中可以作2次攻击。
			local e1=Effect.CreateEffect(c)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EXTRA_ATTACK)
			e1:SetCondition(c49202162.eacon)
			-- 记录发动效果时的回合数，用于判断“下次自己回合”的到来，确保额外攻击不会当回合立即生效。
			e1:SetLabel(Duel.GetTurnCount())
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_SELF_TURN,1+tct)
			c:RegisterEffect(e1)
			c:RegisterFlagEffect(49202163,RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END,0,1+tct)
		end
	else
		-- 显示“请选择要除外的卡”的提示，要求玩家选择1张除外对象。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 从双方场上选择1张满足除外条件的卡作为效果对象。
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		if g:GetCount()>0 then
			-- 将选择的那张卡以表侧表示除外，实现“场上1张卡除外”的效果。
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
	end
end
-- 额外攻击效果的适用条件：当前回合数不等于记录回合数，即只在发动后的“下次自己回合”的战斗阶段中生效。
function c49202162.eacon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合数是否不同于记录值，从而避免额外攻击在发动当回合生效。
	return Duel.GetTurnCount()~=e:GetLabel()
end
-- 素材检查回调：连接召唤时检查素材中是否存在等级7以上的怪兽，若有则将e1的label设为1，否则设为0，供特殊召唤成功时的条件判断使用。
function c49202162.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsLevelAbove,1,nil,7) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
