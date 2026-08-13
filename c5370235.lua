--サイバー・ダーク・キメラ
--not fully implemented
-- 效果：
-- （注：暂时无法正常使用）
-- 
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从手卡丢弃1张魔法·陷阱卡才能发动。从卡组把1张「力量结合」加入手卡。这个回合，自己不是龙族·机械族的「电子」怪兽不能作为融合素材，自己把怪兽融合召唤的场合只有1次，也能把自己墓地的怪兽除外作为融合素材。
-- ②：这张卡被送去墓地的场合才能发动。同名卡不在自己墓地存在的1只「电子暗黑」怪兽从卡组送去墓地。
function c5370235.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：从手卡丢弃1张魔法·陷阱卡才能发动。从卡组把1张「力量结合」加入手卡。这个回合，自己不是龙族·机械族的「电子」怪兽不能作为融合素材，自己把怪兽融合召唤的场合只有1次，也能把自己墓地的怪兽除外作为融合素材。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(5370235,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,5370235)
	e1:SetCost(c5370235.thcost)
	e1:SetTarget(c5370235.thtg)
	e1:SetOperation(c5370235.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡被送去墓地的场合才能发动。同名卡不在自己墓地存在的1只「电子暗黑」怪兽从卡组送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(5370235,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,5370236)
	e2:SetTarget(c5370235.tgtg)
	e2:SetOperation(c5370235.tgop)
	c:RegisterEffect(e2)
	-- 检查是否已安装过融合素材补丁，避免重复覆盖全局函数。
	if not aux.fus_mat_hack_check then
		-- 标记融合素材补丁已安装。
		aux.fus_mat_hack_check=true
		-- 定义过滤函数，筛选拥有EFFECT_EXTRA_FUSION_MATERIAL效果的额外怪兽卡。
		function aux.fus_mat_hack_exmat_filter(c)
			return c:IsHasEffect(EFFECT_EXTRA_FUSION_MATERIAL,c:GetControler())
		end
		-- 保存原始的Duel.GetFusionMaterial函数引用，供覆盖后的函数调用原始逻辑。
		_GetFusionMaterial=Duel.GetFusionMaterial
		-- 覆盖Duel.GetFusionMaterial，在原始手卡·场上素材的基础上，额外加入额外卡组中拥有EFFECT_EXTRA_FUSION_MATERIAL效果的卡作为可用融合素材。
		function Duel.GetFusionMaterial(tp,loc)
			if loc==nil then loc=LOCATION_HAND+LOCATION_MZONE end
			local g=_GetFusionMaterial(tp,loc)
			-- 从额外卡组筛选出所有拥有EFFECT_EXTRA_FUSION_MATERIAL效果的额外怪兽。
			local exg=Duel.GetMatchingGroup(aux.fus_mat_hack_exmat_filter,tp,LOCATION_EXTRA,0,nil)
			return g+exg
		end
		-- 保存原始的Duel.SendtoGrave函数引用，为覆盖做准备。
		_SendtoGrave=Duel.SendtoGrave
		-- 覆盖Duel.SendtoGrave，特殊处理融合素材送墓：若素材来自额外且具有EFFECT_EXTRA_FUSION_MATERIAL效果，则消耗其使用次数；若素材来自墓地，则改为除外而非送墓。
		function Duel.SendtoGrave(tg,reason)
			-- 当不是融合召唤素材送墓（reason不匹配）或目标不是Group时，直接调用原始送墓函数，不做特殊处理。
			if reason~=REASON_EFFECT+REASON_MATERIAL+REASON_FUSION or aux.GetValueType(tg)~="Group" then
				return _SendtoGrave(tg,reason)
			end
			-- 在本次送墓的融合素材中，找到位于额外或墓地且拥有EFFECT_EXTRA_FUSION_MATERIAL效果的卡，用于消耗其使用次数。
			local tc=tg:Filter(Card.IsLocation,nil,LOCATION_EXTRA+LOCATION_GRAVE):Filter(aux.fus_mat_hack_exmat_filter,nil):GetFirst()
			if tc then
				local te=tc:IsHasEffect(EFFECT_EXTRA_FUSION_MATERIAL,tc:GetControler())
				te:UseCountLimit(tc:GetControler())
			end
			local rg=tg:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
			tg:Sub(rg)
			local ct1=_SendtoGrave(tg,reason)
			-- 将原本应作为融合素材从墓地送墓的卡改为除外，返回实际除外的数量，模拟‘把墓地的怪兽除外作为融合素材’。
			local ct2=Duel.Remove(rg,POS_FACEUP,reason)
			return ct1+ct2
		end
	end
end
-- 定义costfilter，筛选手牌中可丢弃的魔法·陷阱卡。
function c5370235.costfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsDiscardable()
end
-- 定义thcost，作为效果①的发动代价：检查手牌是否有可丢弃的魔法·陷阱卡，若有则丢弃1张作为代价。
function c5370235.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段：确认手牌中是否存在至少1张可丢弃的魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c5370235.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 执行丢弃1张魔法·陷阱卡作为发动代价。
	Duel.DiscardHand(tp,c5370235.costfilter,1,1,REASON_COST+REASON_DISCARD,nil)
end
-- 定义thfilter，筛选卡组中卡名为「力量结合」且能加入手牌的卡。
function c5370235.thfilter(c)
	return c:IsCode(37630732) and c:IsAbleToHand()
end
-- 定义thtg，作为效果①的发动目标：检查卡组中是否有「力量结合」可检索，并设置操作信息。
function c5370235.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 目标检查阶段：确认卡组中存在「力量结合」且能够加入手牌。
	if chk==0 then return Duel.IsExistingMatchingCard(c5370235.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果涉及从卡组将1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①处理：从卡组检索「力量结合」加入手牌并向对方展示，然后附加本回合的融合素材限制（禁止非龙族/机械族「电子」怪兽作为融合素材），并赋予自己把墓地怪兽除外作为融合素材的追加效果。
function c5370235.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，要求玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张符合条件的「力量结合」。
	local g=Duel.SelectMatchingCard(tp,c5370235.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的「力量结合」加入持有者的手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示检索到的卡牌。
		Duel.ConfirmCards(1-tp,g)
	end
	-- 对应效果原文：这个回合，自己不是龙族·机械族的「电子」怪兽不能作为融合素材。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(0xff,0xff)
	e1:SetTarget(c5370235.limittg)
	e1:SetValue(c5370235.fuslimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将本回合不能作为融合素材的怪兽限制效果注册到场上。
	Duel.RegisterEffect(e1,tp)
	-- 对应效果原文：这个回合，自己把怪兽融合召唤的场合只有1次，也能把自己墓地的怪兽除外作为融合素材。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetDescription(aux.Stringid(5370235,2))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_EXTRA_FUSION_MATERIAL)
	e2:SetTargetRange(LOCATION_GRAVE,0)
	e2:SetTarget(c5370235.mttg)
	e2:SetValue(1)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 将本回合可从墓地除外作为融合素材的追加效果注册到场上。
	Duel.RegisterEffect(e2,tp)
end
-- 定义limittg：判断怪兽是否不属于龙族·机械族的「电子」怪兽，若是则不能作为融合素材。
function c5370235.limittg(e,c)
	return not (c:IsRace(RACE_DRAGON+RACE_MACHINE) and c:IsSetCard(0x93))
end
-- 定义fuslimit：融合素材限制仅适用于效果持有者控制的怪兽。
function c5370235.fuslimit(e,c,sumtype)
	if not c then return false end
	return c:IsControler(e:GetHandlerPlayer())
end
-- 定义mttg：判断怪兽是否满足从墓地除外的条件（是怪兽且可除外）。
function c5370235.mttg(e,c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
-- 定义tgfilter：筛选卡组中属于「电子暗黑」字段、自己墓地没有同名卡且能送去墓地的怪兽。
function c5370235.tgfilter(c,tp)
	return c:IsSetCard(0x4093) and c:IsType(TYPE_MONSTER)
		-- 补充条件：该「电子暗黑」怪兽的同名卡不在自己墓地，且可以被送去墓地。
		and not Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,c:GetCode()) and c:IsAbleToGrave()
end
-- 定义tgtg，作为效果②的发动目标：检查卡组中是否有符合条件的「电子暗黑」怪兽，并设置操作信息。
function c5370235.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 目标检查阶段：确认卡组中存在符合条件的「电子暗黑」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c5370235.tgfilter,tp,LOCATION_DECK,0,1,nil,tp) end
	-- 设置操作信息：本次效果涉及从卡组将1张怪兽送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果②处理：从卡组选择1张符合条件的「电子暗黑」怪兽送去墓地。
function c5370235.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，要求玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组中选择1张符合条件的「电子暗黑」怪兽。
	local g=Duel.SelectMatchingCard(tp,c5370235.tgfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
