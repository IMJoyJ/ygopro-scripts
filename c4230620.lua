--サイキックブレイク
-- 效果：
-- 念动力族怪兽召唤成功时，可以支付500基本分把那1只怪兽的等级上升1星，攻击力上升300。
function c4230620.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 念动力族怪兽召唤成功时，可以支付500基本分把那1只怪兽的等级上升1星，攻击力上升300。
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
-- 判定效果发动条件：召唤成功的怪兽必须为表侧表示在场且种族为念动力族。
function c4230620.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=eg:GetFirst()
	return c:IsOnField() and c:IsRace(RACE_PSYCHO)
end
-- 效果发动代价处理：检查并支付500基本分。
function c4230620.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段：确认玩家能否支付500基本分，若能则代价合法。
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 实际支付500基本分，完成代价支付。
	Duel.PayLPCost(tp,500)
end
-- 选择效果对象：将召唤成功的那1只念动力族怪兽设为效果对象（取对象效果），且不能选择其他卡。
function c4230620.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return true end
	-- 把召唤成功的那1只怪兽登记为当前连锁的效果对象。
	Duel.SetTargetCard(eg)
end
-- 效果处理：若对象怪兽仍表侧在场且与效果关联，则使其等级上升1星、攻击力上升300，该变化在怪兽离场、离开手牌/卡组等标准重置时失效。
function c4230620.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理的对象怪兽，即之前选择的那只念动力族怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 把那1只怪兽的等级上升1星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 攻击力上升300。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(300)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end
