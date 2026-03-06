--双穹の騎士アストラム
-- 效果：
-- 从额外卡组特殊召唤的怪兽2只以上
-- ①：只要连接召唤的这张卡在怪兽区域存在，对方怪兽不能选择其他怪兽作为攻击对象，对方不能把这张卡作为效果的对象。
-- ②：这张卡和特殊召唤的怪兽进行战斗的伤害计算时才能发动1次。这张卡的攻击力只在那次伤害计算时上升那只对方怪兽的攻击力数值。
-- ③：连接召唤的这张卡被对方送去墓地的场合才能发动。场上1张卡回到卡组。
function c21887175.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续，要求使用至少2个来自额外卡组的怪兽作为连接素材
	aux.AddLinkProcedure(c,c21887175.matfilter,2)
	-- 只要连接召唤的这张卡在怪兽区域存在，对方怪兽不能选择其他怪兽作为攻击对象，对方不能把这张卡作为效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c21887175.tgcon)
	-- 设置该效果为不会成为对方的卡的效果对象
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	-- 只要连接召唤的这张卡在怪兽区域存在，对方怪兽不能选择其他怪兽作为攻击对象。
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
-- 连接素材必须来自额外卡组
function c21887175.matfilter(c)
	return c:IsSummonLocation(LOCATION_EXTRA)
end
-- 效果适用条件：这张卡是连接召唤方式特殊召唤
function c21887175.tgcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 攻击对象限制函数：不能选择自己作为攻击对象
function c21887175.atlimit(e,c)
	return c~=e:GetHandler()
end
-- 伤害计算时的发动条件：战斗的对方怪兽是特殊召唤且攻击力大于0
function c21887175.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and bc:IsSummonType(SUMMON_TYPE_SPECIAL) and bc:GetAttack()>0
end
-- 伤害计算时的发动费用：检查是否已使用过此效果，若未使用则注册使用标记
function c21887175.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetFlagEffect(21887175)==0 end
	c:RegisterFlagEffect(21887175,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL,0,1)
end
-- 伤害计算时的效果处理：使自身攻击力增加对方怪兽的攻击力数值
function c21887175.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if c:IsRelateToBattle() and c:IsFaceup() and bc:IsRelateToBattle() and bc:IsFaceup() then
		-- 使自身攻击力增加对方怪兽的攻击力数值
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
		e1:SetValue(bc:GetAttack())
		c:RegisterEffect(e1)
	end
end
-- 墓地触发效果的发动条件：从场上送去墓地且是连接召唤，且是对方操作，且是自己控制者
function c21887175.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_LINK)
		and rp==1-tp and c:IsPreviousControler(tp)
end
-- 返回卡组效果的目标选择：选择场上1张可返回卡组的卡
function c21887175.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在至少1张可返回卡组的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 获取场上所有可返回卡组的卡
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置连锁操作信息：返回卡组效果的目标为1张卡
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 返回卡组效果的处理：选择并返回1张卡到卡组
function c21887175.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择场上1张可返回卡组的卡
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if g:GetCount()>0 then
		-- 显示所选卡作为对象的动画效果
		Duel.HintSelection(g)
		-- 将所选卡返回卡组并洗牌
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
