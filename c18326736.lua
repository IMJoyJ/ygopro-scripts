--星守の騎士 プトレマイオス
-- 效果：
-- 4星怪兽×2只以上
-- ①：可以把这张卡的超量素材的以下数量取除，那个效果发动。
-- ●3个：自己·对方回合可以发动（同一连锁上最多1次）。除「No.」怪兽外的比这张卡阶级高1阶的1只超量怪兽在自己场上的这张卡上面重叠当作超量召唤从额外卡组特殊召唤。
-- ●7个：自己主要阶段才能发动。下次的对方回合跳过。
-- ②：自己·对方的结束阶段才能发动。从额外卡组把1张「星辉士」卡作为这张卡的超量素材。
function c18326736.initial_effect(c)
	-- 为这张卡设置超量召唤手续：可以用任意4星怪兽2只以上（最高99只）作为超量素材进行超量召唤。
	aux.AddXyzProcedure(c,nil,4,2,nil,nil,99)
	c:EnableReviveLimit()
	-- 对应效果原文：①：可以把这张卡的超量素材的以下数量取除，那个效果发动。●3个：自己·对方回合可以发动（同一连锁上最多1次）。除「No.」怪兽外的比这张卡阶级高1阶的1只超量怪兽在自己场上的这张卡上面重叠当作超量召唤从额外卡组特殊召唤。
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
	-- 对应效果原文：①：可以把这张卡的超量素材的以下数量取除，那个效果发动。●7个：自己主要阶段才能发动。下次的对方回合跳过。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(18326736,1))  --"下次对方回合跳过"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c18326736.skipcost)
	e2:SetTarget(c18326736.skiptg)
	e2:SetOperation(c18326736.skipop)
	c:RegisterEffect(e2)
	-- 对应效果原文：②：自己·对方的结束阶段才能发动。从额外卡组把1张「星辉士」卡作为这张卡的超量素材。
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
-- 效果发动费用：检查这张卡是否有至少3个超量素材，若有则取除3个作为发动代价。
function c18326736.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,3,REASON_COST) end
	c:RemoveOverlayCard(tp,3,3,REASON_COST)
end
-- 定义额外卡组候选怪兽的过滤条件：必须是阶级为指定阶级（这张卡的阶级+1）的超量怪兽，不能是「No.」怪兽，这张卡能够作为它的超量素材，并且它能被当前效果以超量召唤形式特殊召唤，且这张卡移出后仍有可用的额外怪兽特殊召唤区域。
function c18326736.filter(c,e,tp,rk,mc)
	return c:IsRank(rk) and not c:IsSetCard(0x48) and e:GetHandler():IsCanBeXyzMaterial(c)
		-- 额外卡组候选怪兽还必须是能够以超量召唤形式由我方特殊召唤的怪兽（同时满足召唤条件和苏生限制），并且除去这张卡作为素材后，我方场上仍有足够的额外卡组怪兽特殊召唤空格。
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- ①效果（3个素材）的发动目标判定：确认「必须作为超量素材」的限制满足，且额外卡组存在至少1只符合条件的超量怪兽（阶级比这张卡高1、非「No.」等），才能发动。
function c18326736.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动条件之一：检查这张卡相关部分是否满足「必须作为超量素材」的限制，若不满足则不能发动。
	if chk==0 then return aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
		-- 发动条件之二：检查额外卡组中是否存在至少1只满足filter条件的超量怪兽（阶级为这张卡阶级+1且不是「No.」怪兽）。
		and Duel.IsExistingMatchingCard(c18326736.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c:GetRank()+1,c) end
	-- 向系统登记本次效果将进行从额外卡组特殊召唤1只怪兽的操作，且不取对象，供其他卡检测和连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：重新确认合法后，从额外卡组选择1只符合条件的超量怪兽，将这张卡原持有的超量素材移到其下方，再把这张卡自身叠放作为超量素材，以超量召唤形式表侧表示特殊召唤。
function c18326736.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理时再次检查「必须作为超量素材」限制是否仍然满足，如果不再满足则整个效果不处理。
	if not aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if c:IsFacedown() or not c:IsRelateToEffect(e) or c:IsControler(1-tp) or c:IsImmuneToEffect(e) then return end
	-- 向玩家显示选择特殊召唤对象的提示信息（请选择要特殊召唤的卡）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 发动者从额外卡组选择1张满足filter条件的超量怪兽作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c18326736.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,c:GetRank()+1,c)
	local sc=g:GetFirst()
	if sc then
		local mg=c:GetOverlayGroup()
		if mg:GetCount()~=0 then
			-- 将这张卡原有的全部超量素材挪到新选择的超量怪兽下方，作为那只怪兽的超量素材。
			Duel.Overlay(sc,mg)
		end
		sc:SetMaterial(Group.FromCards(c))
		-- 将这张卡自身也叠放到新选择的超量怪兽下方，作为其超量素材。
		Duel.Overlay(sc,Group.FromCards(c))
		-- 将所选择的超量怪兽以超量召唤形式表侧表示特殊召唤到我方场上。
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
	end
end
-- 效果发动费用：检查这张卡是否有至少7个超量素材，若有则取除7个作为发动代价。
function c18326736.skipcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,7,REASON_COST) end
	c:RemoveOverlayCard(tp,7,7,REASON_COST)
end
-- 「跳过对方回合」效果的发动条件：对方玩家当前不能已经处于被“跳过回合”效果影响的状态；若对方已经会被跳过回合，则不能发动。
function c18326736.skiptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 具体判定：检查对方是否受到EFFECT_SKIP_TURN影响，若已受影响则本效果无法发动。
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(1-tp,EFFECT_SKIP_TURN) end
end
-- 效果处理：给对手设置一个“跳过下个回合”的场上效果，效果仅影响对手，在对手回合结束阶段后自动重置，并且只会在对方回合时适用。
function c18326736.skipop(e,tp,eg,ep,ev,re,r,rp)
	-- 对应效果原文：●7个：自己主要阶段才能发动。下次的对方回合跳过。②：自己·对方的结束阶段才能发动。从额外卡组把1张「星辉士」卡作为这张卡的超量素材。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_SKIP_TURN)
	e1:SetTargetRange(0,1)
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
	e1:SetCondition(c18326736.skipcon)
	-- 将生成的“跳过对方回合”效果注册到场上，使其从此刻开始对对方玩家适用。
	Duel.RegisterEffect(e1,tp)
end
-- 定义该跳过回合效果的适用条件函数：只有当前回合玩家不是效果持有者时，效果才会适用。
function c18326736.skipcon(e)
	-- 条件判断：当前回合玩家不是这张卡的持有者（即已经轮到对方回合），满足时对方回合将被跳过。
	return Duel.GetTurnPlayer()~=e:GetHandlerPlayer()
end
-- ②效果素材的过滤条件：额外卡组中卡名属于「星辉士／星骑士」字段（0x109c），并且可以作为超量素材叠放在其他超量怪兽下方的卡片。
function c18326736.mtfilter(c)
	return c:IsSetCard(0x109c) and c:IsCanOverlay()
end
-- ②效果的发动条件：这张卡仍具有超量怪兽类型，并且额外卡组存在至少1张满足mtfilter条件的「星辉士」卡。
function c18326736.mttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ)
		-- 发动条件后半段：额外卡组存在至少1张字段为「星辉士／星骑士」且可以作为超量素材的卡。
		and Duel.IsExistingMatchingCard(c18326736.mtfilter,tp,LOCATION_EXTRA,0,1,nil) end
end
-- ②效果处理：确认这张卡仍与效果关联后，从额外卡组选择1张符合条件的「星辉士」卡，叠放到这张卡下面作为超量素材。
function c18326736.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 向玩家显示选择超量素材的提示信息（请选择要作为超量素材的卡）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 发动者从额外卡组选择1张满足mtfilter条件的「星辉士」卡。
	local g=Duel.SelectMatchingCard(tp,c18326736.mtfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的「星辉士」卡叠放到这张卡下面，作为这张卡的超量素材。
		Duel.Overlay(c,g)
	end
end
