--エヴォルダー・ディプロドクス
-- 效果：
-- 这张卡用名字带有「进化虫」的怪兽的效果特殊召唤成功时，选择对方场上存在的1张魔法·陷阱卡破坏。
function c17045014.initial_effect(c)
	-- 这张卡用名字带有「进化虫」的怪兽的效果特殊召唤成功时，选择对方场上存在的1张魔法·陷阱卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(17045014,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	-- 效果触发条件为使用「进化虫」怪兽的效果特殊召唤成功
	e1:SetCondition(aux.evospcon)
	e1:SetTarget(c17045014.destg)
	e1:SetOperation(c17045014.desop)
	c:RegisterEffect(e1)
end
-- 定义过滤器函数，用于判断目标是否为魔法或陷阱卡
function c17045014.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 设置效果的目标选择函数，选择对方场上的魔法或陷阱卡
function c17045014.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c17045014.desfilter(chkc) end
	if chk==0 then return true end
	-- 向玩家提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的一张魔法或陷阱卡作为目标
	local g=Duel.SelectTarget(tp,c17045014.desfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁操作信息，表明将要破坏目标卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 设置效果的处理函数，执行破坏操作
function c17045014.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标卡片因效果原因破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
