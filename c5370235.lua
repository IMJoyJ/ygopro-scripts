--サイバー・ダーク・キメラ
--not fully implemented
-- 效果：
-- （注：暂时无法正常使用）
-- 
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从手卡丢弃1张魔法·陷阱卡才能发动。从卡组把1张「力量结合」加入手卡。这个回合，自己不是龙族·机械族的「电子」怪兽不能作为融合素材，自己把怪兽融合召唤的场合只有1次，也能把自己墓地的怪兽除外作为融合素材。
-- ②：这张卡被送去墓地的场合才能发动。同名卡不在自己墓地存在的1只「电子暗黑」怪兽从卡组送去墓地。
function c5370235.initial_effect(c)
	-- ①：从手卡丢弃1张魔法·陷阱卡才能发动。从卡组把1张「力量结合」加入手卡。这个回合，自己不是龙族·机械族的「电子」怪兽不能作为融合素材，自己把怪兽融合召唤的场合只有1次，也能把自己墓地的怪兽除外作为融合素材。
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
	-- 检查是否已初始化融合素材的hack功能
	if not aux.fus_mat_hack_check then
		-- 标记融合素材的hack功能已初始化
		aux.fus_mat_hack_check=true
		-- 定义用于过滤额外卡组中融合素材的过滤函数
		function aux.fus_mat_hack_exmat_filter(c)
			return c:IsHasEffect(EFFECT_EXTRA_FUSION_MATERIAL,c:GetControler())
		end
		-- 保存原始的Duel.GetFusionMaterial函数
		_GetFusionMaterial=Duel.GetFusionMaterial
		-- 重写Duel.GetFusionMaterial函数以支持额外卡组中的融合素材
		function Duel.GetFusionMaterial(tp,loc)
			if loc==nil then loc=LOCATION_HAND+LOCATION_MZONE end
			local g=_GetFusionMaterial(tp,loc)
			-- 获取玩家额外卡组中满足融合素材条件的卡
			local exg=Duel.GetMatchingGroup(aux.fus_mat_hack_exmat_filter,tp,LOCATION_EXTRA,0,nil)
			return g+exg
		end
		-- 保存原始的Duel.SendtoGrave函数
		_SendtoGrave=Duel.SendtoGrave
		-- 重写Duel.SendtoGrave函数以处理融合素材的特殊处理
		function Duel.SendtoGrave(tg,reason)
			-- 判断是否为融合相关的送去墓地操作且目标为卡组
			if reason~=REASON_EFFECT+REASON_MATERIAL+REASON_FUSION or aux.GetValueType(tg)~="Group" then
				return _SendtoGrave(tg,reason)
			end
			-- 获取满足融合素材条件的额外卡组中的卡
			local tc=tg:Filter(Card.IsLocation,nil,LOCATION_EXTRA+LOCATION_GRAVE):Filter(aux.fus_mat_hack_exmat_filter,nil):GetFirst()
			if tc then
				local te=tc:IsHasEffect(EFFECT_EXTRA_FUSION_MATERIAL,tc:GetControler())
				te:UseCountLimit(tc:GetControler())
			end
			local rg=tg:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
			tg:Sub(rg)
			local ct1=_SendtoGrave(tg,reason)
			-- 将额外卡组中的卡以除外形式处理
			local ct2=Duel.Remove(rg,POS_FACEUP,reason)
			return ct1+ct2
		end
	end
end
-- 定义用于丢弃手卡中魔法·陷阱卡的过滤函数
function c5370235.costfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsDiscardable()
end
-- 检查是否有满足条件的魔法·陷阱卡并将其丢弃
function c5370235.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c5370235.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 丢弃一张魔法·陷阱卡
	Duel.DiscardHand(tp,c5370235.costfilter,1,1,REASON_COST+REASON_DISCARD,nil)
end
-- 定义用于检索「力量结合」的过滤函数
function c5370235.thfilter(c)
	return c:IsCode(37630732) and c:IsAbleToHand()
end
-- 检查是否有满足条件的「力量结合」并设置操作信息
function c5370235.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的「力量结合」
	if chk==0 then return Duel.IsExistingMatchingCard(c5370235.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为检索「力量结合」
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索「力量结合」并设置融合素材限制效果
function c5370235.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的「力量结合」
	local g=Duel.SelectMatchingCard(tp,c5370235.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的「力量结合」加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
	-- 设置效果：这个回合，自己不是龙族·机械族的「电子」怪兽不能作为融合素材
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(0xff,0xff)
	e1:SetTarget(c5370235.limittg)
	e1:SetValue(c5370235.fuslimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册融合素材限制效果
	Duel.RegisterEffect(e1,tp)
	-- 设置效果：自己把怪兽融合召唤的场合只有1次，也能把自己墓地的怪兽除外作为融合素材
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetDescription(aux.Stringid(5370235,2))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_EXTRA_FUSION_MATERIAL)
	e2:SetTargetRange(LOCATION_GRAVE,0)
	e2:SetTarget(c5370235.mttg)
	e2:SetValue(1)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册额外融合素材效果
	Duel.RegisterEffect(e2,tp)
end
-- 定义融合素材限制的过滤函数
function c5370235.limittg(e,c)
	return not (c:IsRace(RACE_DRAGON+RACE_MACHINE) and c:IsSetCard(0x93))
end
-- 定义融合素材限制的值函数
function c5370235.fuslimit(e,c,sumtype)
	if not c then return false end
	return c:IsControler(e:GetHandlerPlayer())
end
-- 定义额外融合素材的过滤函数
function c5370235.mttg(e,c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
-- 定义用于检索「电子暗黑」怪兽的过滤函数
function c5370235.tgfilter(c,tp)
	return c:IsSetCard(0x4093) and c:IsType(TYPE_MONSTER)
		-- 检查同名卡不在自己墓地
		and not Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,c:GetCode()) and c:IsAbleToGrave()
end
-- 检查是否有满足条件的「电子暗黑」怪兽并设置操作信息
function c5370235.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的「电子暗黑」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c5370235.tgfilter,tp,LOCATION_DECK,0,1,nil,tp) end
	-- 设置操作信息为检索「电子暗黑」怪兽
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 执行检索「电子暗黑」怪兽
function c5370235.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的「电子暗黑」怪兽
	local g=Duel.SelectMatchingCard(tp,c5370235.tgfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
	if g:GetCount()>0 then
		-- 将选中的「电子暗黑」怪兽送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
