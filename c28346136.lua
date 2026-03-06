--銀河眼の極光波竜
-- 效果：
-- 10星怪兽×2
-- 「银河眼极光波龙」1回合1次也能在自己场上的「光波龙」怪兽上面重叠来超量召唤。
-- ①：把这张卡2个超量素材取除才能发动。自己场上的光属性怪兽直到对方回合结束时不会成为对方的效果的对象。
-- ②：自己准备阶段才能发动。自己墓地1只9阶以下的龙族超量怪兽回到额外卡组。那之后，可以把那只怪兽在自己场上的这张卡上面重叠当作超量召唤从额外卡组特殊召唤。
function c28346136.initial_effect(c)
	aux.AddXyzProcedure(c,nil,10,2,c28346136.ovfilter,aux.Stringid(28346136,0),2,c28346136.xyzop)  --"是否在「光波龙」怪兽上面重叠来超量召唤？"
	c:EnableReviveLimit()
	-- ①：把这张卡2个超量素材取除才能发动。自己场上的光属性怪兽直到对方回合结束时不会成为对方的效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(28346136,1))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c28346136.cost)
	e1:SetOperation(c28346136.operation)
	c:RegisterEffect(e1)
	-- ②：自己准备阶段才能发动。自己墓地1只9阶以下的龙族超量怪兽回到额外卡组。那之后，可以把那只怪兽在自己场上的这张卡上面重叠当作超量召唤从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(28346136,2))
	e2:SetCategory(CATEGORY_TOEXTRA+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCountLimit(1)
	e2:SetCondition(c28346136.con)
	e2:SetTarget(c28346136.tg)
	e2:SetOperation(c28346136.op)
	c:RegisterEffect(e2)
end
-- 判断是否为「光波龙」怪兽
function c28346136.ovfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x10e5)
end
-- 检查是否已使用过效果，若未使用则注册标识效果
function c28346136.xyzop(e,tp,chk)
	-- 检查是否已使用过效果
	if chk==0 then return Duel.GetFlagEffect(tp,28346136)==0 end
	-- 注册标识效果，使本回合不能再使用效果
	Duel.RegisterFlagEffect(tp,28346136,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- 筛选场上光属性怪兽
function c28346136.filter1(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- 支付2个超量素材作为cost
function c28346136.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
-- 使场上所有光属性怪兽在对方回合结束前不会成为对方效果的对象
function c28346136.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 筛选场上所有光属性怪兽
	local g=Duel.GetMatchingGroup(c28346136.filter1,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 使目标怪兽在对方回合结束前不会成为对方效果的对象
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		-- 设置效果值为不会成为对方效果的对象
		e3:SetValue(aux.tgoval)
		tc:RegisterEffect(e3)
		tc=g:GetNext()
	end
end
-- 判断是否为自己的准备阶段
function c28346136.con(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为自己的回合
	return Duel.GetTurnPlayer()==tp
end
-- 筛选墓地9阶以下的龙族超量怪兽
function c28346136.filter(c)
	return c:IsType(TYPE_XYZ) and c:IsRankBelow(9) and c:IsRace(RACE_DRAGON) and c:IsAbleToExtra()
end
-- 设置连锁操作信息，准备将怪兽送回额外卡组
function c28346136.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查墓地是否存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c28346136.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息，指定将怪兽送回额外卡组
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,nil,1,tp,LOCATION_GRAVE)
end
-- 处理效果，选择怪兽送回额外卡组并尝试特殊召唤
function c28346136.op(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送回卡组的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择1只符合条件的怪兽送回额外卡组
	local g=Duel.SelectMatchingCard(tp,c28346136.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g==0 then return end
	-- 将选中的怪兽送回额外卡组
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	local c=e:GetHandler()
	local sc=g:GetFirst()
	if sc:IsLocation(LOCATION_EXTRA) and c:IsRelateToEffect(e) and c:IsFaceup() and c:IsControler(tp)
		and c:IsCanBeXyzMaterial(sc) and sc:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
		-- 检查是否有足够的位置进行特殊召唤并满足成为素材的条件
		and Duel.GetLocationCountFromEx(tp,tp,c,sc)>0 and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
		-- 询问玩家是否将怪兽特殊召唤
		and Duel.SelectYesNo(tp,aux.Stringid(28346136,4)) then  --"是否把那只怪兽特殊召唤？"
		-- 中断当前效果处理
		Duel.BreakEffect()
		local mg=c:GetOverlayGroup()
		if mg:GetCount()~=0 then
			-- 将自身叠放的怪兽叠放到目标怪兽上
			Duel.Overlay(sc,mg)
		end
		sc:SetMaterial(Group.FromCards(c))
		-- 将自身叠放到目标怪兽上
		Duel.Overlay(sc,Group.FromCards(c))
		-- 将目标怪兽特殊召唤
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
	end
end
