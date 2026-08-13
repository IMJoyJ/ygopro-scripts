--EMオッドアイズ・バトラー
-- 效果：
-- ←2 【灵摆】 2→
-- ①：1回合1次，对方怪兽的攻击宣言时才能发动。从自己墓地选1只「异色眼」灵摆怪兽表侧表示加入额外卡组，那次攻击无效。那之后，可以让自己基本分回复那只灵摆怪兽的攻击力的数值。
-- 【怪兽效果】
-- 这个卡名的①的怪兽效果1回合只能使用1次。
-- ①：这张卡在手卡·墓地存在的场合，以「娱乐伙伴 异色眼管家」以外的自己场上1张「娱乐伙伴」怪兽卡或者「异色眼」怪兽卡为对象才能发动。这张卡特殊召唤。那之后，作为对象的卡破坏。
-- ②：怪兽区域的这张卡被破坏的场合才能发动。这张卡在自己的灵摆区域放置。
function c56677752.initial_effect(c)
	-- 为这张卡添加灵摆怪兽属性，使其可以进行灵摆召唤以及作为灵摆卡发动
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，对方怪兽的攻击宣言时才能发动。从自己墓地选1只「异色眼」灵摆怪兽表侧表示加入额外卡组，那次攻击无效。那之后，可以让自己基本分回复那只灵摆怪兽的攻击力的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOEXTRA+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c56677752.negcon)
	e1:SetTarget(c56677752.negtg)
	e1:SetOperation(c56677752.negop)
	c:RegisterEffect(e1)
	-- ①：这张卡在手卡·墓地存在的场合，以「娱乐伙伴 异色眼管家」以外的自己场上1张「娱乐伙伴」怪兽卡或者「异色眼」怪兽卡为对象才能发动。这张卡特殊召唤。那之后，作为对象的卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(56677752,2))  --"特殊召唤并破坏"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,56677752)
	e2:SetTarget(c56677752.sptg)
	e2:SetOperation(c56677752.spop)
	c:RegisterEffect(e2)
	-- ②：怪兽区域的这张卡被破坏的场合才能发动。这张卡在自己的灵摆区域放置。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(c56677752.pencon)
	e3:SetTarget(c56677752.pentg)
	e3:SetOperation(c56677752.penop)
	c:RegisterEffect(e3)
end
-- 灵摆效果的发动条件：本次攻击宣言的攻击怪兽由对方控制
function c56677752.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断此次攻击的攻击怪兽是否为对方控制，即对方怪兽的攻击宣言时
	return Duel.GetAttacker():IsControler(1-tp)
end
-- 过滤条件：灵摆怪兽且属于「异色眼」系列（0x99）并且可以表侧表示加入额外卡组
function c56677752.negfilter(c)
	return c:IsType(TYPE_PENDULUM) and c:IsSetCard(0x99) and c:IsAbleToExtra()
end
-- 灵摆效果的对象确认：检查自己墓地是否存在可作为对象的「异色眼」灵摆怪兽，并设置离开墓地的操作信息
function c56677752.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：自己墓地存在至少1只满足条件的「异色眼」灵摆怪兽才能发动
	if chk==0 then return Duel.IsExistingMatchingCard(c56677752.negfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息：本连锁将把1张自己墓地的卡从墓地离开（送去额外卡组）
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,LOCATION_GRAVE)
end
-- 灵摆效果处理：从自己墓地选1只「异色眼」灵摆怪兽表侧表示加入额外卡组，那次攻击无效，之后可以回复那只怪兽攻击力数值的基本分
function c56677752.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入额外卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(56677752,0))  --"请选择要加入额外卡组的卡"
	-- 让玩家从自己墓地选择1只满足条件且不受「王家长眠之谷」影响的「异色眼」灵摆怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c56677752.negfilter),tp,LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	-- 把选择的灵摆怪兽表侧表示送去额外卡组，成功且在额外卡组存在时，将那次攻击无效
	if tc and Duel.SendtoExtraP(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_EXTRA) and Duel.NegateAttack()
		-- 若那只灵摆怪兽攻击力大于0，询问玩家是否回复基本分
		and tc:GetAttack()>0 and Duel.SelectYesNo(tp,aux.Stringid(56677752,1)) then  --"是否回复基本分？"
		-- 中断当前效果处理，使之后的回复与前述处理视为不同时处理
		Duel.BreakEffect()
		-- 让自己基本分回复那只灵摆怪兽的攻击力数值
		Duel.Recover(tp,tc:GetAttack(),REASON_EFFECT)
	end
end
-- 过滤条件：表侧表示的原本种类为怪兽的「娱乐伙伴」（0x9f）或「异色眼」（0x99）卡，且不是「娱乐伙伴 异色眼管家」本身
function c56677752.spfilter(c)
	return c:IsSetCard(0x9f,0x99) and not c:IsCode(56677752) and c:IsFaceup() and c:GetOriginalType()&TYPE_MONSTER~=0
end
-- 怪兽效果的对象确认：自己怪兽区域有空格、这张卡可以特殊召唤、且自己场上存在可选取为对象的「娱乐伙伴」或「异色眼」怪兽卡
function c56677752.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c56677752.spfilter(chkc) end
	-- 发动条件检查：自己主要怪兽区域存在可用空格，且这张卡可以特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 发动条件检查：自己场上存在1张可作为对象的满足条件的「娱乐伙伴」或「异色眼」怪兽卡
		and Duel.IsExistingTarget(c56677752.spfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择自己场上1张满足条件的卡作为效果对象
	local g=Duel.SelectTarget(tp,c56677752.spfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 设置操作信息：本连锁将特殊召唤这张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 设置操作信息：本连锁将破坏作为对象的那1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 怪兽效果处理：确认有空格后把这张卡特殊召唤，成功之后将作为对象的卡破坏
function c56677752.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 自己主要怪兽区域没有可用空格时，效果处理直接结束
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	-- 取得当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	-- 若这张卡仍与效果关联，则将这张卡以表侧表示特殊召唤，且对象卡仍与效果关联时继续处理
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 and tc:IsRelateToEffect(e) then
		-- 中断当前效果处理，使之后的破坏与特殊召唤视为不同时处理
		Duel.BreakEffect()
		-- 将作为对象的卡以效果破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 灵摆区域放置效果的发动条件：这张卡是从怪兽区域被破坏送去且为表侧表示
function c56677752.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
-- 放置效果的对象确认：自己的灵摆区域存在可用的空格
function c56677752.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：自己灵摆区域的左或右格子至少有1个可用
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
-- 灵摆区域放置效果的处理：这张卡仍与效果关联时，把它表侧表示放置到自己的灵摆区域
function c56677752.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 把这张卡表侧表示移动到自己的灵摆区域并立即适用其效果
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
