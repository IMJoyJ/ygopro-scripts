--海造賊－象徴
-- 效果：
-- 「海造贼」怪兽才能装备。这个卡名的②的效果1回合只能使用1次。
-- ①：装备怪兽的攻击力上升500，不会成为对方的效果的对象。
-- ②：把装备的这张卡送去墓地才能发动。把持有和双方的场上·墓地的怪兽的其中任意种相同属性的1只「海造贼」怪兽从额外卡组特殊召唤。那之后，这张卡装备过的怪兽给那只特殊召唤的怪兽当作攻击力上升500的装备卡使用来装备。
function c80621422.initial_effect(c)
	-- 「海造贼」怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c80621422.target)
	e1:SetOperation(c80621422.operation)
	c:RegisterEffect(e1)
	-- 「海造贼」怪兽才能装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c80621422.eqlimit)
	c:RegisterEffect(e2)
	-- ①：装备怪兽的攻击力上升500
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(500)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	-- 设置装备怪兽不会成为对方的效果的对象
	e4:SetValue(aux.tgoval)
	c:RegisterEffect(e4)
	-- ②：把装备的这张卡送去墓地才能发动。把持有和双方的场上·墓地的怪兽的其中任意种相同属性的1只「海造贼」怪兽从额外卡组特殊召唤。那之后，这张卡装备过的怪兽给那只特殊召唤的怪兽当作攻击力上升500的装备卡使用来装备。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(80621422,1))
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCountLimit(1,80621422)
	e5:SetCost(c80621422.spcost)
	e5:SetTarget(c80621422.sptg)
	e5:SetOperation(c80621422.spop)
	c:RegisterEffect(e5)
end
-- 过滤场上表侧表示的「海造贼」怪兽的辅助函数
function c80621422.eqfilter1(c)
	return c:IsFaceup() and c:IsSetCard(0x13f)
end
-- 装备魔法卡发动时的效果目标选择与处理
function c80621422.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c80621422.eqfilter1(chkc) end
	-- 检查场上是否存在可以装备的「海造贼」怪兽
	if chk==0 then return Duel.IsExistingTarget(c80621422.eqfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择1只「海造贼」怪兽作为装备对象
	Duel.SelectTarget(tp,c80621422.eqfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁信息为装备这张卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法卡发动时的效果处理
function c80621422.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取装备的目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() and c:CheckUniqueOnField(tp) then
		-- 将这张卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
	end
end
-- 限制这张卡只能装备给「海造贼」怪兽
function c80621422.eqlimit(e,c)
	return c:IsSetCard(0x13f)
end
-- 效果②的发动代价处理函数
function c80621422.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	e:SetLabelObject(e:GetHandler():GetEquipTarget())
	-- 将装备的这张卡送去墓地作为发动代价
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤额外卡组中可以特殊召唤的、且属性与双方场上·墓地怪兽相同的「海造贼」怪兽
function c80621422.spfilter(c,e,tp)
	return c:IsSetCard(0x13f)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查额外卡组怪兽特殊召唤所需的怪兽区域空格
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
		-- 检查双方场上或墓地是否存在与该额外怪兽相同属性的怪兽
		and Duel.IsExistingMatchingCard(c80621422.mfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,nil,c:GetAttribute())
end
-- 过滤双方场上表侧表示或墓地中具有指定属性的怪兽
function c80621422.mfilter(c,attr)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsAttribute(attr)
end
-- 效果②的靶向与发动准备处理
function c80621422.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组是否存在可特殊召唤的「海造贼」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c80621422.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 将这张卡原本装备的怪兽设为效果处理的对象
	Duel.SetTargetCard(e:GetLabelObject())
	-- 设置连锁信息为从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果②的效果处理（特殊召唤并装备）
function c80621422.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家选择1只满足条件的额外卡组「海造贼」怪兽
	local tc=Duel.SelectMatchingCard(tp,c80621422.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	if not tc then return end
	-- 将选择的怪兽表侧表示特殊召唤，若特殊召唤失败则结束处理
	if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	local ec=e:GetLabelObject()
	if not ec:IsRelateToEffect(e) then return end
	-- 中断效果处理，使后续的装备处理不与特殊召唤同时进行
	Duel.BreakEffect()
	-- 将原本装备的怪兽作为装备卡装备给特殊召唤的怪兽
	if not Duel.Equip(tp,ec,tc,false) then return end
	-- 当作攻击力上升500的装备卡使用来装备
	local e1=Effect.CreateEffect(ec)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(500)
	ec:RegisterEffect(e1)
	-- 当作攻击力上升500的装备卡使用来装备
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	e2:SetLabelObject(tc)
	e2:SetValue(c80621422.eqlimit2)
	ec:RegisterEffect(e2)
end
-- 限制装备对象为特殊召唤出的那只怪兽
function c80621422.eqlimit2(e,c)
	return c==e:GetLabelObject()
end
