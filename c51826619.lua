--磁石の戦士Σ＋
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：只要自己场上有地属性怪兽存在，可以攻击的对方怪兽必须向地属性怪兽作出攻击。
-- ②：只要对方场上有地属性怪兽存在，对方选择自身怪兽的攻击对象之际，那个攻击对象由自己选择。
-- ③：这张卡被送去墓地的场合，以除「磁石战士Σ+」外的自己墓地1只4星以下的「磁石战士」怪兽为对象才能发动。那只怪兽加入手卡或特殊召唤。
local s,id,o=GetID()
-- 创建并注册3个字段效果，分别对应①②③效果的触发条件和处理
function s.initial_effect(c)
	-- 只要自己场上有地属性怪兽存在，可以攻击的对方怪兽必须向地属性怪兽作出攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_MUST_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetCondition(s.atkcon)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_MUST_ATTACK_MONSTER)
	e2:SetValue(s.atklimit)
	c:RegisterEffect(e2)
	-- 只要对方场上有地属性怪兽存在，对方选择自身怪兽的攻击对象之际，那个攻击对象由自己选择。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_PATRICIAN_OF_DARKNESS)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCondition(s.podcond)
	e3:SetTargetRange(0,1)
	c:RegisterEffect(e3)
	-- 这张卡被送去墓地的场合，以除「磁石战士Σ+」外的自己墓地1只4星以下的「磁石战士」怪兽为对象才能发动。那只怪兽加入手卡或特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"回收效果"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_GRAVE_SPSUMMON+CATEGORY_GRAVE_ACTION)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCountLimit(1,id)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
-- 用于判断是否满足地属性怪兽存在的条件
function s.atkfilter(c)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsFaceup()
end
-- 判断己方场上是否存在地属性怪兽
function s.atkcon(e)
	-- 判断己方场上是否存在地属性怪兽
	return Duel.IsExistingMatchingCard(s.atkfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 用于限制攻击对象为地属性怪兽
function s.atklimit(e,c)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsFaceup()
end
-- 用于判断是否满足对方场上有地属性怪兽的条件
function s.podfilter(c)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsFaceup()
end
-- 判断对方场上是否存在地属性怪兽
function s.podcond(e)
	local tp=e:GetOwnerPlayer()
	-- 判断对方场上是否存在地属性怪兽
	return Duel.IsExistingMatchingCard(s.podfilter,tp,0,LOCATION_MZONE,1,nil)
end
-- 过滤墓地中符合条件的「磁石战士」怪兽
function s.filter(c,e,tp)
	return not c:IsCode(id) and c:IsLevelBelow(4) and c:IsSetCard(0x2066)
		-- 判断该怪兽是否能被特殊召唤或加入手牌
		and (c:IsAbleToHand() or Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- 设置效果的目标选择函数，用于选择墓地中的目标怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc,e,tp) end
	-- 检查是否有满足条件的墓地怪兽可作为效果对象
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 从己方墓地中选择符合条件的1只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
end
-- 处理效果发动后的操作，包括判断是否能发动王家长眠之谷无效检查、选择特殊召唤或加入手牌
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		-- 检查目标怪兽是否受到王家长眠之谷保护，若受保护则无效该效果
		if aux.NecroValleyNegateCheck(tc) then return end
		-- 再次确认目标怪兽不受王家长眠之谷影响
		if not aux.NecroValleyFilter()(tc) then return end
		-- 判断是否有足够的场上空间进行特殊召唤
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 根据玩家选择决定是特殊召唤还是加入手牌
			and (not tc:IsAbleToHand() or Duel.SelectOption(tp,1190,1152)==1) then
			-- 将目标怪兽特殊召唤到场上
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		elseif tc:IsAbleToHand() then
			-- 将目标怪兽加入手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	end
end
