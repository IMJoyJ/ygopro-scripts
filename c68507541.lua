--アマゾネスペット虎獅子
-- 效果：
-- 「亚马逊宠物虎」＋「亚马逊」怪兽
-- ①：这张卡攻击的伤害计算时才能发动。这张卡的攻击力只在那次伤害计算时上升500。
-- ②：自己的「亚马逊」怪兽向对方怪兽攻击的伤害计算后，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力下降800。
-- ③：只要这张卡在怪兽区域存在，对方怪兽不能向这张卡以外的「亚马逊」怪兽攻击。
function c68507541.initial_effect(c)
	c:EnableReviveLimit()
	-- 设定融合召唤手续：「亚马逊宠物虎」＋「亚马逊」怪兽
	aux.AddFusionProcCodeFun(c,10979723,aux.FilterBoolFunction(Card.IsFusionSetCard,0x4),1,true,true)
	-- ①：这张卡攻击的伤害计算时才能发动。这张卡的攻击力只在那次伤害计算时上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(68507541,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetCondition(c68507541.atkcon1)
	e1:SetOperation(c68507541.atkop1)
	c:RegisterEffect(e1)
	-- ②：自己的「亚马逊」怪兽向对方怪兽攻击的伤害计算后，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力下降800。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(68507541,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLED)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(c68507541.atkcon2)
	e2:SetTarget(c68507541.atktg2)
	e2:SetOperation(c68507541.atkop2)
	c:RegisterEffect(e2)
	-- ③：只要这张卡在怪兽区域存在，对方怪兽不能向这张卡以外的「亚马逊」怪兽攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetValue(c68507541.atktg)
	c:RegisterEffect(e3)
end
-- 效果①的发动条件：这张卡进行攻击
function c68507541.atkcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前进行攻击的怪兽是否为自身
	return e:GetHandler()==Duel.GetAttacker()
end
-- 效果①的效果处理：使自身攻击力在伤害计算时上升500
function c68507541.atkop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡的攻击力只在那次伤害计算时上升500。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_DAMAGE_CAL)
		e1:SetValue(500)
		c:RegisterEffect(e1)
	end
end
-- 效果②的发动条件：自己的「亚马逊」怪兽向对方怪兽攻击的伤害计算后
function c68507541.atkcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	local d=a:GetBattleTarget()
	return a:IsControler(tp) and a:IsSetCard(0x4)
		and d and d:IsControler(1-tp)
end
-- 效果②的对象选择与判定
function c68507541.atktg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 判定对方场上是否存在可以作为对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上1只表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果②的效果处理：使作为对象的怪兽攻击力下降800
function c68507541.atkop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只怪兽的攻击力下降800。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(-800)
		tc:RegisterEffect(e1)
	end
end
-- 效果③的过滤条件：自身以外的表侧表示「亚马逊」怪兽
function c68507541.atktg(e,c)
	return c:IsFaceup() and c:IsSetCard(0x4) and c~=e:GetHandler()
end
