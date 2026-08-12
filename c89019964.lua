--破械神の禍霊
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：这张卡的攻击力上升自己墓地的「破械」卡数量×300。
-- ②：以对方场上1只表侧表示怪兽为对象才能发动。只用那只对方怪兽和自己场上的这张卡为素材把1只暗属性连接怪兽连接召唤。
-- ③：场上的这张卡被战斗·效果破坏的场合，以「破械神的祸灵」以外的自己墓地1只「破械」怪兽为对象才能发动。那只怪兽特殊召唤。
function c89019964.initial_effect(c)
	-- ①：这张卡的攻击力上升自己墓地的「破械」卡数量×300。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c89019964.atkval)
	c:RegisterEffect(e1)
	-- ②：以对方场上1只表侧表示怪兽为对象才能发动。只用那只对方怪兽和自己场上的这张卡为素材把1只暗属性连接怪兽连接召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(89019964,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,89019964)
	e2:SetTarget(c89019964.target)
	e2:SetOperation(c89019964.operation)
	c:RegisterEffect(e2)
	-- ③：场上的这张卡被战斗·效果破坏的场合，以「破械神的祸灵」以外的自己墓地1只「破械」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(89019964,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,89019965)
	e3:SetCondition(c89019964.spcon)
	e3:SetTarget(c89019964.sptg)
	e3:SetOperation(c89019964.spop)
	c:RegisterEffect(e3)
end
-- 计算攻击力上升数值的函数
function c89019964.atkval(e,c)
	-- 返回自己墓地的「破械」卡数量×300的数值
	return Duel.GetMatchingGroupCount(Card.IsSetCard,c:GetControler(),LOCATION_GRAVE,0,nil,0x130)*300
end
-- 过滤对方场上可作为连接素材的表侧表示怪兽的条件函数
function c89019964.tgfilter(c,tp,ec)
	local mg=Group.FromCards(ec,c)
	-- 过滤条件：卡片表侧表示，且额外卡组存在以该卡和自身为素材可以连接召唤的暗属性连接怪兽
	return c:IsFaceup() and Duel.IsExistingMatchingCard(c89019964.lfilter,tp,LOCATION_EXTRA,0,1,nil,mg)
end
-- 过滤额外卡组中可连接召唤的暗属性连接怪兽的条件函数
function c89019964.lfilter(c,mg)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsLinkSummonable(mg,nil,2,2)
end
-- 效果②（连接召唤）的发动准备与目标选择函数
function c89019964.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return false end
	-- 步骤chk==0：检查对方场上是否存在满足条件的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c89019964.tgfilter,tp,0,LOCATION_MZONE,1,nil,tp,e:GetHandler()) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上1只表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,c89019964.tgfilter,tp,0,LOCATION_MZONE,1,1,nil,tp,e:GetHandler())
	-- 设置效果处理信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果②（连接召唤）的效果处理函数
function c89019964.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的对方怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsFaceup() and c:IsRelateToEffect(e) and c:IsControler(tp)
		and tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsControler(1-tp) and not tc:IsImmuneToEffect(e) then
		local mg=Group.FromCards(c,tc)
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 玩家从额外卡组选择1只满足连接召唤条件的暗属性连接怪兽
		local g=Duel.SelectMatchingCard(tp,c89019964.lfilter,tp,LOCATION_EXTRA,0,1,1,nil,mg)
		local lc=g:GetFirst()
		if lc then
			-- 使用选定的素材将该怪兽连接召唤
			Duel.LinkSummon(tp,lc,mg,nil,2,2)
		end
	end
end
-- 效果③（被破坏时特召墓地怪兽）的发动条件函数：场上的这张卡被战斗或效果破坏
function c89019964.spcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0 and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤墓地中可特殊召唤的「破械神的祸灵」以外的「破械」怪兽的条件函数
function c89019964.spfilter(c,e,tp)
	return c:IsSetCard(0x130) and not c:IsCode(89019964) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果③（被破坏时特召墓地怪兽）的发动准备与目标选择函数
function c89019964.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c89019964.spfilter(chkc,e,tp) end
	-- 步骤chk==0：检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且自己墓地中存在满足特殊召唤条件的「破械神的祸灵」以外的「破械」怪兽
		and Duel.IsExistingTarget(c89019964.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的「破械」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c89019964.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息：将选中的墓地怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果③（被破坏时特召墓地怪兽）的效果处理函数
function c89019964.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的墓地怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
