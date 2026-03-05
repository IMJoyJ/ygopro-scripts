--レインボー・ヴェール
-- 效果：
-- 装备怪兽和对方怪兽进行战斗的场合，只在战斗阶段内那只对方怪兽的效果无效化。
local s,id,o=GetID()
-- 创建装备魔法卡的效果，设置为自由连锁发动，目标为己方场上表侧表示的怪兽，效果处理时进行装备操作
function c12735388.initial_effect(c)
	-- 装备怪兽和对方怪兽进行战斗的场合，只在战斗阶段内那只对方怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c12735388.target)
	e1:SetOperation(c12735388.operation)
	c:RegisterEffect(e1)
	-- 装备对象限制，只能装备给1只怪兽
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 当装备怪兽被选为攻击对象时触发的效果
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BE_BATTLE_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCondition(s.discon1)
	e3:SetOperation(s.disop1)
	c:RegisterEffect(e3)
	-- 对装备怪兽所装备的对方怪兽进行效果无效化
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_DISABLE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(0,LOCATION_MZONE)
	e4:SetTarget(s.distg)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_DISABLE_EFFECT)
	c:RegisterEffect(e5)
end
-- 判断是否满足装备目标条件，即己方场上存在表侧表示的怪兽
function c12735388.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 判断是否满足装备目标条件，即己方场上存在表侧表示的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择装备目标，从己方场上选择1只表侧表示的怪兽
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息，表示将装备卡装备给目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备卡的发动处理函数，将装备卡装备给选择的目标怪兽
function c12735388.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的装备目标
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将装备卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 判断是否满足无效化条件，即装备怪兽为攻击怪兽或被攻击怪兽
function s.discon1(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	-- 判断是否满足无效化条件，即装备怪兽为攻击怪兽或被攻击怪兽
	return ec and (ec==Duel.GetAttacker() or ec==Duel.GetAttackTarget()) and ec:GetBattleTarget()
end
-- 设置无效化标志，使目标怪兽在战斗阶段内效果无效
function s.disop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetEquipTarget():GetBattleTarget()
	tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE,0,1)
	-- 立即刷新场上受影响卡牌的状态
	Duel.AdjustInstantly(c)
end
-- 判断目标怪兽是否具有无效化标志，用于确定是否进行效果无效化
function s.distg(e,c)
	return c:GetFlagEffect(id)~=0
end
