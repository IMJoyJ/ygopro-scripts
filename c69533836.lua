--魂を刻む右
-- 效果：
-- 自己场上的龙族同调怪兽才能装备。
-- ①：这张卡装备的「红莲魔龙」不受对方发动的效果影响。
-- ②：1回合1次，自己主要阶段才能发动。对方场上的全部怪兽的攻击力变成和装备怪兽相同。
-- ③：1回合1次，装备怪兽进行战斗的攻击宣言时，以对方墓地1只怪兽为对象才能发动。那只怪兽除外。装备怪兽的攻击力直到回合结束时上升除外的怪兽的攻击力数值。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- 将「红莲魔龙」的卡片密码加入该卡的关联卡片列表中
	aux.AddCodeList(c,70902743)
	-- 自己场上的龙族同调怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
	-- 自己场上的龙族同调怪兽才能装备。
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetValue(s.eqlimit)
	c:RegisterEffect(e2)
	-- ①：这张卡装备的「红莲魔龙」不受对方发动的效果影响。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetValue(s.immval)
	c:RegisterEffect(e3)
	-- ②：1回合1次，自己主要阶段才能发动。对方场上的全部怪兽的攻击力变成和装备怪兽相同。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(s.atktg)
	e4:SetOperation(s.atkop)
	c:RegisterEffect(e4)
	-- ③：1回合1次，装备怪兽进行战斗的攻击宣言时，以对方墓地1只怪兽为对象才能发动。那只怪兽除外。装备怪兽的攻击力直到回合结束时上升除外的怪兽的攻击力数值。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_REMOVE+CATEGORY_ATKCHANGE)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_ATTACK_ANNOUNCE)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCountLimit(1)
	e5:SetCondition(s.atkcon2)
	e5:SetTarget(s.atktg2)
	e5:SetOperation(s.atkop2)
	c:RegisterEffect(e5)
end
-- 装备限制：必须是自己场上的龙族同调怪兽
function s.eqlimit(e,c)
	return c:IsControler(e:GetHandlerPlayer()) and c:IsType(TYPE_SYNCHRO)
		and c:IsRace(RACE_DRAGON)
end
-- 过滤条件：自己场上的龙族同调怪兽
function s.eqfilter(c,tp)
	return c:IsControler(tp) and c:IsType(TYPE_SYNCHRO)
		and c:IsRace(RACE_DRAGON)
end
-- 装备魔法卡发动时的效果目标选择与处理准备
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.eqfilter(chkc,tp) and s.eqlimit(chkc) end
	-- 检查自己场上是否存在可以装备的龙族同调怪兽
	if chk==0 then return Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只龙族同调怪兽作为装备对象
	Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 设置效果处理信息：将这张卡装备给目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法卡发动时的效果处理：将这张卡装备给选择的怪兽
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的装备目标怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡作为装备卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 免疫效果的判定：装备怪兽是「红莲魔龙」时，不受对方发动的效果影响
function s.immval(e,re)
	local qc=e:GetHandler():GetEquipTarget()
	return re:IsActivated() and e:GetHandlerPlayer()~=re:GetOwnerPlayer() and qc and qc:IsCode(70902743)
end
-- 过滤条件：对方场上表侧表示且攻击力与装备怪兽不同的怪兽
function s.atkfilter(c,atk)
	return c:IsFaceup() and c:GetAttack()~=atk
end
-- 效果②的发动准备与可行性检查
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local qc=e:GetHandler():GetEquipTarget()
	-- 检查是否存在装备怪兽，且对方场上是否存在攻击力与装备怪兽不同的表侧表示怪兽
	if chk==0 then return qc and Duel.IsExistingMatchingCard(s.atkfilter,tp,0,LOCATION_MZONE,1,nil,qc:GetAttack()) end
end
-- 效果②的效果处理：将对方场上所有怪兽的攻击力变成和装备怪兽相同
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local qc=e:GetHandler():GetEquipTarget()
	if qc and qc:IsType(TYPE_MONSTER) and qc:IsFaceup() then
		local atk=qc:GetAttack()
		-- 获取对方场上所有攻击力与装备怪兽不同的表侧表示怪兽
		local g=Duel.GetMatchingGroup(s.atkfilter,tp,0,LOCATION_MZONE,nil,atk)
		-- 遍历获取到的怪兽集合
		for tc in aux.Next(g) do
			-- 对方场上的全部怪兽的攻击力变成和装备怪兽相同。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetValue(atk)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
end
-- 效果③的发动条件检查：装备怪兽进行战斗的攻击宣言时
function s.atkcon2(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetEquipTarget()
	-- 检查当前攻击怪兽或被攻击怪兽是否为装备怪兽
	return Duel.GetAttacker()==tc or Duel.GetAttackTarget()==tc
end
-- 过滤条件：对方墓地中攻击力不为0且可以除外的怪兽
function s.rmfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove() and not c:IsAttack(0)
end
-- 效果③的发动准备与目标选择
function s.atktg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and s.rmfilter(chkc) end
	-- 检查对方墓地是否存在满足除外条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter,tp,0,LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方墓地1只怪兽作为除外对象
	local g=Duel.SelectTarget(tp,s.rmfilter,tp,0,LOCATION_GRAVE,1,1,nil)
	-- 设置效果处理信息：将选择的对方墓地怪兽除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,1-tp,LOCATION_GRAVE)
end
-- 效果③的效果处理：除外目标怪兽，并使装备怪兽攻击力上升该数值
function s.atkop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的除外目标怪兽
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	local qc=c:GetEquipTarget()
	-- 检查目标怪兽是否仍适用效果，并将其表侧表示除外
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 then
		local atk=tc:GetAttack()
		if qc:IsFaceup() and c:IsRelateToEffect(e) and atk>0 then
			-- 装备怪兽的攻击力直到回合结束时上升除外的怪兽的攻击力数值。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(atk)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			qc:RegisterEffect(e1)
		end
	end
end
