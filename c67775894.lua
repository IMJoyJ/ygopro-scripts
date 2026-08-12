--ワンダー・ワンド
-- 效果：
-- 魔法师族怪兽才能装备。
-- ①：装备怪兽的攻击力上升500。
-- ②：把装备怪兽和这张卡从自己场上送去墓地才能发动。自己从卡组抽2张。
function c67775894.initial_effect(c)
	-- 魔法师族怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c67775894.target)
	e1:SetOperation(c67775894.operation)
	c:RegisterEffect(e1)
	-- ①：装备怪兽的攻击力上升500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(500)
	c:RegisterEffect(e2)
	-- 魔法师族怪兽才能装备。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(c67775894.eqlimit)
	c:RegisterEffect(e3)
	-- ②：把装备怪兽和这张卡从自己场上送去墓地才能发动。自己从卡组抽2张。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(67775894,0))  --"抽卡"
	e4:SetCategory(CATEGORY_DRAW)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCost(c67775894.drcost)
	e4:SetTarget(c67775894.drtg)
	e4:SetOperation(c67775894.drop)
	c:RegisterEffect(e4)
end
-- 装备限制：此卡只能装备给魔法师族怪兽
function c67775894.eqlimit(e,c)
	return c:IsRace(RACE_SPELLCASTER)
end
-- 过滤条件：场上表侧表示的魔法师族怪兽
function c67775894.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER)
end
-- 效果发动：选择场上1只表侧表示的魔法师族怪兽作为装备对象
function c67775894.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c67775894.filter(chkc) end
	-- 检查场上是否存在可以装备的合法怪兽
	if chk==0 then return Duel.IsExistingTarget(c67775894.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家发送提示信息，要求选择装备对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择并锁定1只符合条件的魔法师族怪兽作为装备对象
	Duel.SelectTarget(tp,c67775894.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息：装备此卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理：将这张卡装备给选择的目标怪兽
function c67775894.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的装备对象怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡作为装备卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 发动代价：检查自身和装备怪兽是否能送去墓地，且控制权是否一致
function c67775894.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() and c:GetControler()==c:GetEquipTarget():GetControler()
		and c:GetEquipTarget():IsAbleToGraveAsCost() end
	local g=Group.FromCards(c,c:GetEquipTarget())
	-- 将自身和装备怪兽送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果发动：检查并设置抽卡效果的目标玩家和抽卡数量
function c67775894.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家当前是否可以执行抽2张卡的操作
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 将当前发动效果的玩家设为效果影响的目标玩家
	Duel.SetTargetPlayer(tp)
	-- 将抽卡数量参数设置为2
	Duel.SetTargetParam(2)
	-- 设置效果处理信息：抽卡，数量为2
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果处理：执行抽卡
function c67775894.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁信息中的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡操作，让目标玩家从卡组抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
