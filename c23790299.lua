--オルターガイスト・メモリーガント
-- 效果：
-- 「幻变骚灵」怪兽2只以上
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：双方的战斗阶段，把自己场上1只其他怪兽解放才能发动。这张卡的攻击力上升那只怪兽的攻击力数值。
-- ②：这张卡战斗破坏怪兽时才能发动。选对方场上1只怪兽破坏。破坏的场合，这张卡只再1次可以继续攻击。
-- ③：这张卡被破坏的场合，可以作为代替把自己墓地1只怪兽除外。
function c23790299.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加连接召唤手续，要求使用2到4个属于「幻变骚灵」的怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x103),2,4)
	-- ①：双方的战斗阶段，把自己场上1只其他怪兽解放才能发动。这张卡的攻击力上升那只怪兽的攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(23790299,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,23790299)
	e1:SetCondition(c23790299.atkcon)
	e1:SetCost(c23790299.atkcost)
	e1:SetOperation(c23790299.atkop)
	c:RegisterEffect(e1)
	-- ②：这张卡战斗破坏怪兽时才能发动。选对方场上1只怪兽破坏。破坏的场合，这张卡只再1次可以继续攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(23790299,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetCountLimit(1,23790300)
	-- 设置效果的发动条件为战斗破坏怪兽时
	e2:SetCondition(aux.bdcon)
	e2:SetTarget(c23790299.destg)
	e2:SetOperation(c23790299.desop)
	c:RegisterEffect(e2)
	-- ③：这张卡被破坏的场合，可以作为代替把自己墓地1只怪兽除外。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,23790301)
	e3:SetTarget(c23790299.desreptg)
	e3:SetOperation(c23790299.desrepop)
	c:RegisterEffect(e3)
end
-- 判断当前是否为战斗阶段，且未进入伤害步骤
function c23790299.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段
	local ph=Duel.GetCurrentPhase()
	-- 若当前阶段为战斗开始到战斗阶段之间，并且未进入伤害步骤，则效果可以发动
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE and aux.dscon(e,tp,eg,ep,ev,re,r,rp)
end
-- 设置效果的发动费用为解放场上1只攻击力高于1的怪兽
function c23790299.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否满足解放怪兽的条件
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsAttackAbove,1,c,1) end
	-- 提示玩家选择要解放的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 选择满足条件的怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,Card.IsAttackAbove,1,1,c,1)
	-- 执行怪兽的解放操作
	Duel.Release(g,REASON_COST)
	e:SetLabel(g:GetFirst():GetPreviousAttackOnField())
end
-- 设置效果的发动后处理，使自身攻击力上升
function c23790299.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 使自身攻击力上升指定数值
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		e1:SetValue(e:GetLabel())
		c:RegisterEffect(e1)
	end
end
-- 设置效果的发动目标，选择对方场上1只怪兽进行破坏
function c23790299.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1只怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上的所有怪兽
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 设置连锁操作信息，指定要破坏的怪兽数量为1
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 设置效果的发动后处理，选择对方场上1只怪兽进行破坏并可能再攻击
function c23790299.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要破坏的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只怪兽进行破坏
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	if g:GetCount()>0 then
		-- 显示被选为破坏对象的怪兽
		Duel.HintSelection(g)
		-- 若成功破坏怪兽且自身可以连锁攻击，则进行连锁攻击
		if Duel.Destroy(g,REASON_EFFECT)~=0 and c:IsRelateToEffect(e) and c:IsChainAttackable() then
			-- 使自身可以再进行1次攻击
			Duel.ChainAttack()
		end
	end
end
-- 定义用于判断是否可以除外的墓地怪兽的过滤函数
function c23790299.repfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
-- 设置效果的发动条件，当自身因战斗或效果被破坏时，可选择墓地1只怪兽除外代替破坏
function c23790299.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		-- 判断自身是否因效果或战斗被破坏且未被替换过，同时检查墓地是否存在可除外的怪兽
		return c:IsReason(REASON_EFFECT+REASON_BATTLE) and not c:IsReason(REASON_REPLACE) and Duel.IsExistingMatchingCard(c23790299.repfilter,tp,LOCATION_GRAVE,0,1,nil)
	end
	-- 询问玩家是否发动该效果
	if Duel.SelectEffectYesNo(tp,c,96) then
		-- 提示玩家选择要除外的墓地怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
		-- 选择墓地1只符合条件的怪兽进行除外
		local g=Duel.SelectMatchingCard(tp,c23790299.repfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		e:SetLabelObject(g:GetFirst())
		return true
	else return false end
end
-- 设置效果的发动后处理，将选中的怪兽除外
function c23790299.desrepop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 执行将怪兽除外的操作
	Duel.Remove(tc,POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
end
