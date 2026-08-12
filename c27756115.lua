--超重武者装留マカルガエシ
-- 效果：
-- ①：自己主要阶段以自己场上1只「超重武者」怪兽为对象才能发动。从自己的手卡·场上把这只怪兽当作装备卡使用给那只自己怪兽装备。
-- ②：用这张卡的效果把这张卡装备的怪兽1回合只有1次不会被效果破坏。
-- ③：守备表示怪兽被战斗破坏送去自己墓地时，把这张卡从手卡送去墓地才能发动。那怪兽攻击表示特殊召唤。
function c27756115.initial_effect(c)
	-- ①：自己主要阶段以自己场上1只「超重武者」怪兽为对象才能发动。从自己的手卡·场上把这只怪兽当作装备卡使用给那只自己怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27756115,0))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetTarget(c27756115.eqtg)
	e1:SetOperation(c27756115.eqop)
	c:RegisterEffect(e1)
	-- ③：守备表示怪兽被战斗破坏送去自己墓地时，把这张卡从手卡送去墓地才能发动。那怪兽攻击表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(27756115,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetRange(LOCATION_HAND)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCost(c27756115.spcost)
	e2:SetTarget(c27756115.sptg)
	e2:SetOperation(c27756115.spop)
	c:RegisterEffect(e2)
end
-- 筛选场上正面表示的「超重武者」怪兽
function c27756115.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x9a)
end
-- 效果处理时判断是否满足条件，即是否能选择场上正面表示的「超重武者」怪兽作为对象
function c27756115.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c27756115.filter(chkc) end
	-- 判断自己魔法陷阱区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判断自己场上是否存在正面表示的「超重武者」怪兽
		and Duel.IsExistingTarget(c27756115.filter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上正面表示的「超重武者」怪兽作为对象
	Duel.SelectTarget(tp,c27756115.filter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
end
-- 将装备卡装备给对象怪兽，并设置装备限制和不被效果破坏的效果
function c27756115.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if c:IsLocation(LOCATION_MZONE) and c:IsFacedown() then return end
	-- 获取当前连锁效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断装备条件是否满足，包括魔法陷阱区域是否为空、对象怪兽是否为己方、是否正面表示、是否与效果相关
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsControler(1-tp) or tc:IsFacedown() or not tc:IsRelateToEffect(e) then
		-- 若条件不满足则将装备卡送入墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 将装备卡装备给对象怪兽
	Duel.Equip(tp,c,tc)
	-- ②：用这张卡的效果把这张卡装备的怪兽1回合只有1次不会被效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c27756115.eqlimit)
	c:RegisterEffect(e1)
	-- ②：用这张卡的效果把这张卡装备的怪兽1回合只有1次不会被效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2:SetCountLimit(1)
	e2:SetValue(c27756115.valcon)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
end
-- 装备对象必须为「超重武者」怪兽
function c27756115.eqlimit(e,c)
	return c:IsSetCard(0x9a)
end
-- 只有因效果破坏才计入不被破坏次数
function c27756115.valcon(e,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0
end
-- 支付将此卡送入墓地作为cost
function c27756115.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将此卡送入墓地作为cost
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 筛选被战斗破坏并送去墓地的守备表示怪兽
function c27756115.cfilter(c,e,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_BATTLE)
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_DEFENSE)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- 效果处理时判断是否满足条件，即是否能选择符合条件的怪兽进行特殊召唤
function c27756115.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and eg:IsExists(c27756115.cfilter,1,nil,e,tp) end
	local g=eg:Filter(c27756115.cfilter,nil,e,tp)
	-- 设置特殊召唤的目标怪兽
	Duel.SetTargetCard(g)
	-- 设置特殊召唤操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 将符合条件的怪兽攻击表示特殊召唤
function c27756115.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标怪兽并筛选与效果相关的怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 将目标怪兽攻击表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_ATTACK)
	end
end
