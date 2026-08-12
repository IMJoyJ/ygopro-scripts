--忍法 空蝉の術
-- 效果：
-- 选择自己场上的名字有「忍者」字样的1只怪兽才能发动。只要这张卡在场上存在，被选择的怪兽不会被战斗破坏（伤害计算适用）。
function c89628781.initial_effect(c)
	-- 选择自己场上的名字有「忍者」字样的1只怪兽才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c89628781.target)
	e1:SetOperation(c89628781.operation)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上存在，被选择的怪兽不会被战斗破坏（伤害计算适用）。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_TARGET)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示的名字有「忍者」字样的怪兽
function c89628781.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x2b)
end
-- 效果发动时的对象选择与合法性检查
function c89628781.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c89628781.filter(chkc) end
	-- 在发动阶段，检查自己场上是否存在至少1只符合条件的「忍者」怪兽
	if chk==0 then return Duel.IsExistingTarget(c89628781.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家发送提示信息，要求选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的「忍者」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c89628781.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：若此卡与目标怪兽均在场，则将目标怪兽设为此卡的永续对象
function c89628781.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取在发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		c:SetCardTarget(tc)
	end
end
