--魂を刻む右
-- 效果：
-- 自己场上的龙族同调怪兽才能装备。
-- ①：这张卡装备的「红莲魔龙」不受对方发动的效果影响。
-- ②：1回合1次，自己主要阶段才能发动。对方场上的全部怪兽的攻击力变成和装备怪兽相同。
-- ③：1回合1次，装备怪兽进行战斗的攻击宣言时，以对方墓地1只怪兽为对象才能发动。那只怪兽除外。装备怪兽的攻击力直到回合结束时上升除外的怪兽的攻击力数值。
local s,id,o=GetID()
-- 初始化「刻魂之右」的效果：记录「红莲魔龙」卡名记述，并注册发动装备、装备对象限制及①②③三个效果。
function s.initial_effect(c)
	-- 记录这张卡的效果文本上记载了「红莲魔龙」(70902743)的卡名。
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
-- 定义装备对象限制函数：限定这张卡只能装备在自己控制下的龙族同调怪兽身上。
function s.eqlimit(e,c)
	return c:IsControler(e:GetHandlerPlayer()) and c:IsType(TYPE_SYNCHRO)
		and c:IsRace(RACE_DRAGON)
end
-- 定义装备目标过滤函数：检查怪兽是否由发动玩家控制且为龙族同调怪兽。
function s.eqfilter(c,tp)
	return c:IsControler(tp) and c:IsType(TYPE_SYNCHRO)
		and c:IsRace(RACE_DRAGON)
end
-- 发动对象检查与选择函数：验证自己怪兽区存在合法的龙族同调怪兽，选择其中1只作为对象并登记装备操作信息。
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.eqfilter(chkc,tp) end
	-- 在检查能否发动时，确认自己怪兽区存在至少1只可成为效果对象的龙族同调怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 向玩家发送选择要装备对象的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从自己怪兽区选择1只满足条件的龙族同调怪兽作为发动对象。
	Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 向引擎登记本次连锁确定将这张卡自身装备给目标怪兽的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备发动处理函数：若这张卡与对象怪兽均与效果关联且对象表侧在场，则将这张卡装备给对象怪兽。
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的当前连锁的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张装备魔法卡装备给选中的对象怪兽。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- ①效果免疫判断函数：当对方发动效果且当前装备怪兽为「红莲魔龙」(70902743)时返回true，使其不受该效果影响。
function s.immval(e,re)
	local qc=e:GetHandler():GetEquipTarget()
	return re:IsActivated() and e:GetHandlerPlayer()~=re:GetOwnerPlayer() and qc and qc:IsCode(70902743)
end
-- 定义攻击力变化过滤函数：检查怪兽是否为表侧表示且当前攻击力不等于指定攻击力atk。
function s.atkfilter(c,atk)
	return c:IsFaceup() and c:GetAttack()~=atk
end
-- ②效果发动检查函数：确认存在装备怪兽且对方场上存在至少1只攻击力与装备怪兽不同的表侧表示怪兽。
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local qc=e:GetHandler():GetEquipTarget()
	-- 在检查能否发动时，确认装备怪兽存在且对方怪兽区存在至少1只攻击力不等于装备怪兽攻击力的表侧表示怪兽。
	if chk==0 then return qc and Duel.IsExistingMatchingCard(s.atkfilter,tp,0,LOCATION_MZONE,1,nil,qc:GetAttack()) end
end
-- ②效果处理函数：获取表侧在场的装备怪兽当前攻击力，并将对方场上所有攻击力与之不同的表侧表示怪兽攻击力变为该数值。
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local qc=e:GetHandler():GetEquipTarget()
	if qc and qc:IsType(TYPE_MONSTER) and qc:IsFaceup() then
		local atk=qc:GetAttack()
		-- 获取对方怪兽区所有攻击力与装备怪兽攻击力不同的表侧表示怪兽卡片组。
		local g=Duel.GetMatchingGroup(s.atkfilter,tp,0,LOCATION_MZONE,nil,atk)
		-- 遍历对方场上需要改变攻击力的每一只怪兽。
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
-- ③效果发动条件函数：判断当前攻击宣言中的攻击怪兽或被攻击怪兽是否为这张卡的装备怪兽。
function s.atkcon2(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetEquipTarget()
	-- 判断当前战斗的攻击怪兽或被攻击对象是否等于装备怪兽。
	return Duel.GetAttacker()==tc or Duel.GetAttackTarget()==tc
end
-- 定义③效果除外目标过滤函数：检查卡片是否为怪兽、可以被除外且当前攻击力不为0。
function s.rmfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove() and not c:IsAttack(0)
end
-- ③效果发动对象检查与选择函数：验证对方墓地存在可除外的非0攻怪兽，选择其中1只作为对象并登记除外操作信息。
function s.atktg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and s.rmfilter(chkc) end
	-- 在检查能否发动时，确认对方墓地存在至少1只满足条件且可成为效果对象的怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter,tp,0,LOCATION_GRAVE,1,nil) end
	-- 向玩家发送选择要除外的对方墓地怪兽提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从对方墓地选择1只满足条件的怪兽作为当前连锁的发动对象。
	local g=Duel.SelectTarget(tp,s.rmfilter,tp,0,LOCATION_GRAVE,1,1,nil)
	-- 向引擎登记本次连锁确定将对象怪兽从对方墓地除外（1张）的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,1-tp,LOCATION_GRAVE)
end
-- ③效果处理函数：将对象怪兽除外后，若装备怪兽表侧在场、这张卡仍与效果关联且除外怪兽攻击力大于0，则使装备怪兽攻击力直到回合结束上升该数值。
function s.atkop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的当前连锁的对方墓地对象怪兽。
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	local qc=c:GetEquipTarget()
	-- 若对象怪兽仍与效果关联，则将其以表侧表示除外并检查是否除外成功。
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
