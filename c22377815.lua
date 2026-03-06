--水面のアレサ
-- 效果：
-- 这张卡在墓地或者场上表侧表示存在的场合，当作通常怪兽使用。场上表侧表示存在的这张卡可以作当通常召唤使用的再度召唤，这张卡当作效果怪兽使用并得到以下效果。
-- ●这张卡战斗破坏对方怪兽送去墓地时，对方手卡随机丢弃1张。
function c22377815.initial_effect(c)
	-- 为卡片添加二重怪兽属性
	aux.EnableDualAttribute(c)
	-- ●这张卡战斗破坏对方怪兽送去墓地时，对方手卡随机丢弃1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(22377815,0))  --"手牌丢弃"
	e1:SetCategory(CATEGORY_HANDES)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetCondition(c22377815.con)
	e1:SetTarget(c22377815.tg)
	e1:SetOperation(c22377815.op)
	c:RegisterEffect(e1)
end
-- 判断该效果是否满足发动条件，包括是否为再度召唤状态以及是否与对方怪兽战斗并破坏对方怪兽
function c22377815.con(e,tp,eg,ep,ev,re,r,rp)
	-- 满足再度召唤状态且与对方怪兽战斗并破坏对方怪兽的条件
	return aux.IsDualState(e) and aux.bdogcon(e,tp,eg,ep,ev,re,r,rp)
end
-- 设置效果的处理目标，确定对方手牌丢弃的数量
function c22377815.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理信息，指定对方手牌丢弃1张
	Duel.SetOperationInfo(0,CATEGORY_HANDES,0,0,1-tp,1)
end
-- 执行效果的处理操作，随机选择对方手牌并丢弃
function c22377815.op(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的手牌组
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if g:GetCount()==0 then return end
	local sg=g:RandomSelect(1-tp,1)
	-- 将选中的对方手牌送去墓地并记录丢弃原因
	Duel.SendtoGrave(sg,REASON_DISCARD+REASON_EFFECT)
end
