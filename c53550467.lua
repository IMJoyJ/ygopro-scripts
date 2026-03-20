--聖騎士トリスタン
-- 效果：
-- 「圣骑士 崔斯坦」的②的效果1回合只能使用1次。
-- ①：只要自己场上有这张卡以外的「圣骑士」怪兽存在，对方不能把这张卡以外的自己场上的攻击力未满1800的怪兽作为攻击对象，也不能作为效果的对象。
-- ②：让这张卡把「圣剑」装备魔法卡装备的场合，以场上1张表侧表示的卡为对象发动。那张表侧表示的卡破坏。
function c53550467.initial_effect(c)
	-- ①：只要自己场上有这张卡以外的「圣骑士」怪兽存在，对方不能把这张卡以外的自己场上的攻击力未满1800的怪兽作为攻击对象，也不能作为效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetCondition(c53550467.con)
	e1:SetValue(c53550467.atlimit)
	c:RegisterEffect(e1)
	-- ①：只要自己场上有这张卡以外的「圣骑士」怪兽存在，对方不能把这张卡以外的自己场上的攻击力未满1800的怪兽作为攻击对象，也不能作为效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(c53550467.con)
	e2:SetTarget(c53550467.tglimit)
	-- 设置效果值为aux.tgoval函数，用于判断目标是否不会成为对方效果的对象
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- ②：让这张卡把「圣剑」装备魔法卡装备的场合，以场上1张表侧表示的卡为对象发动。那张表侧表示的卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(53550467,0))  --"破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_EQUIP)
	e3:SetCountLimit(1,53550467)
	e3:SetCondition(c53550467.descon)
	e3:SetTarget(c53550467.destg)
	e3:SetOperation(c53550467.desop)
	c:RegisterEffect(e3)
end
-- 过滤函数：检查场上是否存在表侧表示的「圣骑士」怪兽
function c53550467.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x107a)
end
-- 条件函数：判断自己场上是否存在其他「圣骑士」怪兽
function c53550467.con(e)
	-- 检查以当前玩家来看，自己场上是否存在至少1张满足cfilter条件的怪兽
	return Duel.IsExistingMatchingCard(c53550467.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end
-- 限制函数：判断目标怪兽是否不是自己且攻击力小于1800
function c53550467.atlimit(e,c)
	return c~=e:GetHandler() and c:IsFaceup() and c:GetAttack()<1800
end
-- 限制函数：判断目标怪兽是否不是自己且攻击力小于1800
function c53550467.tglimit(e,c)
	return c~=e:GetHandler() and c:GetAttack()<1800
end
-- 条件函数：判断装备的卡是否为「圣剑」系列
function c53550467.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSetCard,1,nil,0x207a)
end
-- 过滤函数：检查目标是否为表侧表示的卡
function c53550467.desfilter(c)
	return c:IsFaceup()
end
-- 设置发动时选择目标的处理函数，提示选择要破坏的卡
function c53550467.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c53550467.desfilter(chkc) end
	if chk==0 then return true end
	-- 向玩家提示“请选择要破坏的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上一张表侧表示的卡作为破坏对象
	local g=Duel.SelectTarget(tp,c53550467.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息，确定将要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 执行破坏操作，将目标卡破坏
function c53550467.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的目标卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将目标卡以效果原因破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
