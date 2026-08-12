--Aiシャドー
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。以自己场上1只「@火灵天星」怪兽为对象才能把这张卡发动。
-- ①：只要这张卡在魔法与陷阱区域存在，作为对象的怪兽的攻击力上升800，可以攻击的对方怪兽必须向作为对象的怪兽作出攻击。
-- ②：魔法与陷阱区域的表侧表示的这张卡因对方的效果从场上离开，被送去墓地的场合或者被除外的场合发动。自己从卡组抽1张。
function c77421977.initial_effect(c)
	-- 以自己场上1只「@火灵天星」怪兽为对象才能把这张卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CONTINUOUS_TARGET)
	-- 设置发动条件为不在伤害计算后（配合DAMAGE_STEP标记，限制在伤害步骤中只能在伤害计算前发动）。
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c77421977.target)
	e1:SetOperation(c77421977.activate)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在魔法与陷阱区域存在，作为对象的怪兽的攻击力上升800
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_TARGET)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetValue(800)
	c:RegisterEffect(e2)
	-- 可以攻击的对方怪兽必须向作为对象的怪兽作出攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_MUST_ATTACK)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetCondition(c77421977.effcon)
	c:RegisterEffect(e3)
	-- 可以攻击的对方怪兽必须向作为对象的怪兽作出攻击。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_MUST_ATTACK_MONSTER)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(0,LOCATION_MZONE)
	e4:SetCondition(c77421977.effcon)
	e4:SetValue(c77421977.atklimit)
	c:RegisterEffect(e4)
	-- 这个卡名的②的效果1回合只能使用1次。②：魔法与陷阱区域的表侧表示的这张卡因对方的效果从场上离开，被送去墓地的场合或者被除外的场合发动。自己从卡组抽1张。
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_DRAW)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetCountLimit(1,77421977)
	e5:SetCondition(c77421977.drcon)
	e5:SetTarget(c77421977.drtg)
	e5:SetOperation(c77421977.drop)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e6)
end
-- 过滤条件：表侧表示且是「@火灵天星」怪兽。
function c77421977.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x135)
end
-- 效果发动的目标选择与合法性检测。
function c77421977.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c77421977.cfilter(chkc) end
	-- 检查自己场上是否存在可以作为对象的表侧表示「@火灵天星」怪兽。
	if chk==0 then return Duel.IsExistingTarget(c77421977.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只表侧表示的「@火灵天星」怪兽作为对象并将其设为连锁对象。
	Duel.SelectTarget(tp,c77421977.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 魔法卡发动时的效果处理（建立持续对象关系）。
function c77421977.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		c:SetCardTarget(tc)
	end
end
-- 判定此卡是否存在持续指向的对象怪兽，作为强制攻击效果的适用条件。
function c77421977.effcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFirstCardTarget()~=nil
end
-- 限制对方怪兽只能攻击此卡指向的对象怪兽。
function c77421977.atklimit(e,c)
	return e:GetHandler():IsHasCardTarget(c)
end
-- 判定此卡是否在魔陷区表侧表示因对方效果离场并送墓/除外。
function c77421977.drcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousLocation(LOCATION_SZONE) and c:IsPreviousControler(tp)
		and c:IsReason(REASON_EFFECT) and rp==1-tp
end
-- 抽卡效果的发动准备与操作信息注册。
function c77421977.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置抽卡效果的对象玩家为自己。
	Duel.SetTargetPlayer(tp)
	-- 设置抽卡数量为1张。
	Duel.SetTargetParam(1)
	-- 注册连锁处理中的操作信息为“玩家抽1张卡”。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 抽卡效果的实际执行处理。
function c77421977.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和抽卡张数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行因效果让目标玩家抽指定张数的卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
