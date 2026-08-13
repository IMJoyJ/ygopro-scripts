--ダブル・ディフェンダー
-- 效果：
-- 自己场上有表侧守备表示怪兽2只以上存在的场合，对方怪兽的攻击宣言时才能发动。把那1只对方怪兽的攻击无效。这个效果1回合只能使用1次。
function c44883600.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 从效果原文“自己场上有表侧守备表示怪兽2只以上存在的场合，对方怪兽的攻击宣言时才能发动。把那1只对方怪兽的攻击无效。这个效果1回合只能使用1次。”可知，e2对应的是“对方怪兽的攻击宣言时才能发动。把那1只对方怪兽的攻击无效。这个效果1回合只能使用1次。”这一整段效果：作为场上永续魔法陷阱卡拥有的诱发效果，在对方攻击宣言时发动，取对象（那只攻击怪兽），一回合一次，发动后无效该攻击。
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
-- 效果发动条件判定：只有对方回合（当前回合玩家不是自己）才能发动，并且自己场上存在至少2只表侧守备表示怪兽。
function c44883600.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 条件表达式：tp（效果发动者）不是当前回合玩家（即对方回合），且自己主要怪兽区存在至少2只表侧守备表示的怪兽。
	return tp~=Duel.GetTurnPlayer() and Duel.IsExistingMatchingCard(Card.IsPosition,tp,LOCATION_MZONE,0,2,nil,POS_FACEUP_DEFENSE)
end
-- 效果发动时的取对象处理：取得当前攻击宣言的怪兽作为对象，并检查其是否在场、能否成为效果对象，若满足则以该攻击怪兽为对象。
function c44883600.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前正在发动攻击的那只怪兽。
	local tg=Duel.GetAttacker()
	if chkc then return chkc==tg end
	if chk==0 then return tg:IsOnField() and tg:IsCanBeEffectTarget(e) end
	-- 将当前攻击宣言的怪兽设置为该连锁的处理对象（用于取对象及后续关联判定）。
	Duel.SetTargetCard(tg)
end
-- 效果处理时的操作：若发动效果的这张卡与效果仍有关联（未离场等），则无效此次攻击。
function c44883600.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 使当前攻击宣言的怪兽攻击无效化，即阻止该次攻击。
		Duel.NegateAttack()
	end
end
