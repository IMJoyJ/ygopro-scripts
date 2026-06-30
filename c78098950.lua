--刀皇－都牟羽沓薙
-- 效果：
-- 这张卡不能特殊召唤。这张卡可以把1只通常召唤的怪兽解放作上级召唤。
-- ①：这张卡召唤·反转的场合发动。对方可以选自身场上的卡任意数量送去墓地。那个场合，双方从卡组抽出那个数量。这个效果发动的回合的结束阶段，双方的场上·墓地的卡以及除外中的卡全部回到持有者卡组。
-- ②：这张卡召唤·反转的回合的结束阶段发动。这张卡回到持有者手卡。
function c78098950.initial_effect(c)
	-- 这张卡不能特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该怪兽不能被任何效果特殊召唤
	e0:SetValue(aux.FALSE)
	c:RegisterEffect(e0)
	-- 为卡片注册灵魂怪兽特有的回合结束阶段回到手卡的效果
	aux.EnableSpiritReturn(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP)
	-- 这张卡可以把1只通常召唤的怪兽解放作上级召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(78098950,0))  --"把1只通常召唤的怪兽解放作上级召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c78098950.otcon)
	e1:SetOperation(c78098950.otop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_PROC)
	c:RegisterEffect(e2)
	-- ①：这张卡召唤·反转的场合发动。对方可以选自身场上的卡任意数量送去墓地。那个场合，双方从卡组抽出那个数量。这个效果发动的回合的结束阶段，双方的场上·墓地的卡以及除外中的卡全部回到持有者卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(78098950,1))
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_TODECK+CATEGORY_GRAVE_ACTION)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(c78098950.tg)
	e2:SetOperation(c78098950.op)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_FLIP)
	c:RegisterEffect(e3)
end
-- 过滤条件：判断怪兽是否为通常召唤（包括上级召唤、再度召唤）的怪兽
function c78098950.otfilter(c)
	return c:IsSummonType(SUMMON_TYPE_NORMAL) or c:IsSummonType(SUMMON_TYPE_ADVANCE) or c:IsSummonType(SUMMON_TYPE_DUAL)
end
-- 判断是否满足特殊上级召唤条件：自身等级在7星以上，所需祭品数量最少为1，且场上存在满足过滤条件且数量足够的祭品怪兽
function c78098950.otcon(e,c,minc)
	if c==nil then return true end
	-- 获取双方场上所有通过通常召唤登场的怪兽组
	local mg=Duel.GetMatchingGroup(c78098950.otfilter,0,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 检查自身等级是否在7星以上、最少祭品数不大于1且存在可用于召唤的通常召唤怪兽
	return c:IsLevelAbove(7) and minc<=1 and Duel.CheckTribute(c,1,1,mg)
end
-- 特殊上级召唤的操作：获取通常召唤过的怪兽并由玩家选择其中1只，作为上级召唤的素材进行解放
function c78098950.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取双方场上所有通过通常召唤登场的怪兽组
	local mg=Duel.GetMatchingGroup(c78098950.otfilter,0,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 玩家选择1只通常召唤登场的怪兽作为祭品
	local sg=Duel.SelectTribute(tp,c,1,1,mg)
	c:SetMaterial(sg)
	-- 将所选的怪兽作为召唤素材解放送去墓地
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
-- 效果发动的目标检查：由于是必定发动的效果且不在此阶段选择目标，因此直接允许发动
function c78098950.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
-- 效果处理的操作：对方可选择场上卡片送去墓地，并使双方各自抽等量的卡，随后注册在此回合结束阶段使全场·墓地·除外卡片回到卡组的延迟效果
function c78098950.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方场上所有可以送去墓地的卡片组
	local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,1-tp,LOCATION_ONFIELD,0,nil)
	-- 检查对方场上是否有卡可以送去墓地，且双方玩家当前均是否可以抽卡
	if #g>0 and Duel.IsPlayerCanDraw(tp) and Duel.IsPlayerCanDraw(1-tp)
		-- 询问对方玩家是否选择将自身场上的卡送去墓地
		and Duel.SelectYesNo(1-tp,aux.Stringid(78098950,2)) then  --"是否选场上的卡送去墓地？"
		-- 提示对方玩家选择要送去墓地的卡片
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local tg=g:Select(1-tp,1,#g,nil)
		-- 若对方选择了卡片，则将其送去墓地并判断是否有卡确实到达了墓地
		if #tg>0 and Duel.SendtoGrave(tg,REASON_EFFECT)>0 and tg:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE) then
			-- 自己从卡组抽出与送墓卡片数量相同数量的卡
			Duel.Draw(tp,#tg,REASON_EFFECT)
			-- 对方从卡组抽出与送墓卡片数量相同数量 of 卡
			Duel.Draw(1-tp,#tg,REASON_EFFECT)
		end
	end
	-- 这个效果发动的回合的结束阶段，双方的场上·墓地的卡以及除外中的卡全部回到持有者卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetOperation(c78098950.todop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册结束阶段回卡组的延迟生效效果到全局环境中
	Duel.RegisterEffect(e1,tp)
end
-- 结束阶段回卡组的具体操作：收集双方场上、墓地和除外状态下的所有能回到卡组的卡，并将其全部返回卡组并洗卡
function c78098950.todop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方场上、墓地以及被除外卡片中所有不受王谷影响且能回到卡组的卡片组
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(Card.IsAbleToDeck),tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,nil)
	if #g==0 then return end
	-- 在场上展示卡片发动效果的动画提示
	Duel.Hint(HINT_CARD,0,78098950)
	-- 将符合条件的所有卡片全部送回持有者卡组并洗牌
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
