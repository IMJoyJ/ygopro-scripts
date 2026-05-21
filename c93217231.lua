--毒蛇の供物
-- 效果：
-- ①：以自己场上1只爬虫类族怪兽和对方场上2张卡为对象才能发动。那1只自己的爬虫类族怪兽和那2张对方的卡破坏。
function c93217231.initial_effect(c)
	-- ①：以自己场上1只爬虫类族怪兽和对方场上2张卡为对象才能发动。那1只自己的爬虫类族怪兽和那2张对方的卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c93217231.target)
	e1:SetOperation(c93217231.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己场上表侧表示的爬虫类族怪兽
function c93217231.filter1(c)
	return c:IsFaceup() and c:IsRace(RACE_REPTILE)
end
-- 发动时的对象选择与合法性检测
function c93217231.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己场上是否存在1只可成为对象的表侧表示爬虫类族怪兽
	if chk==0 then return Duel.IsExistingTarget(c93217231.filter1,tp,LOCATION_MZONE,0,1,nil)
		-- 以及对方场上是否存在2张可成为对象的卡
		and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,2,nil) end
	-- 提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上1只表侧表示的爬虫类族怪兽作为效果对象
	local g1=Duel.SelectTarget(tp,c93217231.filter1,tp,LOCATION_MZONE,0,1,1,nil)
	e:SetLabelObject(g1:GetFirst())
	-- 提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上2张卡作为效果对象
	local g2=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,2,2,nil)
	g1:Merge(g2)
	-- 设置破坏效果的操作信息，包含所有选中的对象卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,g1:GetCount(),0,0)
end
-- 效果处理：验证对象状态并破坏选中的卡片
function c93217231.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次连锁中被选为效果对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	local sc=e:GetLabelObject()
	if sg:GetCount()~=3 or sc:IsFacedown() or not sc:IsRace(RACE_REPTILE) or sc:IsControler(1-tp) then return end
	-- 将符合条件的卡片因效果破坏
	Duel.Destroy(sg,REASON_EFFECT)
end
