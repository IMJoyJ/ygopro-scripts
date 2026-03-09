--マジェスペクター・サイクロン
-- 效果：
-- ①：把自己场上1只魔法师族·风属性怪兽解放，以对方场上1只怪兽为对象才能发动。那只怪兽破坏。
function c49366157.initial_effect(c)
	-- ①：把自己场上1只魔法师族·风属性怪兽解放，以对方场上1只怪兽为对象才能发动。那只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCost(c49366157.cost)
	e1:SetTarget(c49366157.target)
	e1:SetOperation(c49366157.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断是否为魔法师族且风属性的怪兽
function c49366157.cfilter(c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_WIND)
end
-- 检查玩家场上是否存在满足条件的怪兽并选择1只进行解放作为发动代价
function c49366157.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测是否满足发动条件：场上有满足条件的怪兽数量不少于1张
	if chk==0 then return Duel.CheckReleaseGroup(tp,c49366157.cfilter,1,nil) end
	-- 从玩家场上选择1张满足条件的怪兽
	local g=Duel.SelectReleaseGroup(tp,c49366157.cfilter,1,1,nil)
	-- 将选中的怪兽以代價原因进行解放
	Duel.Release(g,REASON_COST)
end
-- 设置效果的目标为对方场上的任意1只怪兽
function c49366157.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 检测是否满足发动条件：对方场上存在至少1只怪兽可以成为对象
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息，表明将要进行破坏效果
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果发动时执行的操作：破坏选定的目标怪兽
function c49366157.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因破坏目标怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
