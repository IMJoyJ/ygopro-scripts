--バーバリアン・レイジ
-- 效果：
-- ①：以自己场上1只战士族怪兽为对象才能把这张卡发动。那只怪兽的攻击力上升1000，那只怪兽战斗破坏的怪兽不送去墓地回到持有者手卡。作为对象的怪兽从场上离开时这张卡破坏。
function c42233477.initial_effect(c)
	-- 对应效果原文：①：以自己场上1只战士族怪兽为对象才能把这张卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设定伤害步骤条件限制：仅在伤害步骤且伤害计算前允许发动，配合EFFECT_FLAG_DAMAGE_STEP在伤害步骤内使用。
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c42233477.target)
	e1:SetOperation(c42233477.activate)
	c:RegisterEffect(e1)
	-- 对应效果原文：作为对象的怪兽从场上离开时这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCondition(c42233477.descon)
	e2:SetOperation(c42233477.desop)
	c:RegisterEffect(e2)
	-- 对应效果原文：那只怪兽的攻击力上升1000。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_TARGET)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_SZONE)
	e3:SetValue(1000)
	c:RegisterEffect(e3)
	-- 对应效果原文：那只怪兽战斗破坏的怪兽不送去墓地回到持有者手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_TARGET)
	e4:SetCode(EFFECT_BATTLE_DESTROY_REDIRECT)
	e4:SetRange(LOCATION_SZONE)
	e4:SetValue(LOCATION_HAND)
	c:RegisterEffect(e4)
end
-- 过滤函数：用于判定一张卡是否为表侧表示的战士族怪兽，作为本卡的取对象选择条件。
function c42233477.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR)
end
-- 发动时的取对象处理：若为连锁确认对象则检查所指定卡是否合法；若为发动条件检测则检查场上是否存在符合条件的怪兽；最后让玩家选择1只自己场上的表侧战士族怪兽作为对象。
function c42233477.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c42233477.filter(chkc) end
	-- 发动条件检测：chk==0时，检查自己场上是否存在至少1只符合条件的表侧战士族怪兽，存在才可以发动。
	if chk==0 then return Duel.IsExistingTarget(c42233477.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家显示选择提示消息“请选择表侧表示的卡”，为接下来的选卡操作设置提示文字。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从自己场上选择1只符合条件的表侧战士族怪兽，并将其设为这张卡的发动对象。
	Duel.SelectTarget(tp,c42233477.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理时：确认这张卡及其对象仍然与效果关联后，将对象怪兽设为这张卡的永续对象，以持续提供加攻、战斗破坏回手及离场破坏的后续效果。
function c42233477.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的取对象怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		c:SetCardTarget(tc)
	end
end
-- 自毁效果的触发条件：这张卡的永续对象怪兽在本事件中发生了离场。
function c42233477.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	return tc and eg:IsContains(tc)
end
-- 自毁效果的处理：将这张卡自身破坏。
function c42233477.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果破坏这张卡自身，因为其对象怪兽已经从场上离开。
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
