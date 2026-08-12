--超重忍者サルト－B
-- 效果：
-- 机械族调整＋调整以外的「超重武者」怪兽1只以上
-- 这张卡在规则上也当作「超重武者」卡使用。
-- ①：这张卡可以用表侧守备表示的状态作出攻击。那个场合，这张卡用守备力当作攻击力使用进行伤害计算。
-- ②：1回合1次，自己墓地没有魔法·陷阱卡存在的场合，以场上1张魔法·陷阱卡为对象才能发动。那张卡破坏，给与对方500伤害。这个效果在对方回合也能发动。
function c76471944.initial_effect(c)
	-- 设置同调召唤手续：机械族调整 + 1只以上调整以外的「超重武者」怪兽
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_MACHINE),aux.NonTuner(Card.IsSetCard,0x9a),1)
	c:EnableReviveLimit()
	-- ①：这张卡可以用表侧守备表示的状态作出攻击。那个场合，这张卡用守备力当作攻击力使用进行伤害计算。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DEFENSE_ATTACK)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己墓地没有魔法·陷阱卡存在的场合，以场上1张魔法·陷阱卡为对象才能发动。那张卡破坏，给与对方500伤害。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(76471944,0))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c76471944.descon)
	e2:SetTarget(c76471944.destg)
	e2:SetOperation(c76471944.desop)
	c:RegisterEffect(e2)
end
-- 定义效果②的发动条件函数：自己墓地没有魔法·陷阱卡存在
function c76471944.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己墓地是否存在魔法或陷阱卡，若不存在则返回true
	return not Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_SPELL+TYPE_TRAP)
end
-- 过滤场上的魔法·陷阱卡
function c76471944.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 定义效果②的发动准备函数（检查与选择目标，设置操作信息）
function c76471944.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c76471944.desfilter(chkc) end
	-- 在发动阶段（chk==0）检查场上是否存在可以作为对象的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c76471944.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张魔法·陷阱卡作为效果的对象
	local g=Duel.SelectTarget(tp,c76471944.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：破坏选中的卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息：给与对方500点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 定义效果②的效果处理函数（破坏对象并造成伤害）
function c76471944.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时的对象卡片
	local tc=Duel.GetFirstTarget()
	-- 若对象卡片仍适应此效果，则将其破坏，并判断是否破坏成功
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 给与对方500点伤害
		Duel.Damage(1-tp,500,REASON_EFFECT)
	end
end
