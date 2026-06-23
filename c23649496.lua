--No.18 紋章祖プレイン・コート
-- 效果：
-- 4星怪兽×2
-- 这张卡的①的效果在同一连锁上只能发动1次。
-- ①：场上有同名怪兽2只以上存在的场合，把这张卡1个超量素材取除才能发动。选那之内的1只，那只怪兽以外的那只怪兽的同名怪兽全部破坏。这个效果在对方回合也能发动。
-- ②：对方不能把这张卡的效果选的怪兽的同名怪兽召唤·反转召唤·特殊召唤。
-- ③：这张卡被送去墓地的场合才能发动。从卡组把2只「纹章兽」怪兽送去墓地。
function c23649496.initial_effect(c)
	-- 为卡片添加等级为4、需要2只怪兽进行XYZ召唤的手续
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- ①：场上有同名怪兽2只以上存在的场合，把这张卡1个超量素材取除才能发动。选那之内的1只，那只怪兽以外的那只怪兽的同名怪兽全部破坏。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(23649496,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e1:SetCost(c23649496.cost)
	e1:SetTarget(c23649496.target)
	e1:SetOperation(c23649496.operation)
	c:RegisterEffect(e1)
	-- ③：这张卡被送去墓地的场合才能发动。从卡组把2只「纹章兽」怪兽送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(23649496,2))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetTarget(c23649496.tgtg)
	e2:SetOperation(c23649496.tgop)
	c:RegisterEffect(e2)
end
-- 设置该卡为编号18的XYZ怪兽
aux.xyz_number[23649496]=18
-- 支付1个超量素材作为费用
function c23649496.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	c:RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤函数，检查场上是否存在至少1只正面表示的同名怪兽
function c23649496.cfilter(c)
	-- 检查场上是否存在至少1只正面表示的同名怪兽
	return c:IsFaceup() and Duel.IsExistingMatchingCard(c23649496.filter,0,LOCATION_MZONE,LOCATION_MZONE,1,c,c:GetCode())
end
-- 过滤函数，检查场上是否存在正面表示且卡号为指定值的怪兽
function c23649496.filter(c,code)
	return c:IsFaceup() and c:IsCode(code)
end
-- 设置效果发动时的处理目标为满足条件的怪兽组
function c23649496.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c23649496.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取满足条件的怪兽组
	local g=Duel.GetMatchingGroup(c23649496.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置连锁操作信息为破坏效果
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 处理效果发动时的破坏操作及限制对方召唤的永续效果
function c23649496.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要破坏的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(23649496,1))  --"送墓"
	-- 选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c23649496.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 获取所有同名怪兽的组
		local dg=Duel.GetMatchingGroup(c23649496.filter,tp,LOCATION_MZONE,LOCATION_MZONE,tc,tc:GetCode())
		-- 将目标怪兽破坏
		Duel.Destroy(dg,REASON_EFFECT)
		if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
		-- 对方不能把这张卡的效果选的怪兽的同名怪兽召唤·反转召唤·特殊召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetRange(LOCATION_MZONE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(0,1)
		e1:SetTarget(c23649496.splimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetLabel(tc:GetCode())
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CANNOT_SUMMON)
		c:RegisterEffect(e2)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
		c:RegisterEffect(e3)
	end
end
-- 限制对方不能特殊召唤指定卡号的怪兽
function c23649496.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsCode(e:GetLabel())
end
-- 过滤函数，检查卡组中是否存在2只以上「纹章兽」类型的怪兽
function c23649496.tgfilter(c)
	return c:IsSetCard(0x76) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 设置效果发动时的处理目标为满足条件的怪兽组
function c23649496.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少2只满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c23649496.tgfilter,tp,LOCATION_DECK,0,2,nil) end
	-- 设置连锁操作信息为送去墓地效果
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,tp,LOCATION_DECK)
end
-- 处理效果发动时的送去墓地操作
function c23649496.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的怪兽组
	local g=Duel.GetMatchingGroup(c23649496.tgfilter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>1 then
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local sg=g:Select(tp,2,2,nil)
		-- 将选择的卡送去墓地
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end
