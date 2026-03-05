--百戦王 ベヒーモス
-- 效果：
-- 这张卡可以把1只怪兽解放作上级召唤。
-- ①：这张卡召唤·特殊召唤的场合，以自己墓地1只兽族·兽战士族·鸟兽族怪兽为对象才能发动。那只怪兽加入手卡，这张卡的攻击力下降700。
-- ②：通常召唤的这张卡不受特殊召唤的怪兽发动的效果影响。
-- ③：自己结束阶段才能发动。这张卡的攻击力上升700。
local s,id,o=GetID()
-- 初始化效果函数
function s.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合，以自己墓地1只兽族·兽战士族·鸟兽族怪兽为对象才能发动。那只怪兽加入手卡，这张卡的攻击力下降700。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(s.otcon)
	e1:SetOperation(s.otop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_PROC)
	c:RegisterEffect(e2)
	-- ②：通常召唤的这张卡不受特殊召唤的怪兽发动的效果影响。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
	-- ③：自己结束阶段才能发动。这张卡的攻击力上升700。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EFFECT_IMMUNE_EFFECT)
	e5:SetValue(s.immval)
	c:RegisterEffect(e5)
	-- 这张卡可以把1只怪兽解放作上级召唤。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,3))
	e6:SetCategory(CATEGORY_ATKCHANGE)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCode(EVENT_PHASE+PHASE_END)
	e6:SetCondition(s.atkcon)
	e6:SetOperation(s.atkop)
	c:RegisterEffect(e6)
end
-- 判断是否满足上级召唤条件
function s.otcon(e,c,minc)
	if c==nil then return true end
	-- 判断等级是否大于等于9且祭品数量为1
	return c:IsLevelAbove(9) and minc<=1 and Duel.CheckTribute(c,1)
end
-- 上级召唤操作函数
function s.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 选择祭品
	local g=Duel.SelectTribute(tp,c,1,1)
	c:SetMaterial(g)
	-- 解放祭品
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
end
-- 判断是否为结束阶段
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为当前回合玩家
	return tp==Duel.GetTurnPlayer()
end
-- 攻击力变化效果处理函数
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 使该卡攻击力上升700
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(700)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- 效果处理目标选择函数
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	-- 检查是否有满足条件的墓地怪兽
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示选择目标
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
end
-- 效果处理函数
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		-- 将目标怪兽送入手卡
		Duel.SendtoHand(tc,tp,REASON_EFFECT)
		-- 使该卡攻击力下降700
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		e1:SetValue(-700)
		c:RegisterEffect(e1)
	end
end
-- 判断目标怪兽是否满足条件
function s.thfilter(c)
	return c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST) and c:IsAbleToHand()
end
-- 效果免疫判断函数
function s.immval(e,te)
	local tc=te:GetOwner()
	local c=e:GetHandler()
	return tc:IsSummonType(SUMMON_TYPE_SPECIAL) and c:IsSummonType(SUMMON_TYPE_NORMAL)
		and te:IsActiveType(TYPE_MONSTER) and te:IsActivated() and te:GetActivateLocation()==LOCATION_MZONE
end
