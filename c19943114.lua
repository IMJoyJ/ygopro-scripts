--サイバネット・リグレッション
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己对连接怪兽的特殊召唤成功的场合，以场上1张卡为对象才能发动。那张卡破坏。那之后，自己从卡组抽1张。
function c19943114.initial_effect(c)
	-- 效果原文内容：①：自己对连接怪兽的特殊召唤成功的场合，以场上1张卡为对象才能发动。那张卡破坏。那之后，自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,19943114+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c19943114.condition)
	e1:SetTarget(c19943114.target)
	e1:SetOperation(c19943114.activate)
	c:RegisterEffect(e1)
end
-- 规则层面作用：检查怪兽是否为连接怪兽且由玩家召唤
function c19943114.cfilter(c,tp)
	return c:IsType(TYPE_LINK) and c:IsSummonPlayer(tp)
end
-- 规则层面作用：判断是否有连接怪兽被特殊召唤成功
function c19943114.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c19943114.cfilter,1,nil,tp)
end
-- 规则层面作用：设置效果发动时的取对象处理条件
function c19943114.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc~=e:GetHandler() end
	-- 规则层面作用：检查玩家是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 规则层面作用：检查场上是否存在可破坏的卡
		and Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 规则层面作用：向玩家发送提示信息，提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 规则层面作用：选择场上1张卡作为效果对象
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 规则层面作用：设置破坏效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 规则层面作用：设置抽卡效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果原文内容：①：自己对连接怪兽的特殊召唤成功的场合，以场上1张卡为对象才能发动。那张卡破坏。那之后，自己从卡组抽1张。
function c19943114.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：获取当前连锁效果的目标卡
	local tc=Duel.GetFirstTarget()
	-- 规则层面作用：判断目标卡是否仍然存在于场上并成功破坏
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 规则层面作用：中断当前效果处理，使后续处理视为错时点
		Duel.BreakEffect()
		-- 规则层面作用：让玩家从卡组抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
