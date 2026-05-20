--鉄球魔神ゴロゴーン
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：怪兽进行战斗的伤害步骤结束时才能发动。这张卡从手卡特殊召唤。
-- ②：从手卡以及自己场上盖放的卡之中把1张陷阱卡送去墓地才能发动。和这张卡相同纵列的其他怪兽全部破坏。
-- ③：怪兽区域的这张卡被战斗·效果破坏送去墓地的场合，以自己墓地1张卡为对象才能发动。掷1次骰子。6出现的场合，作为对象的卡加入手卡。
function c84813516.initial_effect(c)
	-- ①：怪兽进行战斗的伤害步骤结束时才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(84813516,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_DAMAGE_STEP_END)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,84813516)
	e1:SetTarget(c84813516.sptg)
	e1:SetOperation(c84813516.spop)
	c:RegisterEffect(e1)
	-- ②：从手卡以及自己场上盖放的卡之中把1张陷阱卡送去墓地才能发动。和这张卡相同纵列的其他怪兽全部破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(84813516,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,84813517)
	e2:SetCost(c84813516.descost)
	e2:SetTarget(c84813516.destg)
	e2:SetOperation(c84813516.desop)
	c:RegisterEffect(e2)
	-- ③：怪兽区域的这张卡被战斗·效果破坏送去墓地的场合，以自己墓地1张卡为对象才能发动。掷1次骰子。6出现的场合，作为对象的卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(84813516,2))
	e3:SetCategory(CATEGORY_DICE+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,84813518)
	e3:SetCondition(c84813516.thcon)
	e3:SetTarget(c84813516.thtg)
	e3:SetOperation(c84813516.thop)
	c:RegisterEffect(e3)
end
-- ①号效果（手卡特殊召唤）的发动准备与合法性检测函数
function c84813516.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域，以及这张卡是否能特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁信息，表示该效果包含特殊召唤自身的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①号效果（手卡特殊召唤）的效果处理函数
function c84813516.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己的怪兽区域
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤手卡或场上盖放的、可以作为发动代价送去墓地的陷阱卡
function c84813516.costfilter(c)
	return (c:IsLocation(LOCATION_HAND) or c:IsFacedown()) and c:IsType(TYPE_TRAP) and c:IsAbleToGraveAsCost()
end
-- ②号效果（纵列破坏）的发动代价（Cost）处理函数
function c84813516.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡或场上是否存在至少1张满足条件的陷阱卡作为发动代价
	if chk==0 then return Duel.IsExistingMatchingCard(c84813516.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从手卡或场上选择1张满足条件的陷阱卡
	local g=Duel.SelectMatchingCard(tp,c84813516.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)
	-- 将选择的卡作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤属于相同纵列的卡片的过滤函数
function c84813516.desfilter(c,g)
	return g:IsContains(c)
end
-- ②号效果（纵列破坏）的发动准备与合法性检测函数
function c84813516.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local cg=c:GetColumnGroup()
	-- 检查与这张卡相同纵列的其他怪兽区域是否存在至少1只怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c84813516.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c,cg) end
	-- 获取与这张卡相同纵列的其他怪兽的卡片组
	local g=Duel.GetMatchingGroup(c84813516.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,c,cg)
	-- 设置连锁信息，表示该效果包含破坏这些怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- ②号效果（纵列破坏）的效果处理函数
function c84813516.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cg=c:GetColumnGroup()
	if c:IsRelateToEffect(e) then
		-- 重新获取当前与这张卡相同纵列的其他怪兽的卡片组
		local g=Duel.GetMatchingGroup(c84813516.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,c,cg)
		if g:GetCount()>0 then
			-- 因效果破坏这些相同纵列的怪兽
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
-- ③号效果（被破坏送墓掷骰回收）的发动条件检测函数：必须在怪兽区域被战斗或效果破坏并送去墓地
function c84813516.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- ③号效果（被破坏送墓掷骰回收）的发动准备与合法性检测函数
function c84813516.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and chkc:IsAbleToHand() end
	-- 检查自己墓地是否存在至少1张可以加入手卡的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己墓地的1张卡作为效果的对象
	Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁信息，表示该效果包含掷1次骰子的操作
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
-- ③号效果（被破坏送墓掷骰回收）的效果处理函数
function c84813516.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 让玩家掷1次骰子
		local d=Duel.TossDice(tp,1)
		if d==6 then
			-- 将作为对象的卡加入持有者的手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	end
end
