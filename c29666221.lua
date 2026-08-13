--オルフェゴール・アタック
-- 效果：
-- ①：自己或者对方的怪兽的攻击宣言时，把自己场上1只「自奏圣乐」怪兽或者「星遗物」怪兽解放，以对方场上1只怪兽为对象才能发动。那只怪兽除外。
function c29666221.initial_effect(c)
	-- ①：自己或者对方的怪兽的攻击宣言时，把自己场上1只「自奏圣乐」怪兽或者「星遗物」怪兽解放，以对方场上1只怪兽为对象才能发动。那只怪兽除外。
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
-- 过滤条件：检查卡片是否为「自奏圣乐」或「星遗物」系列的怪兽，用于选择可解放的己方场上怪兽。
function c29666221.cfilter(c)
	return c:IsSetCard(0xfe,0x11b)
end
-- 代价函数：在发动时确认己方场上存在满足条件的可解放怪兽，选择1只解放作为发动代价。
function c29666221.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：确认己方场上存在至少1只满足「自奏圣乐」或「星遗物」条件的可解放怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c29666221.cfilter,1,nil) end
	-- 从己方场上选择1只满足「自奏圣乐」或「星遗物」条件的怪兽作为解放对象。
	local g=Duel.SelectReleaseGroup(tp,c29666221.cfilter,1,1,nil)
	-- 将选择的怪兽解放，作为效果发动时支付的代价。
	Duel.Release(g,REASON_COST)
end
-- 目标函数：选择对方场上1只可以被除外的怪兽作为效果对象，并设置效果处理的除外信息。
function c29666221.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	-- 发动合法性检查：确认对方场上存在至少1只可以被除外的怪兽。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家显示选择提示，提示内容为“请选择要除外的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方场上的1只可以被除外的怪兽作为效果对象，并将该对象与当前连锁关联。
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：本次效果处理将执行除外操作，处理对象为已选择的那1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果处理函数：将效果对象中仍与效果关联的怪兽表侧表示除外。
function c29666221.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽表侧表示除外，此为效果处理结果。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
