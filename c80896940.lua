--涅槃の超魔導剣士
-- 效果：
-- ←8 【灵摆】 8→
-- ①：自己的灵摆怪兽攻击的场合，那只怪兽不会被那次战斗破坏，那次战斗发生的对自己的战斗伤害变成0。
-- ②：自己的灵摆怪兽攻击的伤害步骤结束时发动。对方场上的全部怪兽的攻击力直到回合结束时下降攻击的那只怪兽的攻击力数值。
-- 【怪兽效果】
-- 调整＋调整以外的同调怪兽1只以上
-- 这张卡同调召唤的场合，可以用自己场上1只灵摆召唤的灵摆怪兽当作调整使用。
-- ①：这张卡用灵摆召唤的灵摆怪兽为调整作同调召唤成功的场合，以自己墓地1张卡为对象才能发动。那张卡加入手卡。
-- ②：这张卡战斗破坏对方怪兽时才能发动。对方基本分变成一半。
-- ③：怪兽区域的这张卡被战斗·效果破坏的场合才能发动。这张卡在自己的灵摆区域放置。
function c80896940.initial_effect(c)
	c:EnableReviveLimit()
	-- 注册灵摆怪兽属性（不注册灵摆卡卡的发动效果）
	aux.EnablePendulumAttribute(c,false)
	-- 注册同调召唤手续（可以使用自己场上1只灵摆召唤的灵摆怪兽当作调整使用）
	aux.AddSynchroMixProcedure(c,c80896940.matfilter1,nil,nil,aux.NonTuner(Card.IsType,TYPE_SYNCHRO),1,99)
	-- ①：自己的灵摆怪兽攻击的场合，那只怪兽不会被那次战斗破坏，那次战斗发生的对自己的战斗伤害变成0。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCondition(c80896940.indcon)
	e3:SetOperation(c80896940.indop)
	c:RegisterEffect(e3)
	-- ②：自己的灵摆怪兽攻击的伤害步骤结束时发动。对方场上的全部怪兽的攻击力直到回合结束时下降攻击的那只怪兽的攻击力数值。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(80896940,2))  --"攻击力下降"
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_DAMAGE_STEP_END)
	e4:SetRange(LOCATION_PZONE)
	e4:SetCondition(c80896940.atkcon)
	e4:SetOperation(c80896940.atkop)
	c:RegisterEffect(e4)
	-- ①：这张卡用灵摆召唤的灵摆怪兽为调整作同调召唤成功的场合，以自己墓地1张卡为对象才能发动。那张卡加入手卡。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(80896940,3))  --"加入手卡"
	e5:SetCategory(CATEGORY_TOHAND)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e5:SetCondition(c80896940.thcon)
	e5:SetTarget(c80896940.thtg)
	e5:SetOperation(c80896940.thop)
	c:RegisterEffect(e5)
	-- 这张卡用灵摆召唤的灵摆怪兽为调整作同调召唤成功的场合
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(c80896940.valcheck)
	e0:SetLabelObject(e5)
	c:RegisterEffect(e0)
	-- ②：这张卡战斗破坏对方怪兽时才能发动。对方基本分变成一半。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(80896940,4))  --"基本分变成一半"
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_BATTLE_DESTROYING)
	-- 设置效果发动条件为这张卡战斗破坏对方怪兽时
	e6:SetCondition(aux.bdocon)
	e6:SetOperation(c80896940.lpop)
	c:RegisterEffect(e6)
	-- ③：怪兽区域的这张卡被战斗·效果破坏的场合才能发动。这张卡在自己的灵摆区域放置。
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(80896940,5))  --"这张卡在灵摆区域放置"
	e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e7:SetCode(EVENT_DESTROYED)
	e7:SetProperty(EFFECT_FLAG_DELAY)
	e7:SetCondition(c80896940.pencon)
	e7:SetTarget(c80896940.pentg)
	e7:SetOperation(c80896940.penop)
	c:RegisterEffect(e7)
end
c80896940.material_type=TYPE_SYNCHRO
-- 过滤作为同调素材的调整怪兽（可以是调整，或者是自己场上灵摆召唤的灵摆怪兽）
function c80896940.matfilter1(c,syncard)
	return c:IsTuner(syncard) or (c:IsType(TYPE_PENDULUM) and c:IsSummonType(SUMMON_TYPE_PENDULUM))
end
-- 灵摆效果①的发动条件：自己的灵摆怪兽进行攻击宣言时
function c80896940.indcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前进行攻击宣言的怪兽
	local a=Duel.GetAttacker()
	return a:IsType(TYPE_PENDULUM) and a:IsControler(tp)
end
-- 灵摆效果①的效果处理：使进行攻击的怪兽不会被那次战斗破坏，且那次战斗发生的对自己的战斗伤害变成0
function c80896940.indop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前进行攻击的怪兽
	local tc=Duel.GetAttacker()
	-- 那只怪兽不会被那次战斗破坏
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
	tc:RegisterEffect(e1)
	-- 那次战斗发生的对自己的战斗伤害变成0
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e2:SetValue(1)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
	tc:RegisterEffect(e2)
end
-- 灵摆效果②的发动条件：自己的灵摆怪兽攻击的伤害步骤结束时
function c80896940.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取进行攻击的怪兽
	local a=Duel.GetAttacker()
	return a and a:IsRelateToBattle() and a:IsType(TYPE_PENDULUM) and a:IsControler(tp)
end
-- 灵摆效果②的效果处理：对方场上的全部怪兽的攻击力直到回合结束时下降攻击的那只怪兽的攻击力数值
function c80896940.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方场上所有表侧表示的怪兽
	local tg=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local tc=tg:GetFirst()
	while tc do
		-- 获取攻击怪兽的当前攻击力数值
		local atk=Duel.GetAttacker():GetAttack()
		-- 对方场上的全部怪兽的攻击力直到回合结束时下降攻击的那只怪兽的攻击力数值
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=tg:GetNext()
	end
end
-- 怪兽效果①的发动条件：这张卡用灵摆召唤的灵摆怪兽为调整作同调召唤成功时
function c80896940.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO) and e:GetLabel()==1
end
-- 怪兽效果①的靶向/目标选择：以自己墓地1张卡为对象
function c80896940.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and chkc:IsAbleToHand() end
	-- 检查自己墓地是否存在可以加入手牌的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1张可以加入手牌的卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息为将选中的卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 怪兽效果①的效果处理：将作为对象的卡加入手牌
function c80896940.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片因效果加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 过滤出作为同调素材的、且是灵摆召唤的灵摆怪兽
function c80896940.mfilter(c)
	return c:IsType(TYPE_PENDULUM) and c:IsSummonType(SUMMON_TYPE_PENDULUM)
end
-- 检查同调素材，判断是否使用了灵摆召唤的灵摆怪兽作为调整进行同调召唤
function c80896940.valcheck(e,c)
	local g=c:GetMaterial()
	local tg=g:Filter(c80896940.mfilter,nil)
	-- 遍历所有是灵摆召唤的灵摆怪兽的同调素材
	for tc in aux.Next(tg) do
		g:RemoveCard(tc)
		-- 检查除去当前假设作为调整的灵摆怪兽后，其余素材是否全部为非调整的同调怪兽
		local flag=g:FilterCount(aux.NonTuner(Card.IsType,TYPE_SYNCHRO),nil,c)==g:GetCount()
		g:AddCard(tc)
		if flag then
			e:GetLabelObject():SetLabel(1)
			return
		end
	end
	e:GetLabelObject():SetLabel(0)
end
-- 怪兽效果②的效果处理：使对方基本分变成一半
function c80896940.lpop(e,tp,eg,ep,ev,re,r,rp)
	-- 将对方玩家的生命值（LP）设为当前值的一半（向上取整）
	Duel.SetLP(1-tp,math.ceil(Duel.GetLP(1-tp)/2))
end
-- 怪兽效果③的发动条件：怪兽区域的这张卡被战斗·效果破坏的场合
function c80896940.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0 and c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
-- 怪兽效果③的靶向/目标选择：检查自己的灵摆区域是否有空位
function c80896940.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己左侧或右侧的灵摆区域是否可用
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
-- 怪兽效果③的效果处理：将这张卡在自己的灵摆区域放置
function c80896940.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示移动到自己的灵摆区域
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
