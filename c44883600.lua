--ダブル・ディフェンダー
-- 效果：
-- 自己场上有表侧守备表示怪兽2只以上存在的场合，对方怪兽的攻击宣言时才能发动。把那1只对方怪兽的攻击无效。这个效果1回合只能使用1次。
function c44883600.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 效果原文内容：自己场上有表侧守备表示怪兽2只以上存在的场合，对方怪兽的攻击宣言时才能发动。把那1只对方怪兽的攻击无效。这个效果1回合只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(44883600,0))  --"攻击无效"
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetCondition(c44883600.condition)
	e2:SetTarget(c44883600.target)
	e2:SetOperation(c44883600.activate)
	c:RegisterEffect(e2)
end
-- 规则层面作用：判断是否满足发动条件，即当前回合玩家不是攻击玩家，并且自己场上有至少2只表侧守备表示的怪兽。
function c44883600.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：判断是否满足发动条件，即当前回合玩家不是攻击玩家，并且自己场上有至少2只表侧守备表示的怪兽。
	return tp~=Duel.GetTurnPlayer() and Duel.IsExistingMatchingCard(Card.IsPosition,tp,LOCATION_MZONE,0,2,nil,POS_FACEUP_DEFENSE)
end
-- 规则层面作用：设置效果的目标为正在攻击的怪兽。
function c44883600.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 规则层面作用：获取当前正在攻击的怪兽。
	local tg=Duel.GetAttacker()
	if chkc then return chkc==tg end
	if chk==0 then return tg:IsOnField() and tg:IsCanBeEffectTarget(e) end
	-- 规则层面作用：将当前攻击的怪兽设置为效果对象。
	Duel.SetTargetCard(tg)
end
-- 规则层面作用：发动效果，如果此卡存在于场上则无效对方的攻击。
function c44883600.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 规则层面作用：无效当前的攻击
		Duel.NegateAttack()
	end
end
