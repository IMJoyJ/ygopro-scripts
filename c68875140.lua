--押し売りゴブリン
-- 效果：
-- 每次自己场上的怪兽给与对方玩家战斗伤害，对方的魔法与陷阱卡区域存在的1张卡回到持有者手卡。
function c68875140.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 每次自己场上的怪兽给与对方玩家战斗伤害，对方的魔法与陷阱卡区域存在的1张卡回到持有者手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(68875140,0))  --"返回手牌"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetCondition(c68875140.condition)
	e2:SetTarget(c68875140.target)
	e2:SetOperation(c68875140.operation)
	c:RegisterEffect(e2)
end
-- 检查触发条件：受到战斗伤害的玩家是对方，且造成伤害的怪兽由自己控制。
function c68875140.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and eg:GetFirst():GetControler()==tp
end
-- 过滤条件：位于魔法与陷阱卡区域（不含场地卡）且可以回到手牌的卡。
function c68875140.filter(c)
	return c:GetSequence()<5 and c:IsAbleToHand()
end
-- 效果发动的目标选择：确认是否有合法的目标，并选择对方魔法与陷阱卡区域的1张卡作为对象。
function c68875140.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(1-tp) and c68875140.filter(chkc) end
	if chk==0 then return true end
	-- 提示玩家选择要返回手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择对方魔法与陷阱卡区域的1张卡作为效果的对象。
	local g=Duel.SelectTarget(tp,c68875140.filter,tp,0,LOCATION_SZONE,1,1,nil)
	if g:GetCount()>0 then
		-- 设置操作信息：将选中的卡片送回手牌。
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	end
end
-- 效果处理：将作为对象的卡片送回持有者的手牌。
function c68875140.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡片。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 通过效果将目标卡片送回持有者的手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
