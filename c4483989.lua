--反撃準備
-- 效果：
-- 每次对方玩家对表侧守备表示怪兽进行攻击宣言时，投掷硬币猜正反。
-- ●猜中的场合：被攻击的表侧守备表示怪兽变成攻击表示。
-- ●猜错的场合：这张卡的控制者受到攻击怪兽的攻击力超过攻击对象的怪兽的守备力的数值的伤害。
function c4483989.initial_effect(c)
	-- 每次对方玩家对表侧守备表示怪兽进行攻击宣言时，投掷硬币猜正反。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_BATTLE_START)
	e1:SetTarget(c4483989.atktg1)
	e1:SetOperation(c4483989.atkop)
	c:RegisterEffect(e1)
	-- 每次对方玩家对表侧守备表示怪兽进行攻击宣言时，投掷硬币猜正反。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(4483989,0))  --"猜硬币"
	e2:SetCategory(CATEGORY_COIN)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c4483989.atkcon)
	e2:SetTarget(c4483989.atktg2)
	e2:SetOperation(c4483989.atkop)
	c:RegisterEffect(e2)
end
-- 作为诱发效果的发动条件：判断是否为对方回合且对方玩家对表侧守备表示怪兽进行攻击宣言。
function c4483989.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被攻击的怪兽（攻击对象）。
	local at=Duel.GetAttackTarget()
	-- 返回条件是否成立：当前为对方回合，且存在攻击对象，且该攻击对象为表侧守备表示。
	return tp~=Duel.GetTurnPlayer() and at and at:IsPosition(POS_FACEUP_DEFENSE)
end
-- e1的target：仅在当前时点确为攻击宣言且满足对方攻击表侧守备怪兽时，标记标签为1并记录关联与硬币操作信息，否则标签为0使效果处理时不做事。
function c4483989.atktg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:SetLabel(0)
	-- 获取攻击对象，用于判断是否满足表侧守备表示怪兽被攻击的条件。
	local at=Duel.GetAttackTarget()
	-- 检查当前事件是否为攻击宣言，并且当前回合玩家不是这张卡的控制者，确保只能在对方玩家攻击宣言时发动。
	if Duel.CheckEvent(EVENT_ATTACK_ANNOUNCE) and tp~=Duel.GetTurnPlayer()
		and at and at:IsPosition(POS_FACEUP_DEFENSE) then
		e:SetLabel(1)
		-- 将攻击怪兽与当前效果建立联系，以便效果处理时确认其仍与本次效果关联。
		Duel.GetAttacker():CreateEffectRelation(e)
		at:CreateEffectRelation(e)
		-- 设置操作信息为硬币类别，预定进行1次硬币投掷，供系统识别硬币效果及进行相关时点检测。
		Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
	end
end
-- e2的target：必发诱发效果发动时，将攻击怪兽和攻击对象都与效果建立联系，并设置硬币操作信息。
function c4483989.atktg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:SetLabel(1)
	-- 将攻击怪兽与当前效果建立联系。
	Duel.GetAttacker():CreateEffectRelation(e)
	-- 将攻击对象与当前效果建立联系。
	Duel.GetAttackTarget():CreateEffectRelation(e)
	-- 设置操作信息为硬币类别，预定进行1次硬币投掷。
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
-- 效果处理：先确认效果有效，再获取攻击怪兽和攻击对象，确认它们表侧且与效果关联后，让对手宣言硬币并掷币；猜中时将被攻击怪兽变为表侧攻击表示，猜错且攻击力高于守备力时给控制者造成差值伤害。
function c4483989.atkop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 or not e:GetHandler():IsRelateToEffect(e) then return end
	-- 获取攻击怪兽。
	local a=Duel.GetAttacker()
	-- 获取被攻击怪兽。
	local at=Duel.GetAttackTarget()
	if a:IsFaceup() and a:IsRelateToEffect(e) and at:IsFaceup() and at:IsRelateToEffect(e) then
		-- 给对手发送选择硬币正反面的提示消息，提示类型为硬币选择。
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_COIN)  --"请选择硬币的正反面"
		-- 让对手宣言硬币正反面，返回宣言值（注意其与掷币结果的编码相反）。
		local coin=Duel.AnnounceCoin(1-tp)
		-- 掷1次硬币，返回实际结果（与宣言值编码相反）。
		local res=Duel.TossCoin(1-tp,1)
		if coin~=res then
			-- 猜中时，将被攻击的表侧守备表示怪兽改变为表侧攻击表示。
			Duel.ChangePosition(at,POS_FACEUP_ATTACK)
		elseif a:GetAttack()>at:GetDefense() then
			-- 猜错时，若攻击怪兽攻击力高于攻击对象守备力，给这张卡的控制者造成差值的效果伤害。
			Duel.Damage(tp,a:GetAttack()-at:GetDefense(),REASON_EFFECT)
		end
	end
end
