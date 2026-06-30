--EMオッドアイズ・バトラー
-- 效果：
-- ←2 【灵摆】 2→
-- ①：1回合1次，对方怪兽的攻击宣言时才能发动。从自己墓地选1只「异色眼」灵摆怪兽表侧表示加入额外卡组，那次攻击无效。那之后，可以让自己基本分回复那只灵摆怪兽的攻击力的数值。
-- 【怪兽效果】
-- 这个卡名的①的怪兽效果1回合只能使用1次。
-- ①：这张卡在手卡·墓地存在的场合，以「娱乐伙伴 异色眼管家」以外的自己场上1张「娱乐伙伴」怪兽卡或者「异色眼」怪兽卡为对象才能发动。这张卡特殊召唤。那之后，作为对象的卡破坏。
-- ②：怪兽区域的这张卡被破坏的场合才能发动。这张卡在自己的灵摆区域放置。
function c56677752.initial_effect(c)
	-- 为灵摆怪兽添加灵摆怪兽属性
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
-- 攻击无效效果的发动条件
function c56677752.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 对方怪兽的攻击宣言时
	return Duel.GetAttacker():IsControler(1-tp)
end
-- 自己墓地「异色眼」灵摆怪兽的过滤条件
function c56677752.negfilter(c)
	return c:IsType(TYPE_PENDULUM) and c:IsSetCard(0x99) and c:IsAbleToExtra()
end
-- 攻击无效效果的靶向/基本发动条件检测与操作信息注册
function c56677752.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c56677752.negfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 设置“卡片离开墓地”的操作信息
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,LOCATION_GRAVE)
end
-- 攻击无效效果的执行函数
function c56677752.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入额外卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(56677752,0))  --"请选择要加入额外卡组的卡"
	-- 选择自己墓地1只「异色眼」灵摆怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c56677752.negfilter),tp,LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	-- 将选择的怪兽表侧表示送去额外卡组，并无效那次攻击
	if tc and Duel.SendtoExtraP(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_EXTRA) and Duel.NegateAttack()
		-- 可以选择是否回复该灵摆怪兽攻击力数值的基本分
		and tc:GetAttack()>0 and Duel.SelectYesNo(tp,aux.Stringid(56677752,1)) then  --"是否回复基本分？"
		-- 中断效果处理，使之后的效果不视为同时处理
		Duel.BreakEffect()
		-- 自己基本分回复那只灵摆怪兽的攻击力的数值
		Duel.Recover(tp,tc:GetAttack(),REASON_EFFECT)
	end
end
-- 「娱乐伙伴 异色眼管家」以外的自己场上「娱乐伙伴」怪兽卡或者「异色眼」怪兽卡的过滤条件
function c56677752.spfilter(c)
	return c:IsSetCard(0x9f,0x99) and not c:IsCode(56677752) and c:IsFaceup() and c:GetOriginalType()&TYPE_MONSTER~=0
end
-- 特殊召唤并破坏效果的靶向/基本发动条件检测与对象选择
function c56677752.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c56677752.spfilter(chkc) end
	-- 检查自己场上的空怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查自己场上是否存在可以作为对象的卡
		and Duel.IsExistingTarget(c56677752.spfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上的卡作为效果的对象
	local g=Duel.SelectTarget(tp,c56677752.spfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 设置“特殊召唤自身”的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 设置“破坏对象卡片”的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 特殊召唤并破坏效果的执行函数
function c56677752.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上的空怪兽区域，若无则无法特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	-- 获取作为效果对象的卡
	local tc=Duel.GetFirstTarget()
	-- 将自身特殊召唤，并判断对象卡是否仍在场上
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 and tc:IsRelateToEffect(e) then
		-- 中断效果处理，使之后的效果不视为同时处理
		Duel.BreakEffect()
		-- 将作为对象的卡破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 在灵摆区域放置效果的发动条件
function c56677752.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
-- 在灵摆区域放置效果的靶向/基本发动条件检测
function c56677752.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的灵摆区域是否有空位
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
-- 在灵摆区域放置效果的执行函数
function c56677752.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将自身在自己的灵摆区域放置
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
