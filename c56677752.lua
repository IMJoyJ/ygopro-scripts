--EMオッドアイズ・バトラー
-- 效果：
-- ←2 【灵摆】 2→
-- ①：1回合1次，对方怪兽的攻击宣言时才能发动。从自己墓地选1只「异色眼」灵摆怪兽表侧表示加入额外卡组，那次攻击无效。那之后，可以让自己基本分回复那只灵摆怪兽的攻击力的数值。
-- 【怪兽效果】
-- 这个卡名的①的怪兽效果1回合只能使用1次。
-- ①：这张卡在手卡·墓地存在的场合，以「娱乐伙伴 异色眼管家」以外的自己场上1张「娱乐伙伴」怪兽卡或者「异色眼」怪兽卡为对象才能发动。这张卡特殊召唤。那之后，作为对象的卡破坏。
-- ②：怪兽区域的这张卡被破坏的场合才能发动。这张卡在自己的灵摆区域放置。
function c56677752.initial_effect(c)
	-- 启用灵摆怪兽属性（注册灵摆召唤和灵摆卡的发动效果）
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
	-- 这个卡名的①的怪兽效果1回合只能使用1次。①：这张卡在手卡·墓地存在的场合，以「娱乐伙伴 异色眼管家」以外的自己场上1张「娱乐伙伴」怪兽卡或者「异色眼」怪兽卡为对象才能发动。这张卡特殊召唤。那之后，作为对象的卡破坏。
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
-- 灵摆效果①的发动条件判定函数
function c56677752.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查攻击宣言的怪兽是否由对方玩家控制
	return Duel.GetAttacker():IsControler(1-tp)
end
-- 过滤自己墓地中可以加入额外卡组的「异色眼」灵摆怪兽
function c56677752.negfilter(c)
	return c:IsType(TYPE_PENDULUM) and c:IsSetCard(0x99) and c:IsAbleToExtra()
end
-- 灵摆效果①的发动准备与目标检查函数
function c56677752.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少1只满足条件的「异色眼」灵摆怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c56677752.negfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 设置连锁处理信息，表示有卡片将离开墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,LOCATION_GRAVE)
end
-- 灵摆效果①的效果处理函数
function c56677752.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入额外卡组的卡片
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(56677752,0))  --"请选择要加入额外卡组的卡"
	-- 让玩家从自己墓地选择1只满足条件的「异色眼」灵摆怪兽（受王家长眠之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c56677752.negfilter),tp,LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	-- 将选中的灵摆怪兽表侧表示送去额外卡组，若成功送去且攻击成功被无效
	if tc and Duel.SendtoExtraP(tc,nil,REASON_EFFECT) and tc:IsLocation(LOCATION_EXTRA) and Duel.NegateAttack()
		-- 检查该怪兽攻击力是否大于0，并询问玩家是否选择回复基本分
		and tc:GetAttack()>0 and Duel.SelectYesNo(tp,aux.Stringid(56677752,1)) then  --"是否回复基本分？"
		-- 中断当前效果处理，使后续的回复基本分处理不与前面的处理视为同时进行
		Duel.BreakEffect()
		-- 回复玩家等同于该灵摆怪兽攻击力数值的基本分
		Duel.Recover(tp,tc:GetAttack(),REASON_EFFECT)
	end
end
-- 过滤自己场上除「娱乐伙伴 异色眼管家」以外的表侧表示「娱乐伙伴」或「异色眼」怪兽卡
function c56677752.spfilter(c)
	return c:IsSetCard(0x9f,0x99) and not c:IsCode(56677752) and c:IsFaceup() and c:GetOriginalType()&TYPE_MONSTER~=0
end
-- 怪兽效果①的发动准备与对象选择函数
function c56677752.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c56677752.spfilter(chkc) end
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查自己场上是否存在可以作为对象的「娱乐伙伴」或「异色眼」怪兽卡
		and Duel.IsExistingTarget(c56677752.spfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上1张满足条件的卡作为效果对象
	local g=Duel.SelectTarget(tp,c56677752.spfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 设置连锁处理信息，表示将特殊召唤这张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 设置连锁处理信息，表示将破坏作为对象的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 怪兽效果①的效果处理函数
function c56677752.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否仍有可用的怪兽区域，若无则直接返回
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	-- 获取本次效果发动的对象卡片
	local tc=Duel.GetFirstTarget()
	-- 若此卡仍与效果相关且成功特殊召唤，且对象卡片仍与效果相关
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 and tc:IsRelateToEffect(e) then
		-- 中断当前效果处理，使后续的破坏处理不与特殊召唤视为同时进行
		Duel.BreakEffect()
		-- 破坏作为对象的卡片
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 怪兽效果②的发动条件判定函数
function c56677752.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
-- 怪兽效果②的发动准备与目标检查函数
function c56677752.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的灵摆区域是否有空位
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
-- 怪兽效果②的效果处理函数
function c56677752.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡在自己的灵摆区域表侧表示放置
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
