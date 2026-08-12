--天霆號アーゼウス
-- 效果：
-- 12星怪兽×2
-- 「天霆号 阿宙斯」在超量怪兽进行过战斗的回合有1次也能在自己场上的超量怪兽上面重叠来超量召唤。
-- ①：自己·对方回合，把这张卡2个超量素材取除才能发动。场上的其他卡全部送去墓地。
-- ②：1回合1次，自己场上的其他卡被战斗或者对方的效果破坏的场合才能发动。从手卡·卡组·额外卡组把1张卡作为这张卡的超量素材。
function c90448279.initial_effect(c)
	aux.AddXyzProcedure(c,nil,12,2,c90448279.ovfilter,aux.Stringid(90448279,0),2,c90448279.xyzop)  --"是否在超量怪兽上面重叠来超量召唤？"
	c:EnableReviveLimit()
	-- ①：自己·对方回合，把这张卡2个超量素材取除才能发动。场上的其他卡全部送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(90448279,1))  --"全部送去墓地"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCost(c90448279.tgcost)
	e1:SetTarget(c90448279.tgtg)
	e1:SetOperation(c90448279.tgop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己场上的其他卡被战斗或者对方的效果破坏的场合才能发动。从手卡·卡组·额外卡组把1张卡作为这张卡的超量素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(90448279,2))  --"补充超量素材"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c90448279.ovcon)
	e2:SetTarget(c90448279.ovtg)
	e2:SetOperation(c90448279.ovop)
	c:RegisterEffect(e2)
	if not c90448279.global_check then
		c90448279.global_check=true
		-- 「天霆号 阿宙斯」在超量怪兽进行过战斗的回合有1次也能在自己场上的超量怪兽上面重叠来超量召唤。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_BATTLED)
		ge1:SetOperation(c90448279.checkop)
		-- 注册全局环境下的战斗检测效果，用于记录是否有超量怪兽进行过战斗。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 过滤函数，用于筛选自己场上表侧表示的超量怪兽作为重叠超量召唤的素材。
function c90448279.ovfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- 超量召唤的操作函数，检查本回合是否有超量怪兽进行过战斗，并注册该特殊召唤方式每回合只能使用1次的限制。
function c90448279.xyzop(e,tp,chk)
	-- 检查本回合是否有超量怪兽进行过战斗，且本回合自己尚未通过此方法特殊召唤过「天霆号 阿宙斯」。
	if chk==0 then return Duel.GetFlagEffect(tp,90448279)>0 and Duel.GetFlagEffect(tp,90448280)==0 end
	-- 为玩家注册已使用过此方法超量召唤的标识，持续到回合结束。
	Duel.RegisterFlagEffect(tp,90448280,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- 检查卡片是否为超量怪兽。
function c90448279.check(c)
	return c and c:IsType(TYPE_XYZ)
end
-- 战斗检测的操作函数，若有超量怪兽进行过战斗，则为双方玩家注册已发生超量怪兽战斗的标识。
function c90448279.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断进行战斗的攻击怪兽或被攻击怪兽是否为超量怪兽。
	if c90448279.check(Duel.GetAttacker()) or c90448279.check(Duel.GetAttackTarget()) then
		-- 为自己玩家注册本回合有超量怪兽进行过战斗的标识。
		Duel.RegisterFlagEffect(tp,90448279,RESET_PHASE+PHASE_END,0,1)
		-- 为对方玩家注册本回合有超量怪兽进行过战斗的标识。
		Duel.RegisterFlagEffect(1-tp,90448279,RESET_PHASE+PHASE_END,0,1)
	end
end
-- 效果①的代价处理函数，检查并取除这张卡的2个超量素材。
function c90448279.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
-- 效果①的发动准备函数，检查场上是否存在可以送去墓地的其他卡，并设置送去墓地的操作信息。
function c90448279.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取场上除这张卡以外的所有可以送去墓地的卡片组。
	local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	if chk==0 then return #g>0 end
	-- 设置效果处理信息，表示将要把这些卡送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,#g,0,0)
end
-- 效果①的效果处理函数，将场上除这张卡以外的所有卡送去墓地。
function c90448279.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上除这张卡（若仍在场）以外的所有可以送去墓地的卡片组。
	local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	if #g>0 then
		-- 将符合条件的卡片因效果全部送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 过滤函数，用于筛选原本由自己控制、在场上被战斗破坏或被对方效果破坏的卡。
function c90448279.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD) and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp)
end
-- 效果②的发动条件函数，检查是否有自己场上的其他卡被战斗或对方的效果破坏。
function c90448279.ovcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c90448279.cfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- 过滤函数，用于筛选可以作为超量素材且不受该效果影响的卡。
function c90448279.ofilter(c,e)
	return c:IsCanOverlay() and (not e or not c:IsImmuneToEffect(e))
end
-- 效果②的发动准备函数，检查自身是否为超量怪兽，以及手卡、卡组、额外卡组中是否存在可以作为超量素材的卡。
function c90448279.ovtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查自身是否为超量怪兽，且自己的手卡、卡组、额外卡组中是否存在至少1张可以作为超量素材的卡。
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ) and Duel.IsExistingMatchingCard(c90448279.ofilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA,0,1,nil) end
end
-- 效果②的效果处理函数，从手卡、卡组或额外卡组选择1张卡重叠作为这张卡的超量素材，并洗牌。
function c90448279.ovop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 向玩家发送提示信息，要求选择要作为超量素材的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
		-- 让玩家从自己的手卡、卡组、额外卡组中选择1张可以作为超量素材的卡。
		local g=Duel.SelectMatchingCard(tp,c90448279.ofilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e)
		local tc=g:GetFirst()
		if tc then
			-- 将选择的卡片重叠作为这张卡的超量素材。
			Duel.Overlay(c,tc)
		end
		-- 洗切自己的卡组。
		Duel.ShuffleDeck(tp)
	end
end
