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
	-- 设置特殊召唤的条件为始终返回假（即不能特殊召唤）
	e0:SetValue(aux.FALSE)
	c:RegisterEffect(e0)
	-- 注册灵魂怪兽在召唤或反转的回合结束阶段回到持有者手卡的效果
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
	-- ①：这张卡召唤·反转的场合发动。对方可以选自身场上的卡任意数量送去墓地。那个场合，双方从卡组抽出那个数量。
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
-- 过滤通常召唤、上级召唤或再度召唤（二重）的怪兽
function c78098950.otfilter(c)
	return c:IsSummonType(SUMMON_TYPE_NORMAL) or c:IsSummonType(SUMMON_TYPE_ADVANCE) or c:IsSummonType(SUMMON_TYPE_DUAL)
end
-- 上级召唤的替代解放条件判定
function c78098950.otcon(e,c,minc)
	if c==nil then return true end
	-- 获取双方场上所有满足通常召唤条件的怪兽作为解放素材组
	local mg=Duel.GetMatchingGroup(c78098950.otfilter,0,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 判定自身等级在7星以上、最少解放数量不大于1，且场上存在1个满足条件的解放素材
	return c:IsLevelAbove(7) and minc<=1 and Duel.CheckTribute(c,1,1,mg)
end
-- 执行替代解放上级召唤的操作
function c78098950.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取双方场上所有满足通常召唤条件的怪兽作为解放素材组
	local mg=Duel.GetMatchingGroup(c78098950.otfilter,0,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 让召唤玩家选择1只满足条件的怪兽作为解放祭品
	local sg=Duel.SelectTribute(tp,c,1,1,mg)
	c:SetMaterial(sg)
	-- 解放选中的怪兽作为上级召唤的素材
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
-- 召唤·反转时发动效果的靶向/发动条件判定（必发效果，直接返回true）
function c78098950.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
-- 执行召唤·反转时发动的效果：对方选卡送墓并抽卡，并注册回合结束阶段洗回卡组的效果
function c78098950.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方场上可以送去墓地的卡片组
	local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,1-tp,LOCATION_ONFIELD,0,nil)
	-- 判定对方场上有卡可送墓，且双方玩家当前均可抽卡
	if #g>0 and Duel.IsPlayerCanDraw(tp) and Duel.IsPlayerCanDraw(1-tp)
		-- 询问对方玩家是否选择将自身场上的卡送去墓地
		and Duel.SelectYesNo(1-tp,aux.Stringid(78098950,2)) then  --"是否选场上的卡送去墓地？"
		-- 给对方玩家发送选择送去墓地的卡片的提示信息
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local tg=g:Select(1-tp,1,#g,nil)
		-- 将对方选中的卡送去墓地，并确认其中至少有1张卡成功进入墓地
		if #tg>0 and Duel.SendtoGrave(tg,REASON_EFFECT) and tg:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE) then
			-- 让发动效果的玩家从卡组抽出与送墓数量相同的卡
			Duel.Draw(tp,#tg,REASON_EFFECT)
			-- 让对方玩家从卡组抽出与送墓数量相同的卡
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
	-- 在全局环境中注册该回合结束阶段触发的延迟效果
	Duel.RegisterEffect(e1,tp)
end
-- 结束阶段将双方场上、墓地、除外的卡全部回到持有者卡组的具体处理
function c78098950.todop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方场上、墓地、除外中所有可以回到卡组且不受王家之谷影响的卡片
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(Card.IsAbleToDeck),tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,nil)
	if #g==0 then return end
	-- 在屏幕上显示卡片发动动画以提示该效果正在处理
	Duel.Hint(HINT_CARD,0,78098950)
	-- 将所有获取到的卡片送回持有者的卡组并洗牌
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
