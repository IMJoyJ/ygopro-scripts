--エルロン
-- 效果：
-- 这个卡名在规则上也当作「闪刀」卡使用。这个卡名的①③的效果1回合只能有1次使用其中任意1个。
-- ①：自己·对方的主要阶段，以自己场上1只「闪刀姬」怪兽为对象才能发动。从自己的手卡·场上把这张卡当作装备魔法卡使用给那只怪兽装备。
-- ②：有这张卡装备的「闪刀姬」怪兽的攻击力上升400。
-- ③：场上的这张卡被破坏的场合才能发动。从卡组把1张「闪刀」魔法卡送去墓地。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- ①：自己·对方的主要阶段，以自己场上1只「闪刀姬」怪兽为对象才能发动。从自己的手卡·场上把这张卡当作装备魔法卡使用给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.eqcon)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
	-- ②：有这张卡装备的「闪刀姬」怪兽的攻击力上升400。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(400)
	e2:SetCondition(s.atkcon)
	c:RegisterEffect(e2)
	-- ③：场上的这张卡被破坏的场合才能发动。从卡组把1张「闪刀」魔法卡送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.tgcon)
	e3:SetTarget(s.tgtg)
	e3:SetOperation(s.tgop)
	c:RegisterEffect(e3)
end
-- 装备效果的发动条件函数：自己或对方的主要阶段
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前阶段是否为主要阶段1或主要阶段2
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 过滤条件：场上表侧表示的「闪刀姬」怪兽
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x1115)
end
-- 装备效果的发动准备与合法性检测函数
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) and chkc~=c end
	-- 判定魔法与陷阱区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and e:GetHandler():CheckUniqueOnField(tp)
		-- 判定自己场上是否存在除自身以外的、可作为装备对象的「闪刀姬」怪兽
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,c) end
	-- 提示玩家选择要装备的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只「闪刀姬」怪兽作为效果的对象
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,c)
end
-- 装备效果的执行函数，包含卡片合法性与区域空位的安全检查
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if c:IsLocation(LOCATION_MZONE) and c:IsFacedown() then return end
	-- 获取当前连锁中被选择的装备对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 判定魔法与陷阱区域是否无空位，或者装备对象怪兽已变成里侧表示
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsFacedown()
		or not tc:IsRelateToEffect(e) or not c:CheckUniqueOnField(tp) then
		-- 若无法装备，则将这张卡送去墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 将这张卡作为装备卡装备给目标怪兽，若装备失败则结束处理
	if not Duel.Equip(tp,c,tc) then return end
	-- 当作装备魔法卡使用给那只怪兽装备
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(s.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
end
-- 装备限制条件函数：只能装备给被选择的目标怪兽
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 攻击力上升效果的适用条件：装备对象是「闪刀姬」怪兽
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and ec:IsSetCard(0x1115)
end
-- 送墓效果的发动条件：场上的这张卡被破坏
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤条件：卡组中可以送去墓地的「闪刀」魔法卡
function s.tgfilter(c)
	return c:IsSetCard(0x115) and c:IsType(TYPE_SPELL) and c:IsAbleToGrave()
end
-- 送墓效果的发动准备与合法性检测函数
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定卡组中是否存在可送去墓地的「闪刀」魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息：从卡组将1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 送墓效果的执行函数
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组中选择1张满足条件的「闪刀」魔法卡
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选择的卡送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
