--星守の騎士 プトレマイオス
-- 效果：
-- 4星怪兽×2只以上
-- ①：可以把这张卡的超量素材的以下数量取除，那个效果发动。
-- ●3个：自己·对方回合可以发动（同一连锁上最多1次）。除「No.」怪兽外的比这张卡阶级高1阶的1只超量怪兽在自己场上的这张卡上面重叠当作超量召唤从额外卡组特殊召唤。
-- ●7个：自己主要阶段才能发动。下次的对方回合跳过。
-- ②：自己·对方的结束阶段才能发动。从额外卡组把1张「星辉士」卡作为这张卡的超量素材。
function c18326736.initial_effect(c)
	-- 添加超量召唤手续，要求场上存在至少2只等级为4的怪兽作为素材
	aux.AddXyzProcedure(c,nil,4,2,nil,nil,99)
	c:EnableReviveLimit()
	-- 自己·对方回合可以发动（同一连锁上最多1次）。除「No.」怪兽外的比这张卡阶级高1阶的1只超量怪兽在自己场上的这张卡上面重叠当作超量召唤从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(18326736,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e1:SetCost(c18326736.spcost)
	e1:SetTarget(c18326736.sptg)
	e1:SetOperation(c18326736.spop)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e1)
	-- 自己主要阶段才能发动。下次的对方回合跳过。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(18326736,1))  --"下次对方回合跳过"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c18326736.skipcost)
	e2:SetTarget(c18326736.skiptg)
	e2:SetOperation(c18326736.skipop)
	c:RegisterEffect(e2)
	-- 自己·对方的结束阶段才能发动。从额外卡组把1张「星辉士」卡作为这张卡的超量素材。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(18326736,2))  --"添加超量素材"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c18326736.mttg)
	e3:SetOperation(c18326736.mtop)
	c:RegisterEffect(e3)
end
-- 支付3个超量素材作为cost
function c18326736.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,3,REASON_COST) end
	c:RemoveOverlayCard(tp,3,3,REASON_COST)
end
-- 过滤满足等级、种族、可作为超量素材、可特殊召唤且有召唤空间的额外怪兽
function c18326736.filter(c,e,tp,rk,mc)
	return c:IsRank(rk) and not c:IsSetCard(0x48) and e:GetHandler():IsCanBeXyzMaterial(c)
		-- 检查目标怪兽是否可以被特殊召唤且场上存在召唤空间
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 设置特殊召唤的条件，检查是否满足超量素材要求并存在符合条件的额外怪兽
function c18326736.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否满足超量素材要求
	if chk==0 then return aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
		-- 检查是否存在满足条件的额外怪兽
		and Duel.IsExistingMatchingCard(c18326736.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c:GetRank()+1,c) end
	-- 设置连锁操作信息，表示将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 执行特殊召唤操作，选择目标怪兽并将其特殊召唤
function c18326736.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 再次检查是否满足超量素材要求
	if not aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if c:IsFacedown() or not c:IsRelateToEffect(e) or c:IsControler(1-tp) or c:IsImmuneToEffect(e) then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的额外怪兽
	local g=Duel.SelectMatchingCard(tp,c18326736.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,c:GetRank()+1,c)
	local sc=g:GetFirst()
	if sc then
		local mg=c:GetOverlayGroup()
		if mg:GetCount()~=0 then
			-- 将原卡的叠放卡叠放到目标怪兽上
			Duel.Overlay(sc,mg)
		end
		sc:SetMaterial(Group.FromCards(c))
		-- 将原卡叠放到目标怪兽上
		Duel.Overlay(sc,Group.FromCards(c))
		-- 将目标怪兽以超量召唤方式特殊召唤
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
	end
end
-- 支付7个超量素材作为cost
function c18326736.skipcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,7,REASON_COST) end
	c:RemoveOverlayCard(tp,7,7,REASON_COST)
end
-- 设置跳过对方回合的效果发动条件
function c18326736.skiptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方是否未被跳过回合效果影响
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(1-tp,EFFECT_SKIP_TURN) end
end
-- 注册跳过对方回合的效果
function c18326736.skipop(e,tp,eg,ep,ev,re,r,rp)
	-- 注册跳过对方回合的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_SKIP_TURN)
	e1:SetTargetRange(0,1)
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
	e1:SetCondition(c18326736.skipcon)
	-- 将效果注册到玩家全局环境
	Duel.RegisterEffect(e1,tp)
end
-- 设置跳过回合效果的触发条件
function c18326736.skipcon(e)
	-- 当回合玩家不是效果持有者时触发跳过回合效果
	return Duel.GetTurnPlayer()~=e:GetHandlerPlayer()
end
-- 过滤满足种族且可叠放的额外怪兽
function c18326736.mtfilter(c)
	return c:IsSetCard(0x109c) and c:IsCanOverlay()
end
-- 设置添加超量素材的条件，检查是否为超量怪兽且存在满足条件的额外怪兽
function c18326736.mttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ)
		-- 检查是否存在满足条件的额外怪兽
		and Duel.IsExistingMatchingCard(c18326736.mtfilter,tp,LOCATION_EXTRA,0,1,nil) end
end
-- 执行添加超量素材的操作，选择目标怪兽并将其叠放到原卡上
function c18326736.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 提示玩家选择要作为超量素材的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 选择满足条件的额外怪兽
	local g=Duel.SelectMatchingCard(tp,c18326736.mtfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将目标怪兽叠放到原卡上
		Duel.Overlay(c,g)
	end
end
