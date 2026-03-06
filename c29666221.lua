--オルフェゴール・アタック
-- 效果：
-- ①：自己或者对方的怪兽的攻击宣言时，把自己场上1只「自奏圣乐」怪兽或者「星遗物」怪兽解放，以对方场上1只怪兽为对象才能发动。那只怪兽除外。
function c29666221.initial_effect(c)
	-- 效果原文内容：①：自己或者对方的怪兽的攻击宣言时，把自己场上1只「自奏圣乐」怪兽或者「星遗物」怪兽解放，以对方场上1只怪兽为对象才能发动。那只怪兽除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCost(c29666221.cost)
	e1:SetTarget(c29666221.target)
	e1:SetOperation(c29666221.activate)
	c:RegisterEffect(e1)
end
-- 规则层面作用：定义过滤函数，用于判断是否为「自奏圣乐」或「星遗物」怪兽。
function c29666221.cfilter(c)
	return c:IsSetCard(0xfe,0x11b)
end
-- 规则层面作用：处理效果发动时的解放费用，检查并选择满足条件的怪兽进行解放。
function c29666221.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：在发动检查阶段判断是否满足解放条件。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c29666221.cfilter,1,nil) end
	-- 规则层面作用：从场上选择1张满足条件的怪兽作为解放对象。
	local g=Duel.SelectReleaseGroup(tp,c29666221.cfilter,1,1,nil)
	-- 规则层面作用：将选中的怪兽以REASON_COST原因进行解放。
	Duel.Release(g,REASON_COST)
end
-- 规则层面作用：设置效果的目标选择函数，用于选择对方场上的怪兽作为除外对象。
function c29666221.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	-- 规则层面作用：在发动检查阶段判断对方场上是否存在可除外的怪兽。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,nil) end
	-- 规则层面作用：向玩家发送提示信息，提示选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 规则层面作用：选择对方场上的1只怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,1,nil)
	-- 规则层面作用：设置当前连锁的操作信息，指定将要除外的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 规则层面作用：执行效果的处理函数，将目标怪兽除外。
function c29666221.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：获取当前连锁的效果对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 规则层面作用：将目标怪兽以正面表示的形式除外。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
