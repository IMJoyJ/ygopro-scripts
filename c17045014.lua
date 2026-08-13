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
	-- 设置效果的发动条件：此卡用名字带有「进化虫」的怪兽的效果特殊召唤成功时（通过aux.evospcon判断召唤类型）。
	e1:SetCondition(aux.evospcon)
	e1:SetTarget(c17045014.destg)
	e1:SetOperation(c17045014.desop)
	c:RegisterEffect(e1)
end
-- 定义破坏对象过滤器：对方场上的魔法·陷阱卡（即卡的类型为魔法或陷阱）。
function c17045014.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 目标选择函数：发动时从对方场上选择1张魔法·陷阱卡作为破坏对象；若为连锁确认对象合法性，则检查该卡是否仍在对方场上且为魔法·陷阱卡。
function c17045014.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c17045014.desfilter(chkc) end
	if chk==0 then return true end
	-- 向玩家显示“请选择要破坏的卡”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从对方场上选择1张魔法·陷阱卡作为效果对象。
	local g=Duel.SelectTarget(tp,c17045014.desfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：本次效果将破坏所选择的对象卡，数量为其张数（1张）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理函数：若对象卡仍与效果关联，则将其破坏。
function c17045014.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果的对象卡（由于只选择1张，故直接用GetFirstTarget获取唯一对象）。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 以效果原因（REASON_EFFECT）破坏该对象卡。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
