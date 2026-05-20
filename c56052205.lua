--貫ガエル
-- 效果：
-- 这张卡可以直接攻击对方玩家。这张卡直接攻击成功时，自己场上有「贯青蛙」以外的名字带有「青蛙」的怪兽存在的场合，可以把对方场上1张魔法·陷阱卡破坏。
function c56052205.initial_effect(c)
	-- 这张卡可以直接攻击对方玩家。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e1)
	-- 这张卡直接攻击成功时，自己场上有「贯青蛙」以外的名字带有「青蛙」的怪兽存在的场合，可以把对方场上1张魔法·陷阱卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(56052205,0))  --"把对方场上1张魔法·陷阱卡破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetCondition(c56052205.condition)
	e2:SetTarget(c56052205.target)
	e2:SetOperation(c56052205.operation)
	c:RegisterEffect(e2)
end
-- 过滤自己场上表侧表示的、除「贯青蛙」以外的名字带有「青蛙」的怪兽
function c56052205.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x12) and not c:IsCode(56052205)
end
-- 判断是否满足“直接攻击成功给对方造成战斗伤害”以及“自己场上存在「贯青蛙」以外的名字带有「青蛙」的怪兽”的发动条件
function c56052205.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否是给对方造成战斗伤害，且攻击对象为空（即直接攻击成功）
	return ep~=tp and Duel.GetAttackTarget()==nil
		-- 检查自己场上是否存在至少1只表侧表示的「贯青蛙」以外的「青蛙」怪兽
		and Duel.IsExistingMatchingCard(c56052205.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤魔法·陷阱卡
function c56052205.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果发动时的对象选择处理，确认对方场上是否存在魔法·陷阱卡，并选择其中1张作为效果对象，设置破坏的操作信息
function c56052205.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and c56052205.filter(chkc) end
	-- 在效果发动阶段（chk==0）检查对方场上是否存在可以作为对象的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c56052205.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 给发动效果的玩家发送“请选择要破坏的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让发动效果的玩家选择对方场上1张魔法·陷阱卡作为效果对象
	local g=Duel.SelectTarget(tp,c56052205.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置当前连锁的操作信息，表示该效果的处理为破坏选中的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理阶段，再次确认自己场上是否存在「贯青蛙」以外的「青蛙」怪兽，若存在则破坏选中的对象卡
function c56052205.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时，再次检查自己场上是否存在「贯青蛙」以外的「青蛙」怪兽，若不存在则不处理效果
	if not Duel.IsExistingMatchingCard(c56052205.cfilter,tp,LOCATION_MZONE,0,1,nil) then return end
	-- 获取在发动阶段选择的效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 因效果将目标卡片破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
