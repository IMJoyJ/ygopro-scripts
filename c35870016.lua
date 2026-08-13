--剛鬼フィニッシュホールド
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上1只「刚鬼」连接怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升那个连接标记数量×1000，这个回合那只怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。这张卡的发动后，直到回合结束时自己不用「刚鬼」怪兽不能攻击宣言。
function c35870016.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己场上1只「刚鬼」连接怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升那个连接标记数量×1000，这个回合那只怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。这张卡的发动后，直到回合结束时自己不用「刚鬼」怪兽不能攻击宣言。
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
-- 过滤条件：卡片须为表侧表示，且具有「刚鬼」字段，且为连接怪兽。
function c35870016.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xfc) and c:IsType(TYPE_LINK)
end
-- 效果发动时的取对象处理：确认对象合法后，从自己场上选择1只满足条件的「刚鬼」连接怪兽作为效果对象。
function c35870016.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c35870016.filter(chkc) end
	-- 发动合法性检查：自己场上是否存在至少1只可选择的表侧表示「刚鬼」连接怪兽，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c35870016.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家显示选择提示“请选择表侧表示的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择自己场上1只表侧表示的「刚鬼」连接怪兽，并将该卡设定为效果对象。
	Duel.SelectTarget(tp,c35870016.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：①使对象怪兽攻击力上升连接标记数量×1000并获得贯穿能力；②直到结束阶段，自己场上的非「刚鬼」怪兽不能进行攻击宣言。
function c35870016.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果处理时对象怪兽的卡片实例。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只怪兽的攻击力直到回合结束时上升那个连接标记数量×1000。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(tc:GetLink()*1000)
		tc:RegisterEffect(e1)
		-- 这个回合那只怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_PIERCE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	-- 这张卡的发动后，直到回合结束时自己不用「刚鬼」怪兽不能攻击宣言。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(c35870016.atktg)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 将不能攻击宣言的限制效果注册到当前回合，持续到结束阶段，影响自己场上的怪兽。
	Duel.RegisterEffect(e3,tp)
end
-- 限制效果的目标判定：不是「刚鬼」的怪兽（即被禁止攻击宣言的对象）。
function c35870016.atktg(e,c)
	return not c:IsSetCard(0xfc)
end
