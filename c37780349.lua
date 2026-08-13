--D-HERO ダイナマイトガイ
-- 效果：
-- ①：怪兽进行战斗的伤害计算时把这张卡从手卡丢弃才能发动。那次战斗发生的对自己的战斗伤害变成0，双方玩家受到1000伤害。
-- ②：把墓地的这张卡除外，以自己场上1只「命运英雄」怪兽为对象才能发动。那只怪兽的攻击力直到下次的对方回合结束时上升1000。
function c37780349.initial_effect(c)
	-- ①：怪兽进行战斗的伤害计算时把这张卡从手卡丢弃才能发动。那次战斗发生的对自己的战斗伤害变成0，双方玩家受到1000伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37780349,0))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c37780349.dmcon)
	e1:SetCost(c37780349.dmcost)
	e1:SetTarget(c37780349.dmtg)
	e1:SetOperation(c37780349.dmop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己场上1只「命运英雄」怪兽为对象才能发动。那只怪兽的攻击力直到下次的对方回合结束时上升1000。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(37780349,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	-- 设置效果②的发动代价：把墓地的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c37780349.atktg)
	e2:SetOperation(c37780349.atkop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件：在伤害计算时，若自己将受到战斗伤害（Duel.GetBattleDamage(tp)>0）则满足条件。
function c37780349.dmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回自己将要受到的战斗伤害是否大于0，作为效果①的发动判定。
	return Duel.GetBattleDamage(tp)>0
end
-- 效果①的代价函数：检查手卡中的此卡是否可丢弃，若可则将其从手卡丢弃到墓地作为发动代价。
function c37780349.dmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将此卡从手卡丢弃并送去墓地，作为效果①的发动代价（REASON_COST+REASON_DISCARD）。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 效果①的目标/发动确认函数：本效果无需取对象；发动时登记将给双方玩家各造成1000伤害的操作信息。
function c37780349.dmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记本次效果处理会对双方玩家各造成1000点效果伤害（PLAYER_ALL, 1000），用于连锁检测等。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,1000)
end
-- 效果①的解决处理：给发动者自己附加本次战斗伤害变为0的效果，然后让双方玩家各受到1000点伤害，并完成伤害处理时点。
function c37780349.dmop(e,tp,eg,ep,ev,re,r,rp)
	-- 那次战斗发生的对自己的战斗伤害变成0，双方玩家受到1000伤害。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	-- 将“不会受到战斗伤害”的效果注册给玩家tp（效果发动者），使其在该伤害步骤免受战斗伤害。
	Duel.RegisterEffect(e1,tp)
	-- 给予效果发动者tp 1000点效果伤害，is_step=true表示作为连锁中的一步伤害处理。
	Duel.Damage(tp,1000,REASON_EFFECT,true)
	-- 给予对方玩家1000点效果伤害，is_step=true表示作为连锁中的一步伤害处理。
	Duel.Damage(1-tp,1000,REASON_EFFECT,true)
	-- 调用Duel.RDComplete()，完成这组伤害/回复的步骤处理并触发对应时点。
	Duel.RDComplete()
end
-- 效果②的目标过滤函数：要求怪兽表侧表示且持有「命运英雄」字段（setname 0xc008）。
function c37780349.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xc008)
end
-- 效果②的取对象目标选择函数：确定对象为满足条件的卡；在发动确认时检查有无可用对象，然后让玩家从自己场上选择1只表侧表示的「命运英雄」怪兽。
function c37780349.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c37780349.filter(chkc) end
	-- 检查自己场上是否存在至少1只表侧表示且持有「命运英雄」字段的怪兽，作为效果②能否发动的条件。
	if chk==0 then return Duel.IsExistingTarget(c37780349.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 显示选择提示框，提示玩家选择表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从自己场上选择1只表侧表示的「命运英雄」怪兽，并将其登记为效果②的对象。
	Duel.SelectTarget(tp,c37780349.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果②的解决处理：取得对象怪兽，若对象仍与此效果关联且表侧表示，则给它附加攻击力上升1000的效果，持续到下次对方回合结束。
function c37780349.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果②发动时选择的那只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只怪兽的攻击力直到下次的对方回合结束时上升1000。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		e1:SetValue(1000)
		tc:RegisterEffect(e1)
	end
end
