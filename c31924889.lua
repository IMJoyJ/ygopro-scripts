--アーカナイト・マジシャン
-- 效果：
-- 调整＋调整以外的魔法师族怪兽1只以上
-- ①：这张卡同调召唤的场合发动。给这张卡放置2个魔力指示物。
-- ②：这张卡的攻击力上升这张卡的魔力指示物数量×1000。
-- ③：把自己场上1个魔力指示物取除，以对方场上1张卡为对象才能发动。那张对方的卡破坏。
function c31924889.initial_effect(c)
	c:EnableCounterPermit(0x1)
	-- 添加同调召唤手续，要求1只调整和1只调整以外的魔法师族怪兽作为素材
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsRace,RACE_SPELLCASTER),1)
	c:EnableReviveLimit()
	-- ②：这张卡的攻击力上升这张卡的魔力指示物数量×1000。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c31924889.attackup)
	c:RegisterEffect(e1)
	-- ①：这张卡同调召唤的场合发动。给这张卡放置2个魔力指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(31924889,0))  --"放置魔力指示物"
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c31924889.addcc)
	e2:SetTarget(c31924889.addct)
	e2:SetOperation(c31924889.addc)
	c:RegisterEffect(e2)
	-- ③：把自己场上1个魔力指示物取除，以对方场上1张卡为对象才能发动。那张对方的卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(31924889,1))  --"破坏一张卡"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCost(c31924889.descost)
	e3:SetTarget(c31924889.destg)
	e3:SetOperation(c31924889.desop)
	c:RegisterEffect(e3)
end
c31924889.mentioned_counter={
	[0x1]=true,
}
-- 计算攻击力上升值，每有1个魔力指示物则增加1000点攻击力
function c31924889.attackup(e,c)
	return c:GetCounter(0x1)*1000
end
-- 判断是否为同调召唤成功触发
function c31924889.addcc(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 设置连锁操作信息，准备放置2个魔力指示物
function c31924889.addct(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，指定将要放置2个魔力指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,2,0,0x1)
end
-- 为自身放置2个魔力指示物
function c31924889.addc(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():AddCounter(0x1,2)
	end
end
-- 支付破坏效果的代价，移除自身1个魔力指示物
function c31924889.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否可以移除1个魔力指示物作为代价
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x1,1,REASON_COST) end
	-- 执行移除1个魔力指示物的操作
	Duel.RemoveCounter(tp,1,0,0x1,1,REASON_COST)
end
-- 选择对方场上的1张卡作为破坏对象
function c31924889.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 判断是否存在对方场上的卡可作为破坏对象
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向玩家提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的1张卡作为目标
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息，指定将要破坏1张对方的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏选定的对方卡片
function c31924889.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsControler(1-tp) then
		-- 执行破坏目标卡片的操作
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
