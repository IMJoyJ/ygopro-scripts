--パワーコード・トーカー
-- 效果：
-- 怪兽3只
-- ①：1回合1次，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。
-- ②：1回合1次，这张卡和对方怪兽进行战斗的伤害计算时，把这张卡所连接区1只自己怪兽解放才能发动。这张卡的攻击力只在那次伤害计算时变成原本攻击力的2倍。
function c15844566.initial_effect(c)
	c:EnableReviveLimit()
	-- 为力码语者添加连接召唤手续：使用任意3只怪兽作为连接素材（对应原效果文本中的“怪兽3只”）。
	aux.AddLinkProcedure(c,nil,3,3)
	-- ①：1回合1次，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(15844566,0))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c15844566.distg)
	e1:SetOperation(c15844566.disop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，这张卡和对方怪兽进行战斗的伤害计算时，把这张卡所连接区1只自己怪兽解放才能发动。这张卡的攻击力只在那次伤害计算时变成原本攻击力的2倍。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(15844566,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetCountLimit(1)
	e2:SetCondition(c15844566.atkcon)
	e2:SetCost(c15844566.atkcost)
	e2:SetOperation(c15844566.atkop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件判断与取对象处理：检查场上是否存在表侧表示且效果未被无效的效果怪兽，并让玩家选择1只作为对象。
function c15844566.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 连锁处理时验证对象：对象必须位于怪兽区，且是表侧表示、效果未被无效的效果怪兽。
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and aux.NegateMonsterFilter(chkc) end
	-- 发动时检查场上是否存在至少1只满足条件的表侧表示效果怪兽可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(aux.NegateMonsterFilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 给操作玩家显示“请选择要无效的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 让玩家从双方怪兽区选择1只满足条件的效果怪兽，并将它登记为这张卡效果的对象。
	local g=Duel.SelectTarget(tp,aux.NegateMonsterFilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：声明本效果将把这1只对象怪兽的效果无效。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- ①效果处理：若对象怪兽仍在场上且表侧表示，则无效该怪兽的怪兽效果及相关的效果文本，直到回合结束时适用。
function c15844566.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得本效果发动时选择的1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 使与该对象怪兽相关的连锁效果无效化，并在回合结束时重置。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那只怪兽的效果直到回合结束时无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 那只怪兽的效果直到回合结束时无效。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
-- ②效果的发动条件：这张卡与对方怪兽进行战斗并进入伤害计算阶段。
function c15844566.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattleTarget()~=nil
end
-- 过滤函数：选择这张卡所连接区、且没有被战斗破坏确定的自己怪兽作为可解放的卡。
function c15844566.cfilter(c,g)
	return g:IsContains(c) and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
-- ②效果的代价：从这张卡所连接区选择1只满足条件的自己怪兽解放作为发动代价。
function c15844566.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local lg=e:GetHandler():GetLinkedGroup()
	-- 发动时检查场上是否存在至少1只位于这张卡所连接区、可解放且未被战斗破坏的自己的怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c15844566.cfilter,1,nil,lg) end
	-- 让玩家从自己场上选择1只位于这张卡所连接区的自己怪兽作为解放对象。
	local g=Duel.SelectReleaseGroup(tp,c15844566.cfilter,1,1,nil,lg)
	-- 将选择的怪兽解放，作为发动②效果的代价。
	Duel.Release(g,REASON_COST)
end
-- ②效果处理：这张卡仍存在于怪兽区且表侧表示时，将其攻击力变成原本攻击力的2倍，仅在那次伤害计算时适用。
function c15844566.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local atk=c:GetBaseAttack()
		-- 这张卡的攻击力只在那次伤害计算时变成原本攻击力的2倍。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_DAMAGE_CAL)
		e1:SetValue(atk*2)
		c:RegisterEffect(e1)
	end
end
