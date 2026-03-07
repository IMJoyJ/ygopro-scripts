--エクスプローシブ・マジシャン
-- 效果：
-- 调整＋调整以外的魔法师族怪兽1只以上
-- 可以把自己场上存在的2个魔力指示物取除，选择对方场上存在的1张魔法·陷阱卡破坏。
function c33413279.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整，1只调整以外的魔法师族怪兽
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsRace,RACE_SPELLCASTER),1)
	c:EnableReviveLimit()
	-- 可以把自己场上存在的2个魔力指示物取除，选择对方场上存在的1张魔法·陷阱卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(33413279,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(c33413279.descost)
	e1:SetTarget(c33413279.destg)
	e1:SetOperation(c33413279.desop)
	c:RegisterEffect(e1)
end
-- 支付效果代价，移除自己场上2个魔力指示物
function c33413279.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以移除2个魔力指示物
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x1,2,REASON_COST) end
	-- 移除自己场上2个魔力指示物
	Duel.RemoveCounter(tp,1,0,0x1,2,REASON_COST)
end
-- 过滤函数，判断目标是否为魔法或陷阱卡
function c33413279.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 设置效果目标，选择对方场上的魔法或陷阱卡
function c33413279.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c33413279.filter(chkc) end
	-- 检查对方场上是否存在魔法或陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c33413279.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的1张魔法或陷阱卡作为目标
	local g=Duel.SelectTarget(tp,c33413279.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果操作信息，确定破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理函数，破坏选中的魔法或陷阱卡
function c33413279.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
