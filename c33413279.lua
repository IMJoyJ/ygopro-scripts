--エクスプローシブ・マジシャン
-- 效果：
-- 调整＋调整以外的魔法师族怪兽1只以上
-- 可以把自己场上存在的2个魔力指示物取除，选择对方场上存在的1张魔法·陷阱卡破坏。
function c33413279.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和1只调整以外的魔法师族怪兽
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
c33413279.mentioned_counter={
	[0x1]=true,
}
-- 支付效果代价：移除自己场上2个魔力指示物
function c33413279.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以移除自己场上的2个魔力指示物作为代价
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x1,2,REASON_COST) end
	-- 执行移除自己场上2个魔力指示物的操作
	Duel.RemoveCounter(tp,1,0,0x1,2,REASON_COST)
end
-- 定义过滤函数，用于筛选魔法或陷阱卡
function c33413279.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 设置效果目标选择阶段，选择对方场上的魔法或陷阱卡
function c33413279.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c33413279.filter(chkc) end
	-- 检查对方场上是否存在魔法或陷阱卡作为目标
	if chk==0 then return Duel.IsExistingTarget(c33413279.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向玩家提示选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的1张魔法或陷阱卡作为目标
	local g=Duel.SelectTarget(tp,c33413279.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁操作信息，确定将要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理阶段，破坏选定的目标卡片
function c33413279.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
