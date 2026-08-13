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
	-- 设定特殊召唤条件的判定函数为恒假，即这张卡无论如何都不能特殊召唤
	e0:SetValue(aux.FALSE)
	c:RegisterEffect(e0)
	-- 为这张卡添加灵魂怪兽通用的结束阶段回到手卡效果：召唤成功或反转的回合的结束阶段回到手卡（对应效果②）
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
-- 祭品候选的过滤函数：通常召唤（含上级召唤、二重怪兽的再度召唤）出场的怪兽
function c78098950.otfilter(c)
	return c:IsSummonType(SUMMON_TYPE_NORMAL) or c:IsSummonType(SUMMON_TYPE_ADVANCE) or c:IsSummonType(SUMMON_TYPE_DUAL)
end
-- 上级召唤手续的适用条件：这张卡等级在7以上、需要祭品数量不超过1，且双方场上存在可作祭品的通常召唤的怪兽
function c78098950.otcon(e,c,minc)
	if c==nil then return true end
	-- 检索双方怪兽区域中通常召唤出场的怪兽，作为可选的祭品候选
	local mg=Duel.GetMatchingGroup(c78098950.otfilter,0,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 条件判定：这张卡为7星以上、所需祭品不超过1只，且场上确实存在1只可用于解放的通常召唤的怪兽
	return c:IsLevelAbove(7) and minc<=1 and Duel.CheckTribute(c,1,1,mg)
end
-- 上级召唤手续的处理：让玩家从双方场上选1只通常召唤的怪兽作为祭品并将其解放，以此代替通常所需的祭品数量
function c78098950.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 检索双方怪兽区域中通常召唤出场的怪兽，作为祭品候选
	local mg=Duel.GetMatchingGroup(c78098950.otfilter,0,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 让玩家从候选中选择1只通常召唤的怪兽作为这张卡上级召唤的祭品
	local sg=Duel.SelectTribute(tp,c,1,1,mg)
	c:SetMaterial(sg)
	-- 以召唤手续（素材）的原因将选出的1只怪兽解放
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
-- 效果的对象检查函数：必发效果无需额外条件，直接返回真
function c78098950.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
-- ①效果的处理：让对方选择是否将自身场上的卡送去墓地，若送去则双方从卡组抽出那个数量的卡
function c78098950.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检索对方场上所有可以送去墓地的卡
	local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,1-tp,LOCATION_ONFIELD,0,nil)
	-- 判断对方场上存在可送去墓地的卡，且双方玩家都可以抽卡
	if #g>0 and Duel.IsPlayerCanDraw(tp) and Duel.IsPlayerCanDraw(1-tp)
		-- 询问对方是否选自身场上的卡送去墓地，对方选择是才继续处理
		and Duel.SelectYesNo(1-tp,aux.Stringid(78098950,2)) then  --"是否选场上的卡送去墓地？"
		-- 向对方发出提示：请选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local tg=g:Select(1-tp,1,#g,nil)
		-- 若对方选了卡且那些卡被效果实际送去了墓地（至少有1张在墓地），则进入抽卡处理
		if #tg>0 and Duel.SendtoGrave(tg,REASON_EFFECT)>0 and tg:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE) then
			-- 自己从卡组抽出与对方送去墓地的卡相同数量的卡
			Duel.Draw(tp,#tg,REASON_EFFECT)
			-- 对方从卡组抽出与送去墓地的卡相同数量的卡
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
	-- 把这个结束阶段触发的一次性持续效果注册为全局效果
	Duel.RegisterEffect(e1,tp)
end
-- 结束阶段的处理：将双方场上·墓地以及除外中的卡全部回到持有者卡组
function c78098950.todop(e,tp,eg,ep,ev,re,r,rp)
	-- 检索双方场上·墓地·除外中所有可以回到卡组的卡（并排除受王家长眠之谷影响的卡）
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(Card.IsAbleToDeck),tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,nil)
	if #g==0 then return end
	-- 显示「刀皇-都牟羽沓薙」的卡片动画，提示这是不入连锁的规则处理
	Duel.Hint(HINT_CARD,0,78098950)
	-- 把双方的场上·墓地的卡以及除外中的卡全部回到持有者卡组并洗切卡组
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
