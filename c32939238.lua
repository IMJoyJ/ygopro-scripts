--忍法装具 鉄土竜
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：装备怪兽的攻击力上升500，也当作「忍者」怪兽使用。
-- ②：从自己墓地把1只「忍者」怪兽除外，以场上1张卡为对象才能发动。那张卡破坏。
-- ③：这张卡从场上送去墓地的场合，以除外的1只自己的「忍者」怪兽为对象才能发动。那只怪兽加入手卡或里侧守备表示特殊召唤。
local s,id,o=GetID()
-- 初始化效果函数，创建并注册所有效果
function s.initial_effect(c)
	-- ①：装备怪兽的攻击力上升500，也当作「忍者」怪兽使用。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_EQUIP_LIMIT)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetValue(1)
	c:RegisterEffect(e0)
	-- ①：装备怪兽的攻击力上升500，也当作「忍者」怪兽使用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- ①：装备怪兽的攻击力上升500，也当作「忍者」怪兽使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(500)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_ADD_SETCODE)
	e3:SetValue(0x2b)
	c:RegisterEffect(e3)
	-- ②：从自己墓地把1只「忍者」怪兽除外，以场上1张卡为对象才能发动。那张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,id)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCost(s.descost)
	e4:SetTarget(s.destg)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)
	-- ③：这张卡从场上送去墓地的场合，以除外的1只自己的「忍者」怪兽为对象才能发动。那只怪兽加入手卡或里侧守备表示特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetCountLimit(1,id+o)
	e5:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e5:SetCondition(s.rtcon)
	e5:SetTarget(s.rttg)
	e5:SetOperation(s.rtop)
	c:RegisterEffect(e5)
end
-- 设置装备目标选择函数，用于选择场上正面表示的怪兽作为装备对象
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查是否满足装备目标选择条件
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上正面表示的怪兽作为装备对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置装备操作信息
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备操作函数，将装备卡装备给目标怪兽
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的装备目标
	local tc=Duel.GetFirstTarget()
	-- 判断装备卡和目标怪兽是否仍然有效，若有效则执行装备
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then Duel.Equip(tp,c,tc) end
end
-- 除外卡过滤函数，用于判断是否为可除外的「忍者」怪兽
function s.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x2b) and c:IsAbleToRemoveAsCost()
end
-- ②：从自己墓地把1只「忍者」怪兽除外，以场上1张卡为对象才能发动。那张卡破坏。
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足除外卡的条件
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择1只可除外的「忍者」怪兽
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的卡从墓地除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ②：从自己墓地把1只「忍者」怪兽除外，以场上1张卡为对象才能发动。那张卡破坏。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 检查是否满足破坏目标选择条件
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上的一张卡作为破坏对象
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置破坏操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏操作函数，将目标卡破坏
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的破坏目标
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡是否仍然有效，若有效则执行破坏
	if tc:IsRelateToEffect(e) then Duel.Destroy(tc,REASON_EFFECT) end
end
-- 效果处理中用于判断是否可以特殊召唤或加入手牌的过滤函数
function s.filter(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsSetCard(0x2b)
		and (c:IsAbleToHand()
			-- 判断目标卡是否可以特殊召唤
			or Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE))
end
-- ③：这张卡从场上送去墓地的场合，以除外的1只自己的「忍者」怪兽为对象才能发动。那只怪兽加入手卡或里侧守备表示特殊召唤。
function s.rtcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- ③：这张卡从场上送去墓地的场合，以除外的1只自己的「忍者」怪兽为对象才能发动。那只怪兽加入手卡或里侧守备表示特殊召唤。
function s.rttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.filter(chkc,e,tp) end
	-- 检查是否满足特殊召唤/加入手牌目标选择条件
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 提示玩家选择要操作的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 选择1只可操作的除外的「忍者」怪兽
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
end
-- ③：这张卡从场上送去墓地的场合，以除外的1只自己的「忍者」怪兽为对象才能发动。那只怪兽加入手卡或里侧守备表示特殊召唤。
function s.rtop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的特殊召唤/加入手牌目标
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 判断目标卡是否可以特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 判断目标卡是否可以加入手牌，若不能则由玩家选择操作方式
		and (not tc:IsAbleToHand() or Duel.SelectOption(tp,1190,1152)==1) then
		-- 执行特殊召唤操作
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)>0 then
			-- 向对方确认特殊召唤的卡
			Duel.ConfirmCards(1-tp,tc)
		end
	else
		-- 将目标卡加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
