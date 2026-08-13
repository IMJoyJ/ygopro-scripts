--No.18 紋章祖プレイン・コート
-- 效果：
-- 4星怪兽×2
-- 这张卡的①的效果在同一连锁上只能发动1次。
-- ①：场上有同名怪兽2只以上存在的场合，把这张卡1个超量素材取除才能发动。选那之内的1只，那只怪兽以外的那只怪兽的同名怪兽全部破坏。这个效果在对方回合也能发动。
-- ②：对方不能把这张卡的效果选的怪兽的同名怪兽召唤·反转召唤·特殊召唤。
-- ③：这张卡被送去墓地的场合才能发动。从卡组把2只「纹章兽」怪兽送去墓地。
function c23649496.initial_effect(c)
	-- 为No.18添加XYZ召唤手续：以4星怪兽2只为素材进行XYZ召唤。
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- 这张卡的①的效果在同一连锁上只能发动1次。①：场上有同名怪兽2只以上存在的场合，把这张卡1个超量素材取除才能发动。选那之内的1只，那只怪兽以外的那只怪兽的同名怪兽全部破坏。这个效果在对方回合也能发动。
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
-- 将这张卡的卡号23649496登记为No.18（XYZ编号18）。
aux.xyz_number[23649496]=18
-- 效果①的发动代价处理：发动时检查此卡是否有1个超量素材可去除；若有则去除1个超量素材作为代价。
function c23649496.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	c:RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- cfilter：判断一张怪兽卡是否表侧表示，并且场上还存在另一只与它同名的表侧表示怪兽（即满足“场上有同名怪兽2只以上存在”）。
function c23649496.cfilter(c)
	-- 检查c是表侧表示，且场上存在至少1只与c同名的其他表侧表示怪兽作为同名怪兽的判定条件。
	return c:IsFaceup() and Duel.IsExistingMatchingCard(c23649496.filter,0,LOCATION_MZONE,LOCATION_MZONE,1,c,c:GetCode())
end
-- filter：检查怪兽是否表侧表示且卡名与给定的卡号code一致（即同名怪兽）。
function c23649496.filter(c,code)
	return c:IsFaceup() and c:IsCode(code)
end
-- 效果①的发动时点合法判定与操作信息设置：若场上存在满足“有同名怪兽2只以上”的表侧表示怪兽，则取得这些怪兽作为可能破坏的对象，并设置破坏操作信息。
function c23649496.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果①发动条件检查：场上是否存在至少1只满足cfilter的怪兽（即存在同名怪兽2只以上）。
	if chk==0 then return Duel.IsExistingMatchingCard(c23649496.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 取得所有满足cfilter条件的怪兽，作为效果处理时选择“那之内的1只”以及后续破坏对象的候选集合。
	local g=Duel.GetMatchingGroup(c23649496.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置该连锁的操作信息：本效果为破坏效果，可能被破坏的目标为g，预定破坏数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果①的结算：玩家选择1只作为基准的同名怪兽，将场上该怪兽以外的所有同名怪兽全部破坏；若此卡仍与效果关联且表侧表示，则给此卡赋予②效果：对方不能特殊召唤/召唤/反转召唤该选定怪兽的同名怪兽。
function c23649496.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 发出选择提示，提示玩家选择一张满足条件的表侧表示同名怪兽作为“那之内的1只”。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(23649496,1))  --"送墓"
	-- 让玩家从符合条件的怪兽中选择1只作为基准同名怪兽。
	local g=Duel.SelectMatchingCard(tp,c23649496.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 取得场上除基准怪兽tc以外所有与tc同名的表侧表示怪兽（这些即为“那只怪兽以外的同名怪兽”）。
		local dg=Duel.GetMatchingGroup(c23649496.filter,tp,LOCATION_MZONE,LOCATION_MZONE,tc,tc:GetCode())
		-- 将取得的同名怪兽全部破坏。
		Duel.Destroy(dg,REASON_EFFECT)
		if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
		-- ②：对方不能把这张卡的效果选的怪兽的同名怪兽召唤·反转召唤·特殊召唤。
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
-- splimit：限制效果的适用条件——被尝试召唤/特殊召唤/反转召唤的怪兽的卡名与①效果选定怪兽（e:GetLabel()中记录的卡号）一致时才适用。
function c23649496.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsCode(e:GetLabel())
end
-- tgfilter：检查卡是否为「纹章兽」怪兽且为怪兽卡，并且可以被送去墓地。
function c23649496.tgfilter(c)
	return c:IsSetCard(0x76) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 效果③的发动条件与操作信息设置：检查卡组中是否存在至少2只符合条件的「纹章兽」怪兽，若有则设置送墓操作信息。
function c23649496.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果③发动条件检查：卡组中是否存在至少2只可送去墓地的「纹章兽」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c23649496.tgfilter,tp,LOCATION_DECK,0,2,nil) end
	-- 设置操作信息：本效果为送去墓地效果，预定将卡组的2张卡送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,tp,LOCATION_DECK)
end
-- 效果③的结算：从卡组中选择2只「纹章兽」怪兽送去墓地。
function c23649496.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得卡组中所有符合条件的「纹章兽」怪兽作为候选。
	local g=Duel.GetMatchingGroup(c23649496.tgfilter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>1 then
		-- 发出选择提示，提示玩家选择要送去墓地的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local sg=g:Select(tp,2,2,nil)
		-- 将玩家选择的2只「纹章兽」怪兽以效果原因送去墓地。
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end
