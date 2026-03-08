--サイキックブレイク
-- 效果：
-- 念动力族怪兽召唤成功时，可以支付500基本分把那1只怪兽的等级上升1星，攻击力上升300。
function c4230620.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 诱发选发效果，对应一速的【……才能发动】
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(4230620,0))  --"等级攻击上升"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCondition(c4230620.atkcon)
	e2:SetCost(c4230620.atkcost)
	e2:SetTarget(c4230620.atktg)
	e2:SetOperation(c4230620.atkop)
	c:RegisterEffect(e2)
end
-- 念动力族怪兽召唤成功时
function c4230620.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=eg:GetFirst()
	return c:IsOnField() and c:IsRace(RACE_PSYCHO)
end
-- 可以支付500基本分把那1只怪兽的等级上升1星，攻击力上升300。
function c4230620.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付500基本分
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 让玩家支付500基本分
	Duel.PayLPCost(tp,500)
end
-- 设置连锁对象为召唤成功的怪兽
function c4230620.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return true end
	-- 将召唤成功的怪兽设为连锁对象
	Duel.SetTargetCard(eg)
end
-- 使目标怪兽的等级上升1星，攻击力上升300
function c4230620.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的唯一对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 使目标怪兽的等级上升1星
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 使目标怪兽的攻击力上升300
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(300)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end
