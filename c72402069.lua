--DDD超死偉王ホワイテスト・ヘル・アーマゲドン
-- 效果：
-- ←1 【灵摆】 1→
-- ①：1回合1次，对方怪兽的攻击宣言时以自己场上1只「DDD」同调怪兽为对象才能发动。持有那只怪兽的攻击力以下的守备力的对方场上的怪兽全部破坏，给与对方破坏的怪兽数量×1000伤害。
-- 【怪兽效果】
-- 「DD」调整＋调整以外的「DDD」怪兽1只以上
-- ①：只要这张卡在怪兽区域存在，对方不能把自己场上的怪兽作为效果的对象。
-- ②：这张卡已在怪兽区域存在的状态，这张卡以外的怪兽召唤·特殊召唤的场合才能发动。对方选自身场上1只灵摆怪兽。那只怪兽以外的对方场上的怪兽的效果无效化。
-- ③：怪兽区域的这张卡被破坏的场合才能发动。这张卡在自己的灵摆区域放置。
function c72402069.initial_effect(c)
	c:EnableReviveLimit()
	-- 注册灵摆怪兽属性（不注册灵摆卡卡的发动效果）
	aux.EnablePendulumAttribute(c,false)
	-- 注册同调召唤手续：「DD」调整＋调整以外的「DDD」怪兽1只以上
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0xaf),aux.NonTuner(Card.IsSetCard,0x10af),1)
	-- ①：1回合1次，对方怪兽的攻击宣言时以自己场上1只「DDD」同调怪兽为对象才能发动。持有那只怪兽的攻击力以下的守备力的对方场上的怪兽全部破坏，给与对方破坏的怪兽数量×1000伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(72402069,0))  --"破坏并伤害"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCondition(c72402069.descon)
	e1:SetTarget(c72402069.destg)
	e1:SetOperation(c72402069.desop)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在怪兽区域存在，对方不能把自己场上的怪兽作为效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 设置不能成为对方卡的效果的对象
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- ②：这张卡已在怪兽区域存在的状态，这张卡以外的怪兽召唤·特殊召唤的场合才能发动。对方选自身场上1只灵摆怪兽。那只怪兽以外的对方场上的怪兽的效果无效化。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(72402069,1))  --"效果无效"
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(c72402069.distg)
	e3:SetOperation(c72402069.disop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
	-- ③：怪兽区域的这张卡被破坏的场合才能发动。这张卡在自己的灵摆区域放置。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(72402069,3))  --"这张卡在自己的灵摆区域放置"
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_DESTROYED)
	e6:SetProperty(EFFECT_FLAG_DELAY)
	e6:SetCondition(c72402069.pencon)
	e6:SetTarget(c72402069.pentg)
	e6:SetOperation(c72402069.penop)
	c:RegisterEffect(e6)
end
-- 灵摆效果①的发动条件判定（对方怪兽攻击宣言时）
function c72402069.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定攻击怪兽的控制者是否为对方
	return Duel.GetAttacker():GetControler()~=tp
end
-- 过滤自己场上表侧表示的「DDD」同调怪兽，且对方场上存在守备力在其攻击力以下的怪兽
function c72402069.desfilter1(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsSetCard(0x10af)
		-- 检查对方场上是否存在守备力在选择怪兽攻击力以下的怪兽
		and Duel.IsExistingMatchingCard(c72402069.desfilter2,tp,0,LOCATION_MZONE,1,nil,c:GetAttack())
end
-- 过滤对方场上表侧表示且守备力在指定数值以下的怪兽
function c72402069.desfilter2(c,atk)
	return c:IsFaceup() and c:IsDefenseBelow(atk)
end
-- 灵摆效果①的发动目标选择与效果处理声明
function c72402069.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c72402069.desfilter1(chkc,tp) end
	-- 检查自己场上是否存在符合条件的「DDD」同调怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(c72402069.desfilter1,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的「DDD」同调怪兽作为对象
	local tc=Duel.SelectTarget(tp,c72402069.desfilter1,tp,LOCATION_MZONE,0,1,1,nil,tp):GetFirst()
	-- 获取对方场上所有守备力在对象怪兽攻击力以下的怪兽组
	local g=Duel.GetMatchingGroup(c72402069.desfilter2,tp,0,LOCATION_MZONE,nil,tc:GetAttack())
	-- 设置破坏操作信息，包含要破坏的怪兽组及数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 设置伤害操作信息，给与对方破坏数量×1000的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:GetCount()*1000)
end
-- 灵摆效果①的效果处理（破坏对方场上符合条件的怪兽并给与伤害）
function c72402069.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 重新获取对方场上守备力在对象怪兽当前攻击力以下的怪兽组
		local g=Duel.GetMatchingGroup(c72402069.desfilter2,tp,0,LOCATION_MZONE,nil,tc:GetAttack())
		if g:GetCount()==0 then return end
		-- 破坏符合条件的怪兽，并获取实际破坏的数量
		local oc=Duel.Destroy(g,REASON_EFFECT)
		-- 若有怪兽被破坏，则给与对方破坏数量×1000的伤害
		if oc>0 then Duel.Damage(1-tp,oc*1000,REASON_EFFECT) end
	end
end
-- 过滤对方场上表侧表示的灵摆怪兽
function c72402069.disfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM)
end
-- 怪兽效果②的发动目标检查
function c72402069.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not eg:IsContains(e:GetHandler())
		-- 检查对方场上是否存在表侧表示的灵摆怪兽
		and Duel.IsExistingMatchingCard(c72402069.disfilter,tp,0,LOCATION_MZONE,1,nil) end
end
-- 怪兽效果②的效果处理
function c72402069.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示对方玩家选择场上1只灵摆怪兽
	Duel.Hint(HINT_SELECTMSG,1-tp,aux.Stringid(72402069,2))  --"请选择场上1只灵摆怪兽"
	-- 由对方玩家选择自身场上1只表侧表示的灵摆怪兽
	local pc=Duel.SelectMatchingCard(1-tp,c72402069.disfilter,tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
	if not pc then return end
	-- 获取对方场上除被选择的灵摆怪兽以外的所有可无效化的怪兽
	local g=Duel.GetMatchingGroup(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,pc)
	local tc=g:GetFirst()
	while tc do
		-- 那只怪兽以外的对方场上的怪兽的效果无效化。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 那只怪兽以外的对方场上的怪兽的效果无效化。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
end
-- 怪兽效果③的发动条件判定（怪兽区域的这张卡被破坏）
function c72402069.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
-- 怪兽效果③的发动目标检查
function c72402069.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的左或右灵摆区域是否可用
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
-- 怪兽效果③的效果处理
function c72402069.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示移动到自己的灵摆区域
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
