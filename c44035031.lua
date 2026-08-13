--グラヴィティ・ウォリアー
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这张卡同调召唤成功时，这张卡的攻击力上升对方场上表侧表示存在的怪兽数量×300的数值。1回合1次，对方的战斗阶段时选择对方场上守备表示存在的1只怪兽才能发动。选择的怪兽变成表侧攻击表示。这个回合那只怪兽可以攻击的场合必须作出攻击。
function c44035031.initial_effect(c)
	-- 为这张卡添加同调召唤手续：调整＋调整以外的怪兽1只以上（调整无限制，调整以外至少1只）。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 这张卡同调召唤成功时，这张卡的攻击力上升对方场上表侧表示存在的怪兽数量×300的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44035031,0))  --"攻击上升"
	e1:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c44035031.atkcon)
	e1:SetOperation(c44035031.atkop)
	c:RegisterEffect(e1)
	-- 1回合1次，对方的战斗阶段时选择对方场上守备表示存在的1只怪兽才能发动。选择的怪兽变成表侧攻击表示。这个回合那只怪兽可以攻击的场合必须作出攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(44035031,1))  --"改变表示形式"
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c44035031.poscon)
	e2:SetTarget(c44035031.postg)
	e2:SetOperation(c44035031.posop)
	c:RegisterEffect(e2)
end
-- 效果1的发动条件判定：只有这张卡以同调召唤方式成功召唤时才满足。
function c44035031.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 效果1处理：若这张卡仍与效果关联且表侧表示，则统计对方场上表侧表示怪兽数量，为这张卡附加攻击力上升该数量×300的持续效果。
function c44035031.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 统计对方场上表侧表示怪兽的数量，作为攻击力上升的数值依据。
	local ct=Duel.GetMatchingGroupCount(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	-- 这张卡的攻击力上升对方场上表侧表示存在的怪兽数量×300的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(ct*300)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
end
-- 效果2的发动条件判定：仅在对方回合的战斗阶段中满足。
function c44035031.poscon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前为对方回合且处于战斗阶段开始到战斗阶段结束之间，以允许发动效果。
	return Duel.GetTurnPlayer()~=tp and (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE)
end
-- 效果2的发动与目标选择：取对象效果，选择对方场上1只守备表示怪兽；处理时将该怪兽变更为表侧攻击表示并附加必须攻击效果。
function c44035031.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsDefensePos() end
	-- 发动时合法性检查：确认对方场上存在至少1只守备表示怪兽可选。
	if chk==0 then return Duel.IsExistingTarget(Card.IsDefensePos,tp,0,LOCATION_MZONE,1,nil) end
	-- 给操作者显示选择提示，提示内容为‘请选择要改变表示形式的怪兽’。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 让操作者从对方场上选择1只守备表示怪兽，并将其登记为这张效果的对象。
	local g=Duel.SelectTarget(tp,Card.IsDefensePos,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：宣告本效果将进行表示形式变更，对象为所选择的怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 效果2处理：将对象怪兽变为表侧攻击表示，如果成功变为表侧攻击表示，则给它附加‘本回合必须攻击’的效果。
function c44035031.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本连锁处理的对象卡（即效果发动时选择的对方守备表示怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽的表示形式变更为表侧攻击表示。
		Duel.ChangePosition(tc,POS_FACEUP_ATTACK)
		if tc:IsFaceup() then
			-- 这个回合那只怪兽可以攻击的场合必须作出攻击。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_MUST_ATTACK)
			e1:SetReset(RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
		end
	end
end
