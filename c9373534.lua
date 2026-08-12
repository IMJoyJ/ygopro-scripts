--風魔手裏剣
-- 效果：
-- 名称中含有「忍者」字样的怪兽才能装备这张卡。装备这张卡的怪兽攻击力上升700点。这张卡从场上送去墓地时，给与对方基本分700分的伤害。
function c9373534.initial_effect(c)
	-- 名称中含有「忍者」字样的怪兽才能装备这张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c9373534.target)
	e1:SetOperation(c9373534.operation)
	c:RegisterEffect(e1)
	-- 装备这张卡的怪兽攻击力上升700点。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(700)
	c:RegisterEffect(e2)
	-- 名称中含有「忍者」字样的怪兽才能装备这张卡。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(c9373534.eqlimit)
	c:RegisterEffect(e3)
	-- 这张卡从场上送去墓地时，给与对方基本分700分的伤害。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(9373534,0))  --"给予对方700分伤害"
	e4:SetCategory(CATEGORY_DAMAGE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(c9373534.damcon)
	e4:SetTarget(c9373534.damtg)
	e4:SetOperation(c9373534.damop)
	c:RegisterEffect(e4)
end
-- 限制装备对象为「忍者」怪兽
function c9373534.eqlimit(e,c)
	return c:IsSetCard(0x2b)
end
-- 过滤场上表侧表示的「忍者」怪兽
function c9373534.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x2b)
end
-- 装备魔法卡发动时的对象选择与效果处理准备
function c9373534.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c9373534.filter(chkc) end
	-- 检查场上是否存在可以装备的表侧表示「忍者」怪兽
	if chk==0 then return Duel.IsExistingTarget(c9373534.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只表侧表示的「忍者」怪兽作为装备对象
	Duel.SelectTarget(tp,c9373534.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息为装备这张卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法卡发动后的效果处理，将自身装备给目标怪兽
function c9373534.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的装备对象怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡作为装备卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 判定这张卡是否是从场上送去墓地
function c9373534.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 伤害效果的发动准备，设置伤害参数和操作信息
function c9373534.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果的对象玩家为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置效果的对象参数为700点伤害
	Duel.SetTargetParam(700)
	-- 设置效果处理信息为给与对方700点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,700)
end
-- 伤害效果的处理，给与对方玩家伤害
function c9373534.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的对象玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 给与目标玩家对应数值的效果伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
