--天子の指輪
-- 效果：
-- 有装备卡装备的自己场上的怪兽才能装备。
-- ①：「天子的指轮」在自己场上只能有1张表侧表示存在。
-- ②：对方发动的魔法卡的效果1回合只有1次无效化。
-- ③：1回合1次，这张卡装备中的场合才能发动。自己回复500基本分。那之后，这张卡破坏，以下效果适用。
-- ●只要这张卡装备过的怪兽在怪兽区域表侧表示存在，对方不能把那只怪兽作为效果的对象。
local s,id,o=GetID()
-- 初始化效果函数，注册4个效果：装备效果、装备限制、对方魔法发动时无效化、1回合1次的回复LP并破坏效果
function s.initial_effect(c)
	-- ①：「天子的指轮」在自己场上只能有1张表侧表示存在。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 有装备卡装备的自己场上的怪兽才能装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(s.eqlimit)
	c:RegisterEffect(e2)
	c:SetUniqueOnField(1,0,id)
	-- 对方发动的魔法卡的效果1回合只有1次无效化。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.discon)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
	-- 1回合1次，这张卡装备中的场合才能发动。自己回复500基本分。那之后，这张卡破坏，以下效果适用。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_RECOVER+CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(s.rdptg)
	e4:SetOperation(s.rdpop)
	c:RegisterEffect(e4)
end
-- 筛选自己场上已装备装备卡的怪兽
function s.filter(c)
	return c:GetEquipCount()>0
end
-- 设置装备效果的目标选择处理
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	-- 判断是否满足装备效果的发动条件
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择装备目标怪兽
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置装备效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备效果的发动处理函数
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取装备效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断装备是否成功
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then Duel.Equip(tp,c,tc) end
end
-- 装备限制效果的判断函数
function s.eqlimit(e,c)
	return c:IsControler(e:GetHandlerPlayer()) and c:GetEquipCount()>0
end
-- 无效化对方魔法发动的条件函数
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActiveType(TYPE_SPELL)
end
-- 无效化对方魔法发动的效果处理函数
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示对方无效化了该卡
	Duel.Hint(HINT_CARD,0,id)
	-- 使对方魔法发动无效
	Duel.NegateEffect(ev,true)
end
-- 设置回复LP并破坏效果的处理信息
function s.rdptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置回复LP的处理信息
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,500)
	-- 设置破坏自身卡的处理信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 回复LP并破坏自身卡的效果处理函数
function s.rdpop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetEquipTarget()
	-- 判断是否成功回复LP
	if Duel.Recover(tp,500,REASON_EFFECT)>0 then
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 判断是否成功破坏自身卡
		if Duel.Destroy(c,REASON_EFFECT)<=0 then return end
		-- 只要这张卡装备过的怪兽在怪兽区域表侧表示存在，对方不能把那只怪兽作为效果的对象。
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,2))  --"「天子的指轮」效果适用中"
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetOwnerPlayer(tp)
		e1:SetValue(s.tgval)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
	end
end
-- 判断对方是否不能将目标怪兽作为效果对象
function s.tgval(e,re,rp)
	return rp==1-e:GetOwnerPlayer()
end
