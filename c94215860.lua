--夜叉
-- 效果：
-- 这张卡不能特殊召唤。召唤·反转的回合的结束阶段时回到持有者手卡。这张卡召唤·反转时，可以选择对方场上存在的1张魔法·陷阱卡回到持有者手卡。
function c94215860.initial_effect(c)
	-- 注册灵魂怪兽在通常召唤或翻转成功的回合结束阶段回到持有者手卡的效果
	aux.EnableSpiritReturn(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件为恒假，使该怪兽无法被任何方式特殊召唤
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 这张卡召唤·反转时，可以选择对方场上存在的1张魔法·陷阱卡回到持有者手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(94215860,0))  --"返回手牌"
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetTarget(c94215860.srettg)
	e4:SetOperation(c94215860.sretop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_FLIP)
	c:RegisterEffect(e5)
end
-- 过滤场上属于魔法或陷阱卡且可以送回手卡的卡片
function c94215860.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果发动的目标选择与条件检查函数（Target）
function c94215860.srettg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c94215860.filter(chkc) end
	-- 在发动效果时，检查对方场上是否存在至少1张符合条件的魔法或陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c94215860.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 在客户端向发动效果的玩家显示“请选择要返回手牌的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家选择对方场上1张符合条件的魔法或陷阱卡作为效果的对象
	local g=Duel.SelectTarget(tp,c94215860.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理的操作信息，声明此效果会将选中的1张卡送回手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果的实际处理函数（Operation）
function c94215860.sretop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动阶段被选为效果对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片因效果送回持有者的手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
