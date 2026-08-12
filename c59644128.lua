--剛鬼ジェット・オーガ
-- 效果：
-- 「刚鬼」怪兽2只
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：1回合1次，以自己场上1张「刚鬼」卡为对象才能发动。那张卡破坏，场上的怪兽全部变成表侧攻击表示。
-- ②：这张卡从场上送去墓地的场合才能发动。自己场上的全部「刚鬼」怪兽的攻击力直到回合结束时上升500。
function c59644128.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加连接召唤手续：需要2只「刚鬼」怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0xfc),2,2)
	-- ①：1回合1次，以自己场上1张「刚鬼」卡为对象才能发动。那张卡破坏，场上的怪兽全部变成表侧攻击表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(59644128,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c59644128.postg)
	e1:SetOperation(c59644128.posop)
	c:RegisterEffect(e1)
	-- ②：这张卡从场上送去墓地的场合才能发动。自己场上的全部「刚鬼」怪兽的攻击力直到回合结束时上升500。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(59644128,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,59644128)
	e2:SetCondition(c59644128.atkcon)
	e2:SetTarget(c59644128.atktg)
	e2:SetOperation(c59644128.atkop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示的「刚鬼」卡，且场上存在可以改变表示形式的怪兽
function c59644128.desfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xfc)
		-- 检查场上是否存在至少1只处于守备表示或里侧表示的怪兽（排除作为破坏对象的卡本身）
		and Duel.IsExistingMatchingCard(c59644128.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c)
end
-- 过滤条件：处于守备表示或里侧表示的怪兽
function c59644128.posfilter(c)
	return c:IsDefensePos() or c:IsFacedown()
end
-- 效果①的发动准备：检查并选择自己场上1张表侧表示的「刚鬼」卡作为破坏对象
function c59644128.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c59644128.desfilter(chkc,tp) end
	-- 检查自己场上是否存在符合条件的「刚鬼」卡作为效果对象
	if chk==0 then return Duel.IsExistingTarget(c59644128.desfilter,tp,LOCATION_ONFIELD,0,1,nil,tp) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择1张符合条件的「刚鬼」卡作为效果对象
	local g=Duel.SelectTarget(tp,c59644128.desfilter,tp,LOCATION_ONFIELD,0,1,1,nil,tp)
	-- 设置操作信息：包含破坏1张卡的操作
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果①的处理：破坏选择的卡，并将场上的怪兽全部变成表侧攻击表示
function c59644128.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果①选择的对象卡
	local tc=Duel.GetFirstTarget()
	-- 若对象卡仍符合条件，则将其因效果破坏；若成功破坏，则继续处理
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 获取场上所有守备表示或里侧表示的怪兽
		local g=Duel.GetMatchingGroup(c59644128.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		if g:GetCount()==0 then return end
		-- 将这些怪兽全部变成表侧攻击表示
		Duel.ChangePosition(g,POS_FACEUP_ATTACK)
	end
end
-- 效果②的发动条件：此卡之前存在于场上
function c59644128.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤条件：自己场上表侧表示的「刚鬼」怪兽
function c59644128.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xfc)
end
-- 效果②的发动准备：检查自己场上是否存在表侧表示的「刚鬼」怪兽
function c59644128.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只表侧表示的「刚鬼」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c59644128.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 效果②的处理：使自己场上全部「刚鬼」怪兽的攻击力直到回合结束时上升500
function c59644128.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有表侧表示的「刚鬼」怪兽
	local g=Duel.GetMatchingGroup(c59644128.atkfilter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 攻击力直到回合结束时上升500
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
