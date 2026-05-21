--氷結界の鏡魔師
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把自己场上1只其他的效果怪兽解放才能发动。在自己场上把最多3只「冰结界衍生物」（水族·水·1星·攻/守0）特殊召唤，这张卡的等级上升那个数量的数值。这个回合，自己不是水属性同调怪兽不能从额外卡组特殊召唤。
-- ②：这张卡被送去墓地的场合才能发动。「冰结界的镜魔师」以外的自己的卡组·除外状态的1张「冰结界」卡加入手卡。
local s,id,o=GetID()
-- 注册卡片「冰结界的镜魔师」的两个效果（①效果：特殊召唤衍生物并上升等级；②效果：送墓检索「冰结界」卡）。
function s.initial_effect(c)
	-- ①：把自己场上1只其他的效果怪兽解放才能发动。在自己场上把最多3只「冰结界衍生物」（水族·水·1星·攻/守0）特殊召唤，这张卡的等级上升那个数量的数值。这个回合，自己不是水属性同调怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤衍生物"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡被送去墓地的场合才能发动。「冰结界的镜魔师」以外的自己的卡组·除外状态的1张「冰结界」卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"加入手卡"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上的效果怪兽，且该怪兽解放后能空出至少1个怪兽区域。
function s.rfilter(c,tp)
	-- 判断卡片是否为效果怪兽，且该怪兽解放后玩家场上是否有可用的怪兽区域。
	return c:IsType(TYPE_EFFECT) and Duel.GetMZoneCount(tp,c)>0
end
-- ①效果的发动代价（Cost）处理：检查并解放自己场上1只其他的效果怪兽。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在发动效果时，检查自己场上是否存在至少1只除自身以外、可解放且能腾出怪兽区域的效果怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,s.rfilter,1,c,tp) end
	-- 提示玩家选择要解放的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 让玩家选择1只除自身以外、满足过滤条件的可解放效果怪兽。
	local g=Duel.SelectReleaseGroup(tp,s.rfilter,1,1,c,tp)
	-- 将选中的怪兽作为发动代价（Cost）解放。
	Duel.Release(g,REASON_COST)
end
-- ①效果的发动条件与效果分类（Target）处理：检查是否能特殊召唤衍生物，并设置特殊召唤和衍生物生成的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动效果时，检查玩家是否能够特殊召唤「冰结界衍生物」（水族·水·1星·攻/守0）。
	if chk==0 then return Duel.IsPlayerCanSpecialSummonMonster(tp,9396663,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_AQUA,ATTRIBUTE_WATER) end
	-- 设置操作信息：此效果包含产生衍生物的操作。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息：此效果包含特殊召唤的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- ①效果的效果处理（Operation）：在自己场上特殊召唤最多3只「冰结界衍生物」，使这张卡等级上升对应数值，并适用“本回合不能从额外卡组特殊召唤水属性同调怪兽以外的怪兽”的限制。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取玩家场上可用的怪兽区域数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local ct=3
	-- 判断玩家场上是否有空位、特招数量是否大于0，且玩家是否能特殊召唤「冰结界衍生物」。
	if ft>0 and ct>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,9396663,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_AQUA,ATTRIBUTE_WATER) then
		local count=math.min(ft,ct)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then count=1 end
		if count>1 then
			local num={}
			local i=1
			while i<=count do
				num[i]=i
				i=i+1
			end
			-- 提示玩家选择要特殊召唤的衍生物数量。
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))  --"请选择要特殊召唤的衍生物数量"
			-- 让玩家宣言要特殊召唤的衍生物数量。
			count=Duel.AnnounceNumber(tp,table.unpack(num))
		end
		local lv=count
		repeat
			-- 在后台创建「冰结界衍生物」卡片数据。
			local token=Duel.CreateToken(tp,9396663)
			-- 将衍生物以表侧表示特殊召唤到场上（单步处理）。
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
			count=count-1
		until count==0
		-- 完成所有怪兽的特殊召唤处理。
		Duel.SpecialSummonComplete()
		if c:IsRelateToEffect(e) then
			-- 这张卡的等级上升那个数量的数值。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_LEVEL)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			e1:SetValue(lv)
			c:RegisterEffect(e1)
		end
	end
	-- 这个回合，自己不是水属性同调怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将“不能从额外卡组特殊召唤水属性同调怪兽以外的怪兽”的限制效果注册给玩家。
	Duel.RegisterEffect(e1,tp)
end
-- 限制条件：不能从额外卡组特殊召唤非水属性或非同调怪兽。
function s.splimit(e,c)
	return not (c:IsAttribute(ATTRIBUTE_WATER) and c:IsType(TYPE_SYNCHRO)) and c:IsLocation(LOCATION_EXTRA)
end
-- 过滤条件：卡组或除外状态的「冰结界」卡（不含「冰结界的镜魔师」），且能加入手卡。
function s.thfilter(c)
	return c:IsSetCard(0x2f) and c:IsAbleToHand() and not c:IsCode(id) and c:IsFaceupEx()
end
-- ②效果的发动条件与效果分类（Target）处理：检查卡组或除外状态是否存在可检索的「冰结界」卡，并设置检索和加入手卡的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动效果时，检查自己的卡组或除外状态是否存在至少1张满足条件的「冰结界」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,nil) end
	-- 设置操作信息：此效果包含从卡组或除外状态将1张卡加入手卡的操作。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_REMOVED)
end
-- ②效果的效果处理（Operation）：从卡组或除外状态选择1张「冰结界」卡加入手卡。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组或除外状态选择1张满足条件的「冰结界」卡。
	local tg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,1,nil)
	if #tg>0 then
		-- 将选中的卡加入玩家手卡。
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的卡片。
		Duel.ConfirmCards(1-tp,tg)
	end
end
