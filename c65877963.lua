--魔神儀－カリスライム
-- 效果：
-- 「魔神仪的祝诞」降临。这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：把手卡的这张卡给对方观看才能发动。选1张手卡丢弃，从卡组把1只「魔神仪」怪兽特殊召唤。发动后，这个回合中自己对仪式怪兽的特殊召唤没有成功的场合，结束阶段让自己失去2500基本分。
-- ②：从手卡以及自己场上的表侧表示的卡之中把1张「魔神仪」卡送去墓地，以对方场上1只怪兽为对象才能发动。那只怪兽破坏。
function c65877963.initial_effect(c)
	-- 登记这张卡卡名记有「魔神仪的祝诞」
	aux.AddCodeList(c,86758915)
	c:EnableReviveLimit()
	-- ①：把手卡的这张卡给对方观看才能发动。选1张手卡丢弃，从卡组把1只「魔神仪」怪兽特殊召唤。发动后，这个回合中自己对仪式怪兽的特殊召唤没有成功的场合，结束阶段让自己失去2500基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_HANDES_SELF+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,65877963)
	e1:SetCost(c65877963.spcost)
	e1:SetTarget(c65877963.sptg)
	e1:SetOperation(c65877963.spop)
	c:RegisterEffect(e1)
	-- ②：从手卡以及自己场上的表侧表示的卡之中把1张「魔神仪」卡送去墓地，以对方场上1只怪兽为对象才能发动。那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,65877963)
	e2:SetCost(c65877963.descost)
	e2:SetTarget(c65877963.destg)
	e2:SetOperation(c65877963.desop)
	c:RegisterEffect(e2)
end
-- 检查这张卡是否已在手卡公开，作为发动时展示卡片的消费检查
function c65877963.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 过滤卡组中可特殊召唤的「魔神仪」怪兽
function c65877963.spfilter(c,e,tp)
	return c:IsSetCard(0x117) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 丢弃手卡并从卡组特殊召唤效果的发动准备与合法性检查
function c65877963.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区域是否有空位，以及手卡数是否大于0
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0
		-- 并检查卡组中是否存在可特殊召唤的「魔神仪」怪兽
		and Duel.IsExistingMatchingCard(c65877963.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置在连锁处理时从卡组特殊召唤1只怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 丢弃手卡并从卡组特殊召唤效果的实际处理过程，并注册结束阶段失去基本分的效果
function c65877963.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 让玩家选择并丢弃1张手卡，丢弃成功且主要怪兽区域有空位时继续处理
	if Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 玩家选择自己卡组中1只符合条件的「魔神仪」怪兽
		local g=Duel.SelectMatchingCard(tp,c65877963.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将所选怪兽在自己场上表侧表示特殊召唤
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	local c=e:GetHandler()
	-- 发动后，这个回合中自己对仪式怪兽的特殊召唤没有成功的场合，结束阶段让自己失去2500基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetOperation(c65877963.regop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 在玩家身上注册用于记录是否进行过仪式召唤的状况监视效果
	Duel.RegisterEffect(e1,tp)
	-- 结束阶段让自己失去2500基本分。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetCondition(c65877963.damcon)
	e2:SetOperation(c65877963.damop)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetLabelObject(e1)
	-- 在玩家身上注册结束阶段时检测若未成功进行仪式召唤则失去2500基本分的效果
	Duel.RegisterEffect(e2,tp)
end
-- 过滤特殊召唤成功的卡片是否为自己召唤的仪式怪兽
function c65877963.regfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsType(TYPE_RITUAL)
end
-- 满足特殊召唤成功条件时，将标志标签设置为1，表示本回合自己进行过仪式怪兽的特殊召唤
function c65877963.regop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(c65877963.regfilter,1,nil,tp) then
		e:SetLabel(1)
	end
end
-- 检查玩家本回合是否没有成功仪式召唤过怪兽，作为结束阶段扣减生命值的条件
function c65877963.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():GetLabel()~=1
end
-- 结束阶段时扣减玩家2500基本分的操作处理
function c65877963.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 扣减玩家2500基本分
	Duel.SetLP(tp,Duel.GetLP(tp)-2500)
end
-- 过滤手卡及场上表侧表示可以送去墓地的「魔神仪」卡片
function c65877963.cfilter(c)
	return (c:IsFaceup() or c:IsLocation(LOCATION_HAND)) and c:IsSetCard(0x117) and c:IsAbleToGraveAsCost()
end
-- 破坏效果的消耗动作，玩家选择1张手卡或场上的表侧表示「魔神仪」卡送去墓地
function c65877963.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检查：检查手卡或场上表侧表示是否存在可作为消耗送去墓地的「魔神仪」卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c65877963.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家选择1张符合条件的「魔神仪」卡片
	local g=Duel.SelectMatchingCard(tp,c65877963.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	-- 将所选的卡片作为发动消耗送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 破坏效果的发动准备与合法性检查，并进行取对象
function c65877963.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在可成为效果对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择对方场上1只怪兽作为破坏效果处理对象
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置在连锁处理时破坏目标怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果的实际处理过程
function c65877963.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果中被选为破坏对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以效果的原因为由破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
