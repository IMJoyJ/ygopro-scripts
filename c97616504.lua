--閃刀機構－ハーキュリーベース
-- 效果：
-- 自己的主要怪兽区域没有怪兽存在的场合才能把这张卡发动。
-- ①：装备怪兽不能直接攻击，同1次的战斗阶段中最多2次可以向怪兽攻击。
-- ②：装备怪兽的攻击破坏怪兽的场合，若自己墓地有魔法卡3张以上存在则发动。自己从卡组抽1张。
-- ③：这张卡被效果从场上送去墓地的场合，以「闪刀机构-大力神基地」以外的自己墓地最多3张「闪刀」卡为对象才能发动。那些卡回到卡组。
function c97616504.initial_effect(c)
	-- 自己的主要怪兽区域没有怪兽存在的场合才能把这张卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c97616504.condition)
	e1:SetTarget(c97616504.target)
	e1:SetOperation(c97616504.activate)
	c:RegisterEffect(e1)
	-- ①：装备怪兽不能直接攻击
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	c:RegisterEffect(e2)
	-- 同1次的战斗阶段中最多2次可以向怪兽攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- ②：装备怪兽的攻击破坏怪兽的场合，若自己墓地有魔法卡3张以上存在则发动。自己从卡组抽1张。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(97616504,0))
	e4:SetCategory(CATEGORY_DRAW)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EVENT_BATTLE_DESTROYING)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(c97616504.drcon)
	e4:SetTarget(c97616504.drtg)
	e4:SetOperation(c97616504.drop)
	c:RegisterEffect(e4)
	-- ③：这张卡被效果从场上送去墓地的场合，以「闪刀机构-大力神基地」以外的自己墓地最多3张「闪刀」卡为对象才能发动。那些卡回到卡组。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(97616504,1))
	e5:SetCategory(CATEGORY_TODECK)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetCondition(c97616504.tdcon)
	e5:SetTarget(c97616504.tdtg)
	e5:SetOperation(c97616504.tdop)
	c:RegisterEffect(e5)
	-- 装备限制
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e6:SetCode(EFFECT_EQUIP_LIMIT)
	e6:SetValue(1)
	c:RegisterEffect(e6)
end
-- 过滤条件：位于主要怪兽区域的怪兽
function c97616504.cfilter(c)
	return c:GetSequence()<5
end
-- 卡片发动条件判定函数
function c97616504.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己主要怪兽区域是否没有怪兽存在
	return not Duel.IsExistingMatchingCard(c97616504.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 卡片发动时的对象选择与操作信息设置函数
function c97616504.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查场上是否存在可以装备的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只表侧表示怪兽作为装备对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息为装备这张卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 卡片发动后的效果处理函数
function c97616504.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的装备对象怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡作为装备卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 抽卡效果的发动条件判定函数
function c97616504.drcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	-- 检查自己墓地是否有3张以上魔法卡，且被破坏的怪兽是被装备怪兽因攻击而破坏
	return Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_SPELL)>=3 and eg:GetFirst()==ec and Duel.GetAttacker()==ec
end
-- 抽卡效果的发动准备与操作信息设置函数
function c97616504.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果处理的参数为抽1张卡
	Duel.SetTargetParam(1)
	-- 设置操作信息为玩家抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 抽卡效果的实际处理函数
function c97616504.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取抽卡的目标玩家和抽卡张数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行效果抽卡
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 回卡组效果的发动条件判定函数
function c97616504.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤条件：自己墓地中「闪刀机构-大力神基地」以外的「闪刀」卡
function c97616504.tdfilter(c)
	return c:IsSetCard(0x115) and not c:IsCode(97616504) and c:IsAbleToDeck()
end
-- 回卡组效果的对象选择与操作信息设置函数
function c97616504.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c97616504.tdfilter(chkc) end
	-- 检查自己墓地是否存在至少1张满足条件的「闪刀」卡
	if chk==0 then return Duel.IsExistingTarget(c97616504.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己墓地最多3张满足条件的「闪刀」卡作为对象
	local g=Duel.SelectTarget(tp,c97616504.tdfilter,tp,LOCATION_GRAVE,0,1,3,nil)
	-- 设置操作信息为将选中的卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 回卡组效果的实际处理函数
function c97616504.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取仍与效果关联的对象卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 将目标卡片送回卡组并洗牌
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
