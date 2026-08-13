--EMヒックリカエル
-- 效果：
-- ←3 【灵摆】 3→
-- ①：1回合1次，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力·守备力直到回合结束时交换。
-- 【怪兽效果】
-- ①：自己战斗阶段1次，以自己场上1只怪兽为对象才能发动。那只怪兽的表示形式变更，那个攻击力·守备力直到回合结束时交换。
function c4239451.initial_effect(c)
	-- 为这张卡添加灵摆怪兽属性（灵摆召唤与灵摆卡发动等基础功能）。
	aux.EnablePendulumAttribute(c)
	-- ←3 【灵摆】 3→ ①：1回合1次，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力·守备力直到回合结束时交换。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(4239451,0))  --"攻守交换"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetTarget(c4239451.adtg1)
	e2:SetOperation(c4239451.adop1)
	c:RegisterEffect(e2)
	-- 【怪兽效果】①：自己战斗阶段1次，以自己场上1只怪兽为对象才能发动。那只怪兽的表示形式变更，那个攻击力·守备力直到回合结束时交换。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(4239451,1))  --"攻守交换"
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetCondition(c4239451.adcon2)
	e3:SetTarget(c4239451.adtg2)
	e3:SetOperation(c4239451.adop2)
	c:RegisterEffect(e3)
end
-- 定义对象筛选函数：选择场上表侧表示且守备力数值为0以上的怪兽（即表侧表示怪兽）。
function c4239451.filter(c)
	return c:IsFaceup() and c:IsDefenseAbove(0)
end
-- 灵摆效果发动时的取对象流程：校验对象合法性、确认存在可选择的表侧表示怪兽、提示并选择对象。
function c4239451.adtg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c4239451.filter(chkc) end
	-- 发动条件判定：场上是否存在至少1只满足条件且可成为效果对象的表侧表示怪兽。
	if chk==0 then return Duel.IsExistingTarget(c4239451.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家显示“请选择表侧表示的卡”的选择提示（用于卡片选择UI）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 玩家选择场上1只表侧表示怪兽作为效果对象，并将其登记为当前连锁的对象。
	Duel.SelectTarget(tp,c4239451.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 灵摆效果处理：如果对象仍与效果相关且为表侧表示，则获取其当前攻击力与守备力，以攻击力·守备力交换的状态持续到回合结束。
function c4239451.adop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取灵摆效果所选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local atk=tc:GetAttack()
		local def=tc:GetDefense()
		-- 那只怪兽的攻击力·守备力直到回合结束时交换。（此处将攻击力暂时设为原守备力）
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(def)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2:SetValue(atk)
		tc:RegisterEffect(e2)
	end
end
-- 怪兽效果的发动条件判断：仅能让己方在自己的战斗阶段内且当前无连锁处理时发动。
function c4239451.adcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家为自己、当前阶段在战斗阶段范围内且连锁数为0，满足发动时机。
	return Duel.GetTurnPlayer()==tp and (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE) and Duel.GetCurrentChain()==0
end
-- 怪兽效果发动时的取对象流程：校验对象为自家怪兽区的表侧表示怪兽、确认存在可选择的怪兽、提示并选择对象。
function c4239451.adtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsDefenseAbove(0) end
	-- 发动条件判定：己方怪兽区是否存在至少1只可被选择为对象的表侧表示怪兽。
	if chk==0 then return Duel.IsExistingTarget(Card.IsDefenseAbove,tp,LOCATION_MZONE,0,1,nil,0) end
	-- 向玩家显示“请选择效果的对象”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 玩家选择自己场上1只表侧表示怪兽作为效果对象，并将其登记为当前连锁的对象。
	Duel.SelectTarget(tp,Card.IsDefenseAbove,tp,LOCATION_MZONE,0,1,1,nil,0)
end
-- 怪兽效果处理：若对象仍与效果相关，则先反转其表示形式（表侧攻击↔表侧守备），成功后再执行攻击力·守备力交换直到回合结束。
function c4239451.adop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取怪兽效果所选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e)
		-- 变更对象怪兽的表示形式（表侧攻击变表侧守备、表侧守备变表侧攻击），并判断变更是否成功。
		and Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)~=0 then
		local atk=tc:GetAttack()
		local def=tc:GetDefense()
		-- 那只怪兽的攻击力·守备力直到回合结束时交换。（此处将攻击力暂时设为原守备力，且该效果不会被无效）
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(def)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2:SetValue(atk)
		tc:RegisterEffect(e2)
	end
end
