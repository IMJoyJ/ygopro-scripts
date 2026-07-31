--対壊獣用決戦兵器スーパーメカドゴラン
-- 效果：
-- 这张卡不能通常召唤。对方场上有「坏兽」怪兽存在的场合可以特殊召唤。
-- ①：「坏兽」怪兽在自己场上只能有1只表侧表示存在。
-- ②：1回合1次，把自己·对方场上2个坏兽指示物取除才能发动。从自己的手卡·墓地选1只「坏兽」怪兽当作装备卡使用给这张卡装备。
-- ③：这张卡的攻击力上升这张卡的效果装备的「坏兽」怪兽的原本攻击力数值。
function c84769941.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置「坏兽」怪兽在自己场上只能有1只表侧表示存在
	c:SetUniqueOnField(1,0,aux.FilterBoolFunction(Card.IsSetCard,0xd3),LOCATION_MZONE)
	-- 这张卡不能通常召唤。对方场上有「坏兽」怪兽存在的场合可以特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c84769941.spcon)
	c:RegisterEffect(e1)
	-- ②：1回合1次，把自己·对方场上2个坏兽指示物取除才能发动。从自己的手卡·墓地选1只「坏兽」怪兽当作装备卡使用给这张卡装备。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(84769941,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c84769941.eqcost)
	e2:SetTarget(c84769941.eqtg)
	e2:SetOperation(c84769941.eqop)
	c:RegisterEffect(e2)
	-- ③：这张卡的攻击力上升这张卡的效果装备的「坏兽」怪兽的原本攻击力数值。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(c84769941.atkval)
	c:RegisterEffect(e3)
end
c84769941.mentioned_counter={
	[0x37]=true,
}
-- 特殊召唤条件过滤：对方场上表侧表示的「坏兽」怪兽
function c84769941.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xd3)
end
-- 特殊召唤手牌此卡的发动条件检查
function c84769941.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查己方怪兽区域是否有空位
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查对方场上是否存在表侧表示的「坏兽」怪兽
		and Duel.IsExistingMatchingCard(c84769941.cfilter,tp,0,LOCATION_MZONE,1,nil)
end
-- ②效果发动Cost：把自己·对方场上2个坏兽指示物取除
function c84769941.eqcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- Cost检查：场上是否存在至少2个坏兽指示物
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,1,0x37,2,REASON_COST) end
	-- 取除场上2个坏兽指示物
	Duel.RemoveCounter(tp,1,1,0x37,2,REASON_COST)
end
-- 装备卡过滤条件：手牌·墓地的「坏兽」怪兽且可以放置在魔陷区
function c84769941.eqfilter(c)
	return c:IsSetCard(0xd3) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
-- ②效果发动准备：检查魔法与陷阱区域空位及可装备的「坏兽」怪兽并设置操作信息
function c84769941.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：魔法与陷阱区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 发动条件检查：手牌或墓地是否存在可装备的「坏兽」怪兽
		and Duel.IsExistingMatchingCard(c84769941.eqfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil) end
	-- 设置连锁操作信息：涉及从墓地移动卡片的操作
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
-- ②效果处理：从手牌·墓地选1只「坏兽」怪兽给此卡装备
function c84769941.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 魔法与陷阱区域无空位时终止效果处理
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 从手牌或墓地选择1只满足条件的「坏兽」怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c84769941.eqfilter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的怪兽当作装备卡装备给此卡，若失败则终止
		if not Duel.Equip(tp,tc,c) then return end
		tc:RegisterFlagEffect(84769941,RESET_EVENT+RESETS_STANDARD,0,0)
		-- 装备限制：只能装备给「对坏兽用决战兵器 超级机械多哥兰」
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c84769941.eqlimit)
		tc:RegisterEffect(e1)
	end
end
-- 装备限制条件：装备卡的目标必须是效果来源卡
function c84769941.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 攻击力上升过滤条件：由自身效果装备的「坏兽」怪兽
function c84769941.atkfilter(c)
	return c:IsSetCard(0xd3) and c:GetAttack()>=0 and c:GetFlagEffect(84769941)~=0
end
-- 计算所有由自身效果装备的「坏兽」怪兽的原本攻击力合计值
function c84769941.atkval(e,c)
	local g=e:GetHandler():GetEquipGroup():Filter(c84769941.atkfilter,nil)
	return g:GetSum(Card.GetAttack)
end
