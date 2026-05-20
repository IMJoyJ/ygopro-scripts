--エレキャッシュ
-- 效果：
-- 3星以下的雷族怪兽才能装备。装备怪兽的攻击力上升800，效果无效化。装备怪兽给与对方基本分战斗伤害时，从自己卡组抽1张卡。
function c84428023.initial_effect(c)
	-- 3星以下的雷族怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c84428023.target)
	e1:SetOperation(c84428023.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽的攻击力上升800
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(800)
	c:RegisterEffect(e2)
	-- 效果无效化。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_DISABLE)
	c:RegisterEffect(e3)
	-- 3星以下的雷族怪兽才能装备。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_EQUIP_LIMIT)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetValue(c84428023.eqlimit)
	c:RegisterEffect(e4)
	-- 装备怪兽给与对方基本分战斗伤害时，从自己卡组抽1张卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(84428023,0))  --"抽卡"
	e4:SetCategory(CATEGORY_DRAW)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_DAMAGE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCondition(c84428023.drcon)
	e4:SetTarget(c84428023.drtg)
	e4:SetOperation(c84428023.drop)
	c:RegisterEffect(e4)
end
-- 判断怪兽是否为3星以下的雷族怪兽，用于限制合法的装备对象
function c84428023.eqlimit(e,c)
	return c:IsLevelBelow(3) and c:IsRace(RACE_THUNDER)
end
-- 过滤场上表侧表示的3星以下的雷族怪兽
function c84428023.filter(c)
	return c:IsLevelBelow(3) and c:IsFaceup() and c:IsRace(RACE_THUNDER)
end
-- 装备卡发动时的对象选择与效果处理
function c84428023.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c84428023.filter(chkc) end
	-- 在发动时，判断场上是否存在可以装备的合法对象
	if chk==0 then return Duel.IsExistingTarget(c84428023.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只符合条件的怪兽作为装备对象并进行取对象
	Duel.SelectTarget(tp,c84428023.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁的操作信息为装备这张卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备卡发动成功时的效果处理，将卡装备给目标怪兽
function c84428023.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的装备对象怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡作为装备卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 判断是否为装备怪兽给对方造成战斗伤害，作为抽卡效果的触发条件
function c84428023.drcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and r==REASON_BATTLE and eg:GetFirst()==e:GetHandler():GetEquipTarget()
end
-- 设置抽卡效果的对象玩家、参数以及操作信息
function c84428023.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将效果的对象玩家设置为当前发动效果的玩家
	Duel.SetTargetPlayer(tp)
	-- 将效果的对象参数设置为1（抽卡数量）
	Duel.SetTargetParam(1)
	-- 设置连锁的操作信息为从卡组抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 执行抽卡效果，让指定玩家抽指定数量的卡
function c84428023.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁信息中的对象玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家从卡组抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
