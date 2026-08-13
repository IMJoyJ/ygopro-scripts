--レインボー・ヴェール
-- 效果：
-- 装备怪兽和对方怪兽进行战斗的场合，只在战斗阶段内那只对方怪兽的效果无效化。
local s,id,o=GetID()
-- 为“虹之衣”注册所有效果：发动并装备给怪兽、装备限制、战斗时给战斗对象打标记、无效对方怪兽效果的永续效果（分别用效果无效和无效果无效实现）。
function c12735388.initial_effect(c)
	-- 装备怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c12735388.target)
	e1:SetOperation(c12735388.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 和对方怪兽进行战斗的场合
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BE_BATTLE_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCondition(s.discon1)
	e3:SetOperation(s.disop1)
	c:RegisterEffect(e3)
	-- 只在战斗阶段内那只对方怪兽的效果无效化
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
-- 效果发动时的取对象处理：选择我方场上1只表侧表示怪兽作为这张卡的装备对象。
function c12735388.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 发动合法性检查：确认我方场上是否存在至少1只表侧表示怪兽可作为装备对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 给玩家显示“请选择要装备的卡”的提示，要求选择装备对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 从自己场上选择1只表侧表示怪兽，并将其设为这张卡发动时取的对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 将本次连锁的操作信息记录为装备效果，使后续处理时把此卡装备给对象。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理时，若此卡和对象仍与效果关联且对象仍表侧表示，则进行装备操作。
function c12735388.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的那只装备对象怪兽。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 把这张装备魔法卡装备给对象怪兽。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 战斗时点触发判定：检查装备怪兽是否是攻击怪兽或攻击对象，并且存在战斗对象。
function s.discon1(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	-- 返回条件：装备怪兽正在参与战斗（作为攻击方或攻击对象）且有对应的战斗对象。
	return ec and (ec==Duel.GetAttacker() or ec==Duel.GetAttackTarget()) and ec:GetBattleTarget()
end
-- 给与该装备怪兽战斗的对方怪兽注册一个标记，标记在战斗阶段结束或标准离场等重置条件下清除，用于限定无效化只在战斗阶段内适用。
function s.disop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetEquipTarget():GetBattleTarget()
	tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE,0,1)
	-- 手动刷新场上卡片状态，使打上标记的对方怪兽立刻被无效化。
	Duel.AdjustInstantly(c)
end
-- 无效化效果的过滤条件：只对带有标记的对方怪兽适用效果无效化。
function s.distg(e,c)
	return c:GetFlagEffect(id)~=0
end
