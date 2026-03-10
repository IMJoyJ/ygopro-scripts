--シェルヴァレット・ドラゴン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：场上的这张卡为对象的连接怪兽的效果发动时才能发动。这张卡破坏。那之后，选和这张卡存在过的区域相同纵列1只怪兽破坏，那些相邻区域有怪兽存在的场合，那些也破坏。
-- ②：场上的这张卡被战斗·效果破坏送去墓地的回合的结束阶段才能发动。从卡组把「霰弹弹丸龙」以外的1只「弹丸」怪兽特殊召唤。
function c5087128.initial_effect(c)
	-- ①：场上的这张卡为对象的连接怪兽的效果发动时才能发动。这张卡破坏。那之后，选和这张卡存在过的区域相同纵列1只怪兽破坏，那些相邻区域有怪兽存在的场合，那些也破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(5087128,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,5087128)
	e1:SetCondition(c5087128.descon)
	e1:SetTarget(c5087128.destg)
	e1:SetOperation(c5087128.desop)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡被战斗·效果破坏送去墓地的回合的结束阶段才能发动。从卡组把「霰弹弹丸龙」以外的1只「弹丸」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(c5087128.regop)
	c:RegisterEffect(e2)
end
-- 连锁效果的对象必须包含此卡，且该效果为连接怪兽的效果
function c5087128.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁的效果对象卡片组
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or not g:IsContains(c) then return false end
	return re:IsActiveType(TYPE_LINK)
end
-- 判断目标怪兽是否在指定区域组中
function c5087128.desfilter(c,g)
	return g:IsContains(c)
end
-- 判断目标怪兽是否与指定序列相邻且属于指定玩家
function c5087128.desfilter2(c,s,tp)
	local seq=c:GetSequence()
	return seq<5 and math.abs(seq-s)==1 and c:IsControler(tp)
end
-- 检索满足条件的怪兽并设置破坏操作信息
function c5087128.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取场上所有与该卡所在纵列相同的怪兽
	local g=Duel.GetMatchingGroup(c5087128.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,c:GetColumnGroup())
	if chk==0 then return c:IsDestructable() and g:GetCount()>0 end
	-- 设置将此卡破坏的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,c,1,0,0)
	-- 设置将选中怪兽送去墓地的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
-- 处理效果发动时的破坏和连锁破坏逻辑
function c5087128.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local lg=c:GetColumnGroup()
	-- 确认此卡能被破坏并执行破坏操作
	if c:IsRelateToEffect(e) and Duel.Destroy(c,REASON_EFFECT)>0 then
		-- 获取场上所有与该卡所在纵列相同的怪兽
		local g=Duel.GetMatchingGroup(c5087128.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,lg)
		if g:GetCount()==0 then return end
		-- 中断当前效果，使后续效果视为错时处理
		Duel.BreakEffect()
		local tc=nil
		if g:GetCount()==1 then
			tc=g:GetFirst()
		else
			-- 提示玩家选择要破坏的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			tc=g:Select(tp,1,1,nil):GetFirst()
		end
		local seq=tc:GetSequence()
		local dg=Group.CreateGroup()
		-- 获取目标怪兽相邻区域的怪兽组
		if seq<5 then dg=Duel.GetMatchingGroup(c5087128.desfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,nil,seq,tc:GetControler()) end
		-- 若目标怪兽被破坏且相邻怪兽存在，则破坏相邻怪兽
		if Duel.Destroy(tc,REASON_EFFECT)~=0 and dg:GetCount()>0 then
			-- 破坏相邻怪兽
			Duel.Destroy(dg,REASON_EFFECT)
		end
	end
end
-- 当此卡因战斗或效果破坏送去墓地时，注册结束阶段特殊召唤效果
function c5087128.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsReason(REASON_DESTROY) and c:IsPreviousLocation(LOCATION_ONFIELD) then
		-- ②：场上的这张卡被战斗·效果破坏送去墓地的回合的结束阶段才能发动。从卡组把「霰弹弹丸龙」以外的1只「弹丸」怪兽特殊召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(5087128,1))
		e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1,5087129)
		e1:SetRange(LOCATION_GRAVE)
		e1:SetTarget(c5087128.sptg)
		e1:SetOperation(c5087128.spop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 过滤满足条件的「弹丸」怪兽（不包括自身）
function c5087128.spfilter(c,e,tp)
	return c:IsSetCard(0x102) and not c:IsCode(5087128) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否可以发动特殊召唤效果
function c5087128.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断卡组中是否存在符合条件的怪兽
		and Duel.IsExistingMatchingCard(c5087128.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置将1只「弹丸」怪兽特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 处理特殊召唤效果的执行逻辑
function c5087128.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否满足特殊召唤条件（场上是否有召唤位置）
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择符合条件的1只怪兽
	local g=Duel.SelectMatchingCard(tp,c5087128.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
