--剛鬼フィニッシュホールド
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上1只「刚鬼」连接怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升那个连接标记数量×1000，这个回合那只怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。这张卡的发动后，直到回合结束时自己不用「刚鬼」怪兽不能攻击宣言。
function c35870016.initial_effect(c)
	-- 效果原文：这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,35870016+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c35870016.target)
	e1:SetOperation(c35870016.activate)
	c:RegisterEffect(e1)
end
-- 检索满足条件的「刚鬼」连接怪兽（表侧表示且为连接怪兽）
function c35870016.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xfc) and c:IsType(TYPE_LINK)
end
-- 效果原文：①：以自己场上1只「刚鬼」连接怪兽为对象才能发动。
function c35870016.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c35870016.filter(chkc) end
	-- 判断是否满足发动条件：场上是否存在符合条件的「刚鬼」连接怪兽
	if chk==0 then return Duel.IsExistingTarget(c35870016.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择一张表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择一张符合条件的「刚鬼」连接怪兽作为效果对象
	Duel.SelectTarget(tp,c35870016.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果原文：那只怪兽的攻击力直到回合结束时上升那个连接标记数量×1000，这个回合那只怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。这张卡的发动后，直到回合结束时自己不用「刚鬼」怪兽不能攻击宣言。
function c35870016.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 效果原文：那只怪兽的攻击力直到回合结束时上升那个连接标记数量×1000
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(tc:GetLink()*1000)
		tc:RegisterEffect(e1)
		-- 效果原文：这个回合那只怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_PIERCE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	-- 效果原文：这张卡的发动后，直到回合结束时自己不用「刚鬼」怪兽不能攻击宣言
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(c35870016.atktg)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 将不能攻击宣言的效果注册给全局环境
	Duel.RegisterEffect(e3,tp)
end
-- 判断目标怪兽是否不是「刚鬼」怪兽
function c35870016.atktg(e,c)
	return not c:IsSetCard(0xfc)
end
