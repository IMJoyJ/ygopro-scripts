--サブテラーの激闘
-- 效果：
-- ①：自己场上的「地中族」怪兽的攻击力·守备力上升场上的里侧表示怪兽数量×500。
-- ②：1回合1次，自己的「地中族」怪兽给与对方战斗伤害时，以「地中族的激斗」以外的自己墓地1张「地中族」卡为对象才能发动。那张卡加入手卡。
function c68001309.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己场上的「地中族」怪兽的攻击力·守备力上升场上的里侧表示怪兽数量×500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 设置效果影响的目标为自己场上的「地中族」怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xed))
	e2:SetValue(c68001309.atkval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- ②：1回合1次，自己的「地中族」怪兽给与对方战斗伤害时，以「地中族的激斗」以外的自己墓地1张「地中族」卡为对象才能发动。那张卡加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(68001309,0))
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_BATTLE_DAMAGE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c68001309.thcon)
	e4:SetTarget(c68001309.thtg)
	e4:SetOperation(c68001309.thop)
	c:RegisterEffect(e4)
end
-- 计算攻击力/守备力上升数值的函数
function c68001309.atkval(e,c)
	-- 返回双方场上里侧表示怪兽数量×500的数值
	return Duel.GetMatchingGroupCount(Card.IsFacedown,e:GetHandlerPlayer(),LOCATION_MZONE,LOCATION_MZONE,nil)*500
end
-- 检测是否满足发动条件：自己的「地中族」怪兽给与对方战斗伤害
function c68001309.thcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=eg:GetFirst()
	return ep~=tp and rc:IsControler(tp) and rc:IsSetCard(0xed)
end
-- 过滤自己墓地中「地中族的激斗」以外的「地中族」卡片且能加入手牌的卡
function c68001309.thfilter(c)
	return c:IsSetCard(0xed) and not c:IsCode(68001309) and c:IsAbleToHand()
end
-- 效果发动的目标选择与检测函数
function c68001309.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c68001309.thfilter(chkc) end
	-- 在发动时，检测自己墓地是否存在符合条件的卡片
	if chk==0 then return Duel.IsExistingTarget(c68001309.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1张符合条件的卡片作为效果对象
	local sg=Duel.SelectTarget(tp,c68001309.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息为将选中的卡片加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,1,0,0)
end
-- 效果处理的执行函数
function c68001309.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的卡片
	local tc=Duel.GetFirstTarget()
	-- 判断对象卡片是否仍对该效果有效，且不受「王家之谷」的影响
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) then
		-- 将目标卡片加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
