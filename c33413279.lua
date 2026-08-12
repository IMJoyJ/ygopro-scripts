--エクスプローシブ・マジシャン
-- 效果：
-- 调整＋调整以外的魔法师族怪兽1只以上
-- 可以把自己场上存在的2个魔力指示物取除，选择对方场上存在的1张魔法·陷阱卡破坏。
function c33413279.initial_effect(c)
	-- 为这张卡添加同调召唤手续：不限制调整怪兽，非调整部分要求1只以上的魔法师族怪兽
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
-- 效果发动的代价处理函数：检查并把自己场上的2个魔力指示物取除作为发动代价
function c33413279.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己能否以发动代价为由取除场上2个魔力指示物（发动条件的判定）
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x1,2,REASON_COST) end
	-- 以发动代价为由取除自己场上存在的2个魔力指示物
	Duel.RemoveCounter(tp,1,0,0x1,2,REASON_COST)
end
-- 目标过滤函数：筛选魔法·陷阱卡
function c33413279.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果的对象选择函数：确认对方场上存在可作为对象的魔法·陷阱卡，由玩家选择1张作为效果对象，并设置破坏的操作信息
function c33413279.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c33413279.filter(chkc) end
	-- 检查对方场上是否存在1张以上可以成为效果对象的魔法·陷阱卡（能否发动的判定）
	if chk==0 then return Duel.IsExistingTarget(c33413279.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向玩家发出「请选择要破坏的卡」的选择提示消息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择对方场上1张魔法·陷阱卡，并将其设置为当前连锁的效果对象
	local g=Duel.SelectTarget(tp,c33413279.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置当前连锁的操作信息为破坏效果，对象为选择的1张卡，供其他卡的效果发动检测使用
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理函数：取得效果对象，若其仍与该效果关联则将其破坏
function c33413279.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果为由将对象卡破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
