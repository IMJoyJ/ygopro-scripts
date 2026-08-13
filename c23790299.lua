--オルターガイスト・メモリーガント
-- 效果：
-- 「幻变骚灵」怪兽2只以上
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：双方的战斗阶段，把自己场上1只其他怪兽解放才能发动。这张卡的攻击力上升那只怪兽的攻击力数值。
-- ②：这张卡战斗破坏怪兽时才能发动。选对方场上1只怪兽破坏。破坏的场合，这张卡只再1次可以继续攻击。
-- ③：这张卡被破坏的场合，可以作为代替把自己墓地1只怪兽除外。
function c23790299.initial_effect(c)
	c:EnableReviveLimit()
	-- 为该卡添加连接召唤手续，素材为2～4只持有「幻变骚灵」字段的怪兽（0x103为幻变骚灵系列）。
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
	-- 设置②效果的发动条件：本卡与本次战斗相关，即本卡进行了战斗并战斗破坏了怪兽。
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
-- 定义①效果的发动条件函数：当前必须是战斗阶段（包含战斗阶段开始到战斗阶段结束），且满足伤害步骤内允许发动的限制。
function c23790299.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段，用于判断是否处于战斗阶段。
	local ph=Duel.GetCurrentPhase()
	-- 判断当前阶段是否在战斗阶段范围内，并通过aux.dscon排除伤害计算后等不允许发动的时点。
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE and aux.dscon(e,tp,eg,ep,ev,re,r,rp)
end
-- 定义①效果的发动代价函数：从自己场上选择1只其他怪兽解放，并把那只怪兽解放前的攻击力数值保存到效果标签中。
function c23790299.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 代价合法性检查：确认自己场上存在至少1只攻击力1以上的其他怪兽可以作为解放对象。
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsAttackAbove,1,c,1) end
	-- 向玩家显示“请选择要解放的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 让玩家从自己场上选择1只攻击力1以上的其他怪兽（排除自身）作为解放代价。
	local g=Duel.SelectReleaseGroup(tp,Card.IsAttackAbove,1,1,c,1)
	-- 将选择的怪兽以“代价”的原因解放，完成代价支付。
	Duel.Release(g,REASON_COST)
	e:SetLabel(g:GetFirst():GetPreviousAttackOnField())
end
-- 定义①效果处理函数：若本卡仍表侧表示且与效果链相关联，则把保存的解放怪兽攻击力数值赋予本卡，使其攻击力上升。
function c23790299.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力上升那只怪兽的攻击力数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		e1:SetValue(e:GetLabel())
		c:RegisterEffect(e1)
	end
end
-- 定义②效果的发动时目标确认函数：确认对方场上有怪兽可被破坏，并将对方场上全部怪兽登记为可能破坏的对象。
function c23790299.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 目标合法性检查：确认对方场上存在至少1只怪兽（无论表侧/里侧）。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上的全部怪兽，作为本次破坏效果的可能对象集合。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 登记连锁处理信息：本次效果为破坏效果，可能破坏的对象是对方场上全部怪兽，实际将破坏其中1只。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 定义②效果处理函数：选择对方场上1只怪兽破坏；若破坏成功且本卡仍相关并可继续攻击，则使本卡可以再攻击1次。
function c23790299.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 向玩家显示“请选择要破坏的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从对方场上选择1只怪兽作为破坏对象。
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	if g:GetCount()>0 then
		-- 显示所选择卡片的选中动画，并将其标记为被选择的卡。
		Duel.HintSelection(g)
		-- 判断破坏是否实际成功（返回非0），且本卡仍与效果相关、处于可继续攻击状态，满足则执行再攻击处理。
		if Duel.Destroy(g,REASON_EFFECT)~=0 and c:IsRelateToEffect(e) and c:IsChainAttackable() then
			-- 使本卡可以再1次进行攻击，对应“这张卡只再1次可以继续攻击”。
			Duel.ChainAttack()
		end
	end
end
-- 定义③效果中作为代替破坏除外的墓地怪兽的过滤条件：必须是怪兽且当前可以除外。
function c23790299.repfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
-- 定义③代替破坏效果的触发条件函数：当本卡将要被战斗或效果破坏，且破坏原因不是代替破坏本身时，检查墓地是否有可除外的怪兽，并询问玩家是否发动。
function c23790299.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		-- 判断本次破坏是否因战斗或效果造成，且不是由代替破坏产生，同时墓地存在满足条件的可除外怪兽。
		return c:IsReason(REASON_EFFECT+REASON_BATTLE) and not c:IsReason(REASON_REPLACE) and Duel.IsExistingMatchingCard(c23790299.repfilter,tp,LOCATION_GRAVE,0,1,nil)
	end
	-- 弹出选择框，让玩家决定是否发动代替破坏效果。
	if Duel.SelectEffectYesNo(tp,c,96) then
		-- 显示“请选择要代替破坏的卡”的提示信息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
		-- 让玩家从自己墓地选择1只满足条件的怪兽作为代替破坏除外的卡片。
		local g=Duel.SelectMatchingCard(tp,c23790299.repfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		e:SetLabelObject(g:GetFirst())
		return true
	else return false end
end
-- 定义③代替破坏效果的实际处理：将选中的墓地怪兽除外，从而使本卡不因破坏而离场。
function c23790299.desrepop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将选择怪兽以表侧表示除外，以此代替本卡的破坏。
	Duel.Remove(tc,POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
end
