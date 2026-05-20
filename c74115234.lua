--八尺勾玉
-- 效果：
-- 灵魂怪兽才能装备。装备怪兽战斗破坏对方怪兽送去墓地时，自己基本分回复破坏怪兽的原本攻击力的数值。装备怪兽从自己场上回到手卡让这张卡被送去墓地时，这张卡回到手卡。
function c74115234.initial_effect(c)
	-- 灵魂怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c74115234.target)
	e1:SetOperation(c74115234.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽战斗破坏对方怪兽送去墓地时，自己基本分回复破坏怪兽的原本攻击力的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(74115234,0))  --"LP回复"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c74115234.recon)
	e2:SetTarget(c74115234.retg)
	e2:SetOperation(c74115234.reop)
	c:RegisterEffect(e2)
	-- 灵魂怪兽才能装备。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(c74115234.eqlimit)
	c:RegisterEffect(e3)
	-- 装备怪兽从自己场上回到手卡让这张卡被送去墓地时，这张卡回到手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(74115234,1))  --"返回手牌"
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(c74115234.retcon)
	e4:SetTarget(c74115234.rettg)
	e4:SetOperation(c74115234.retop)
	c:RegisterEffect(e4)
end
c74115234.has_text_type=TYPE_SPIRIT
-- 装备限制：只能装备于灵魂怪兽
function c74115234.eqlimit(e,c)
	return c:IsType(TYPE_SPIRIT)
end
-- 过滤条件：场上表侧表示的灵魂怪兽
function c74115234.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPIRIT)
end
-- 装备魔法卡发动时的对象选择与判定
function c74115234.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c74115234.filter(chkc) end
	-- 判定场上是否存在可以装备的表侧表示灵魂怪兽
	if chk==0 then return Duel.IsExistingTarget(c74115234.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择1只表侧表示的灵魂怪兽作为装备对象
	Duel.SelectTarget(tp,c74115234.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 装备魔法卡发动处理：将这张卡装备给目标怪兽
function c74115234.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中选择的装备目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡作为装备卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
	end
end
-- 判定装备怪兽是否战斗破坏对方怪兽并送去墓地，并记录被破坏的怪兽
function c74115234.recon(e,tp,eg,ep,ev,re,r,rp)
	local ec=eg:GetFirst()
	local bc=ec:GetBattleTarget()
	e:SetLabelObject(bc)
	return e:GetHandler():GetEquipTarget()==eg:GetFirst() and ec:IsControler(tp)
		and bc:IsLocation(LOCATION_GRAVE) and bc:IsType(TYPE_MONSTER) and bc:IsReason(REASON_BATTLE)
end
-- 回复效果的启动判定与参数设定：获取被破坏怪兽的原本攻击力并设置回复信息
function c74115234.retg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local v=e:GetLabelObject():GetBaseAttack()
	if v<0 then v=0 end
	-- 设置回复效果的受益玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置回复效果的数值为被破坏怪兽的原本攻击力
	Duel.SetTargetParam(v)
	-- 向系统宣告当前连锁的处理信息为回复自己对应数值的基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,v)
end
-- 回复效果的实际处理
function c74115234.reop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取回复效果的受益玩家和回复数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 因效果使玩家回复对应的基本分
	Duel.Recover(p,d,REASON_EFFECT)
end
-- 判定是否因装备怪兽从自己场上回到手卡而导致这张卡失去装备对象送去墓地
function c74115234.retcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetPreviousEquipTarget()
	return c:IsReason(REASON_LOST_TARGET) and ec and ec:IsLocation(LOCATION_HAND) and ec:IsPreviousControler(tp)
end
-- 判定这张卡是否能回到手卡，并设置操作信息
function c74115234.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 向系统宣告当前连锁的处理信息为将这张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 将这张卡回到手卡并给对方确认
function c74115234.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡加入持有者的手卡
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		-- 将加入手卡的这张卡给对方玩家确认
		Duel.ConfirmCards(1-tp,c)
	end
end
