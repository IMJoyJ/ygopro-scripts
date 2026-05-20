--BK チート・コミッショナー
-- 效果：
-- 3星怪兽×2
-- 只要这张卡在场上表侧表示存在，可以攻击的对方怪兽必须作出攻击。此外，自己场上有这张卡以外的名字带有「燃烧拳击手」的怪兽存在的场合，对方不能把这张卡作为攻击对象。这张卡以外的自己的名字带有「燃烧拳击手」的怪兽进行战斗的攻击宣言时，把这张卡2个超量素材取除才能发动。把对方手卡确认，从那之中选1张魔法卡在自己场上盖放。
function c76589815.initial_effect(c)
	-- 设置该卡XYZ召唤的素材为3星怪兽2只。
	aux.AddXyzProcedure(c,nil,3,2)
	c:EnableReviveLimit()
	-- 只要这张卡在场上表侧表示存在，可以攻击的对方怪兽必须作出攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetCode(EFFECT_MUST_ATTACK)
	c:RegisterEffect(e1)
	-- 此外，自己场上有这张卡以外的名字带有「燃烧拳击手」的怪兽存在的场合，对方不能把这张卡作为攻击对象。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e3:SetCondition(c76589815.atcon)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- 这张卡以外的自己的名字带有「燃烧拳击手」的怪兽进行战斗的攻击宣言时，把这张卡2个超量素材取除才能发动。把对方手卡确认，从那之中选1张魔法卡在自己场上盖放。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(76589815,0))  --"确认手牌"
	e3:SetCategory(CATEGORY_SSET)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c76589815.cfcon)
	e3:SetCost(c76589815.cfcost)
	e3:SetTarget(c76589815.cftg)
	e3:SetOperation(c76589815.cfop)
	c:RegisterEffect(e3)
end
-- 过滤自己场上表侧表示的「燃烧拳击手」怪兽。
function c76589815.atfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1084)
end
-- 检查自己场上是否存在这张卡以外的名字带有「燃烧拳击手」的怪兽。
function c76589815.atcon(e)
	-- 检查自己场上是否存在至少1只除自身以外的表侧表示「燃烧拳击手」怪兽。
	return Duel.IsExistingMatchingCard(c76589815.atfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end
-- 检查是否是这张卡以外的自己的名字带有「燃烧拳击手」的怪兽进行战斗的攻击宣言时。
function c76589815.cfcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取攻击宣言时的攻击怪兽。
	local a=Duel.GetAttacker()
	-- 获取攻击宣言时的被攻击怪兽。
	local at=Duel.GetAttackTarget()
	return (a:IsControler(tp) and a~=e:GetHandler() and a:IsSetCard(0x1084))
		or (at and at:IsControler(tp) and at:IsFaceup() and at~=e:GetHandler() and at:IsSetCard(0x1084))
end
-- 效果发动的代价：把这张卡2个超量素材取除。
function c76589815.cfcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
-- 检查对方手卡数量是否大于0且自己魔陷区是否有空位。
function c76589815.cftg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方手卡数量是否大于0。
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0
		-- 检查自己魔陷区是否有空位。
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
end
-- 过滤可以盖放在自己场上的魔法卡。
function c76589815.cffilter(c,tp)
	-- 检查卡片是否为魔法卡、是否可以盖放，且满足场地魔法或魔陷区有空位的条件。
	return c:IsType(TYPE_SPELL) and c:IsSSetable(true) and (c:IsType(TYPE_FIELD) or Duel.GetLocationCount(tp,LOCATION_SZONE)>0)
end
-- 效果处理：确认对方手卡，选择其中1张魔法卡在自己场上盖放，之后洗切对方手卡。
function c76589815.cfop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方的所有手卡。
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if g:GetCount()==0 then return end
	-- 给自己确认对方的所有手卡。
	Duel.ConfirmCards(tp,g)
	local sg=g:Filter(c76589815.cffilter,nil,tp)
	if sg:GetCount()>0 then
		-- 提示玩家选择要盖放的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		local setg=sg:Select(tp,1,1,nil)
		-- 将选中的魔法卡在自己场上盖放。
		Duel.SSet(tp,setg:GetFirst())
	end
	-- 洗切对方的手卡。
	Duel.ShuffleHand(1-tp)
end
