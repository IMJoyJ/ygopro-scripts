--グラヴィティ・ウォリアー
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这张卡同调召唤成功时，这张卡的攻击力上升对方场上表侧表示存在的怪兽数量×300的数值。1回合1次，对方的战斗阶段时选择对方场上守备表示存在的1只怪兽才能发动。选择的怪兽变成表侧攻击表示。这个回合那只怪兽可以攻击的场合必须作出攻击。
function c44035031.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和1只调整以外的怪兽
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
-- 判断此卡是否为同调召唤
function c44035031.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 计算对方场上表侧表示怪兽数量，并为自身添加攻击力提升效果
function c44035031.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 获取对方场上表侧表示怪兽数量
	local ct=Duel.GetMatchingGroupCount(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	-- 为自身添加攻击力提升效果，提升值为怪兽数量×300
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(ct*300)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
end
-- 判断是否为对方的战斗阶段
function c44035031.poscon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合玩家不是自己且当前阶段为战斗阶段开始到战斗阶段结束
	return Duel.GetTurnPlayer()~=tp and (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE)
end
-- 设置选择目标的处理，用于选择对方场上的守备表示怪兽
function c44035031.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsDefensePos() end
	-- 检查对方场上是否存在守备表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsDefensePos,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择对方场上的1只守备表示怪兽作为目标
	local g=Duel.SelectTarget(tp,Card.IsDefensePos,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息，指定将要改变表示形式的怪兽
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 处理改变表示形式的效果，将目标怪兽变为表侧攻击表示并强制攻击
function c44035031.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽变为表侧攻击表示
		Duel.ChangePosition(tc,POS_FACEUP_ATTACK)
		if tc:IsFaceup() then
			-- 为目标怪兽添加必须攻击的效果，持续到回合结束
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_MUST_ATTACK)
			e1:SetReset(RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
		end
	end
end
