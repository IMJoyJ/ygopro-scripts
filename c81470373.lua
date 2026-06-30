--BF－毒風のシムーン
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：自己场上没有怪兽存在的场合，从手卡把这张卡以外的1只「黑羽」怪兽除外才能发动。从卡组选1张「黑旋风」在自己的魔法与陷阱区域表侧表示放置。那之后，手卡的这张卡不用解放作召唤或送去墓地。这个效果放置的「黑旋风」在结束阶段送去墓地，自己受到1000伤害。这个效果的发动后，直到回合结束时自己不是暗属性怪兽不能从额外卡组特殊召唤。
local s,id,o=GetID()
-- 注册手牌发动自身的效果，包含放置「黑旋风」、召唤自身或送去墓地等处理，同时注册不需要解放通常召唤的效果
function s.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：自己场上没有怪兽存在的场合，从手卡把这张卡以外的1只「黑羽」怪兽除外才能发动。从卡组选1张「黑旋风」在自己的魔法与陷阱区域表侧表示放置。那之后，手卡的这张卡不用解放作召唤或送去墓地。这个效果放置的「黑旋风」在结束阶段送去墓地，自己受到1000伤害。这个效果的发动后，直到回合结束时自己不是暗属性怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SUMMON+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.sumcon)
	e1:SetCost(s.sumcost)
	e1:SetTarget(s.sumtg)
	e1:SetOperation(s.sumop)
	c:RegisterEffect(e1)
	-- 手卡的这张卡不用解放作召唤
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SUMMON_PROC)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.ntcon)
	e2:SetValue(SUMMON_TYPE_NORMAL)
	c:RegisterEffect(e2)
	e1:SetLabelObject(e2)
end
-- 检测手卡中这张卡是否可以直接不用解放通常召唤
function s.ntcon(e,c,minc)
	if c==nil then return true end
	-- 判断是否不需要解放（0祭品）且满足通常召唤的条件
	return minc==0 and Duel.CheckTribute(c,0)
end
-- 检测起动效果发动条件：自己场上没有怪兽存在
function s.sumcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上的怪兽数量是否为0
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 过滤出可以作为发动代价除外的除这张卡以外的手牌中的「黑羽」怪兽
function s.cfilter(c)
	return c:IsSetCard(0x33) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 处理效果发动的代价，从手牌将1只黑羽怪兽除外
function s.sumcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在效果发动时进行代价检测，判断手牌中是否存在可作为代价除外的「黑羽」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,c) end
	-- 提示玩家选择要作为代价除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择手牌中1张符合代价条件的「黑羽」怪兽
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,c)
	-- 将选中的卡片作为发动代价正面除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤出卡组中能够放置在场上的「黑旋风」
function s.acfilter(c,tp)
	return c:IsCode(91351370) and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- 处理效果发动时的目标检测，确认魔法与陷阱区域有空位，且卡组存在「黑旋风」，并确认手牌的这张卡可召唤或送去墓地
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 判断自己的魔法与陷阱区域是否没有空位
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0
			-- 或者检测卡组中是否存在能够被放置在魔法与陷阱区域的「黑旋风」
			or not Duel.IsExistingMatchingCard(s.acfilter,tp,LOCATION_DECK,0,1,nil,tp) then return false end
		return e:GetHandler():IsSummonable(true,e:GetLabelObject()) or e:GetHandler():IsAbleToGrave()
	end
end
-- 处理效果的发动结果：限制非暗属性从额外特殊召唤，将「黑旋风」放置在场上并注册结束阶段送去墓地和受到伤害的效果，然后根据玩家选择将手牌的这张卡召唤或送去墓地
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 这个效果的发动后，直到回合结束时自己不是暗属性怪兽不能从额外卡组特殊召唤。①：自己场上没有怪兽存在的场合，从手卡把这张卡以外的1只「黑羽」怪兽除外才能发动。从卡组选1张「黑旋风」在自己的魔法与陷阱区域表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 为玩家注册只能特殊召唤暗属性怪兽的全局限制效果
	Duel.RegisterEffect(e1,tp)
	-- 检测自己的魔法与陷阱区域是否已没有空位，若无则结束效果处理
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 提示玩家选择要放置在场上的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从卡组中选择1张能够被放置的「黑旋风」
	local tc=Duel.SelectMatchingCard(tp,s.acfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	-- 将选择的「黑旋风」表侧表示移动并放置在自己的魔法与陷阱区域
	if tc and Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
		-- 这个效果放置的「黑旋风」在结束阶段送去墓地，自己受到1000伤害。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetRange(LOCATION_SZONE)
		e1:SetCountLimit(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetOperation(s.tgop)
		tc:RegisterEffect(e1)
		if not c:IsRelateToEffect(e) then return end
		local se=e:GetLabelObject()
		if c:IsSummonable(true,se)
			-- 如果这张卡可以被召唤且玩家选择通常召唤
			and (not c:IsAbleToGrave() or Duel.SelectOption(tp,1151,1191)==0) then
			-- 中断效果处理，使后续的通常召唤处理不视为与前面的效果同时处理
			Duel.BreakEffect()
			-- 忽略每回合的通常召唤次数限制，使用该卡注册的不需解放召唤的效果通常召唤这张卡
			Duel.Summon(tp,c,true,se)
		else
			-- 中断效果处理，使后续的送去墓地处理不视为与前面的效果同时处理
			Duel.BreakEffect()
			-- 将手牌的这张卡送去墓地
			Duel.SendtoGrave(c,REASON_EFFECT)
		end
	end
end
-- 限制玩家不能从额外卡组特殊召唤暗属性以外的怪兽
function s.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_DARK) and c:IsLocation(LOCATION_EXTRA)
end
-- 处理在结束阶段将放置的「黑旋风」送去墓地并给与玩家伤害的具体操作
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 向双方玩家展示该卡片发动效果的动画
	Duel.Hint(HINT_CARD,0,id)
	local c=e:GetHandler()
	-- 将该卡送去墓地，并判断是否成功送去墓地
	if Duel.SendtoGrave(c,REASON_EFFECT)~=0 then
		-- 给与玩家1000点的伤害
		Duel.Damage(tp,1000,REASON_EFFECT)
	end
end
