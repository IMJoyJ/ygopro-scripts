--双穹の騎士アストラム
-- 效果：
-- 从额外卡组特殊召唤的怪兽2只以上
-- ①：只要连接召唤的这张卡在怪兽区域存在，对方怪兽不能选择其他怪兽作为攻击对象，对方不能把这张卡作为效果的对象。
-- ②：这张卡和特殊召唤的怪兽进行战斗的伤害计算时才能发动1次。这张卡的攻击力只在那次伤害计算时上升那只对方怪兽的攻击力数值。
-- ③：连接召唤的这张卡被对方送去墓地的场合才能发动。场上1张卡回到卡组。
function c21887175.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加连接召唤手续：需要2只以上满足matfilter的怪兽作为连接素材（即从额外卡组特殊召唤的怪兽）。
	aux.AddLinkProcedure(c,c21887175.matfilter,2)
	-- 对方不能把这张卡作为效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c21887175.tgcon)
	-- 设置该效果的值函数：使此卡不能成为对方发动的效果的对象（仅对对方玩家的效果免疫）。
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	-- 对方怪兽不能选择其他怪兽作为攻击对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetCondition(c21887175.tgcon)
	e2:SetValue(c21887175.atlimit)
	c:RegisterEffect(e2)
	-- 这张卡和特殊召唤的怪兽进行战斗的伤害计算时才能发动1次。这张卡的攻击力只在那次伤害计算时上升那只对方怪兽的攻击力数值。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e3:SetCondition(c21887175.atkcon)
	e3:SetCost(c21887175.atkcost)
	e3:SetOperation(c21887175.atkop)
	c:RegisterEffect(e3)
	-- 连接召唤的这张卡被对方送去墓地的场合才能发动。场上1张卡回到卡组。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TODECK)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCondition(c21887175.tdcon)
	e4:SetTarget(c21887175.tdtg)
	e4:SetOperation(c21887175.tdop)
	c:RegisterEffect(e4)
end
-- 连接素材过滤函数：素材怪兽必须是从额外卡组特殊召唤的怪兽（满足“从额外卡组特殊召唤的怪兽2只以上”的素材要求）。
function c21887175.matfilter(c)
	return c:IsSummonLocation(LOCATION_EXTRA)
end
-- 效果适用条件：这张卡处于连接召唤状态（即出场方式是连接召唤）。
function c21887175.tgcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- EFFECT_CANNOT_SELECT_BATTLE_TARGET的值函数：若候选攻击对象不是本卡，则对方不能选择它作为攻击对象，从而只能攻击本卡。
function c21887175.atlimit(e,c)
	return c~=e:GetHandler()
end
-- 发动条件：本卡的战斗对象存在，且该战斗对象为特殊召唤的怪兽，并且其攻击力大于0。
function c21887175.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and bc:IsSummonType(SUMMON_TYPE_SPECIAL) and bc:GetAttack()>0
end
-- 发动代价/限制：确认本卡没有在此次伤害计算中用过后，打上标记直到伤害计算阶段结束，以限制每次伤害计算只能发动一次。
function c21887175.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetFlagEffect(21887175)==0 end
	c:RegisterFlagEffect(21887175,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL,0,1)
end
-- 效果处理：当本卡与战斗对象仍相关且都是表侧表示时，赋予本卡攻击力上升效果，上升值为那只战斗对象当前的攻击力，并在该伤害计算阶段结束时重置。
function c21887175.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if c:IsRelateToBattle() and c:IsFaceup() and bc:IsRelateToBattle() and bc:IsFaceup() then
		-- 这张卡的攻击力只在那次伤害计算时上升那只对方怪兽的攻击力数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
		e1:SetValue(bc:GetAttack())
		c:RegisterEffect(e1)
	end
end
-- 发动条件：本卡为连接召唤怪兽，从自己怪兽区域被对方送去墓地（且此前由自己控制）。
function c21887175.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_LINK)
		and rp==1-tp and c:IsPreviousControler(tp)
end
-- 效果发动时确认双方场上存在可以返回卡组的卡，并登记操作信息：不取对象，预计让1张卡返回卡组。
function c21887175.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：双方场上至少存在1张可以返回卡组的卡，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 获取双方场上全部可以返回卡组的卡作为候选集合（用于登记此效果涉及的可能卡片）。
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 登记效果处理信息：本效果能将1张卡返回卡组，候选为场上所有满足条件的卡，具体卡在效果处理时选择。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 效果处理：从双方场上选择1张可以返回卡组的卡，展示选择结果后将其返回持有者卡组并洗牌，原因为效果。
function c21887175.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 向操作玩家显示选择提示，提示内容为“请选择要返回卡组的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让操作玩家从双方场上选择1张可以返回卡组的卡（不取对象，处理时选择）。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if g:GetCount()>0 then
		-- 向双方展示被选中的卡，并记录为本次效果选择的卡。
		Duel.HintSelection(g)
		-- 将选中的卡返回持有者卡组并洗牌，原因标记为效果；nil表示返回持有者卡组。
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
