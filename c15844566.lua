--パワーコード・トーカー
-- 效果：
-- 怪兽3只
-- ①：1回合1次，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。
-- ②：1回合1次，这张卡和对方怪兽进行战斗的伤害计算时，把这张卡所连接区1只自己怪兽解放才能发动。这张卡的攻击力只在那次伤害计算时变成原本攻击力的2倍。
function c15844566.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续，需要3只连接素材
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
-- 定义效果①的目标选择函数，检查场上是否存在可无效的怪兽
function c15844566.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 判断目标是否为场上怪兽且符合被无效化条件
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and aux.NegateMonsterFilter(chkc) end
	-- 检查是否满足发动条件，即场上存在可无效的怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.NegateMonsterFilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家发送提示信息，提示选择要无效的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择一个满足条件的场上怪兽作为目标
	local g=Duel.SelectTarget(tp,aux.NegateMonsterFilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息，指定将要无效的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 定义效果①的处理函数，使目标怪兽效果无效
function c15844566.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 使目标怪兽相关的连锁效果无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 使目标怪兽的效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 使目标怪兽的效果无效化效果在回合结束时解除
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
-- 判断是否满足效果②的发动条件，即此卡正在与对方怪兽战斗
function c15844566.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattleTarget()~=nil
end
-- 筛选连接区怪兽的过滤函数，排除已被战斗破坏的怪兽
function c15844566.cfilter(c,g)
	return g:IsContains(c) and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 定义效果②的费用支付函数，选择并解放连接区的怪兽
function c15844566.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local lg=e:GetHandler():GetLinkedGroup()
	-- 检查是否满足解放怪兽的条件
	if chk==0 then return Duel.CheckReleaseGroup(tp,c15844566.cfilter,1,nil,lg) end
	-- 选择一个满足条件的连接区怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,c15844566.cfilter,1,1,nil,lg)
	-- 将选中的怪兽从场上解放作为费用
	Duel.Release(g,REASON_COST)
end
-- 定义效果②的处理函数，使此卡攻击力变为原本的2倍
function c15844566.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local atk=c:GetBaseAttack()
		-- 设置此卡攻击力变为原本的2倍的效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_DAMAGE_CAL)
		e1:SetValue(atk*2)
		c:RegisterEffect(e1)
	end
end
