--リンク・バースト
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上1只连接怪兽和对方场上1只怪兽为对象才能发动。那些怪兽破坏。那之后，自己从卡组抽1张。
function c73287067.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己场上1只连接怪兽和对方场上1只怪兽为对象才能发动。那些怪兽破坏。那之后，自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,73287067+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c73287067.target)
	e1:SetOperation(c73287067.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己场上表侧表示连接怪兽的条件函数
function c73287067.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_LINK)
end
-- 效果发动的靶向检测与合法性判断
function c73287067.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己场上是否存在可作为对象的表侧表示连接怪兽
	if chk==0 then return Duel.IsExistingTarget(c73287067.filter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上是否存在可作为对象的怪兽
		and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil)
		-- 检查自己是否能够进行抽卡
		and Duel.IsPlayerCanDraw(tp,1) end
	-- 设置选择对象的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只表侧表示的连接怪兽作为对象
	local g1=Duel.SelectTarget(tp,c73287067.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置选择对象的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择对方场上1只怪兽作为对象
	local g2=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	g1:Merge(g2)
	-- 设置破坏操作的连锁信息，包含选中的2张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
	-- 设置抽卡操作的连锁信息，数量为1张
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理的执行函数
function c73287067.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与效果相关的对象卡片
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 破坏作为对象的怪兽，并判断是否成功破坏
	if tg:GetCount()>0 and Duel.Destroy(tg,REASON_EFFECT)~=0 then
		-- 中断当前效果，使后续的抽卡处理不与破坏同时进行
		Duel.BreakEffect()
		-- 自己从卡组抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
