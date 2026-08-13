--無敗将軍 フリード
-- 效果：
-- 只要这张卡在场上表侧表示存在，这张卡为对象的魔法卡的效果无效并破坏。只要这张卡在场上表侧表示存在，可以作为自己的抽卡阶段时进行通常抽卡的代替，从自己卡组把1只4星以下的战士族怪兽加入手卡。
function c49681811.initial_effect(c)
	-- 只要这张卡在场上表侧表示存在，这张卡为对象的魔法卡的效果无效
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
	e1:SetTarget(c49681811.distg)
	c:RegisterEffect(e1)
	-- 这张卡为对象的魔法卡的效果无效并破坏
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(c49681811.disop)
	c:RegisterEffect(e2)
	-- 并破坏
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SELF_DESTROY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
	e3:SetTarget(c49681811.distg)
	c:RegisterEffect(e3)
	-- 只要这张卡在场上表侧表示存在，可以作为自己的抽卡阶段时进行通常抽卡的代替，从自己卡组把1只4星以下的战士族怪兽加入手卡
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(49681811,0))  --"检索"
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PREDRAW)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c49681811.condition)
	e4:SetTarget(c49681811.target)
	e4:SetOperation(c49681811.operation)
	c:RegisterEffect(e4)
end
-- 判定候选魔陷是否为以这张卡为对象的魔法卡：必须是魔法卡，且其当前永续对象中包含本卡。
function c49681811.distg(e,c)
	if not c:IsType(TYPE_SPELL) or c:GetCardTargetCount()==0 then return false end
	return c:GetCardTarget():IsContains(e:GetHandler())
end
-- 连锁处理时，若当前发动的效果是取对象的魔法卡、本卡与该效果关联，且该效果的对象包含本卡，则无效该连锁并将其效果无效，若该魔法卡仍与连锁关联则将其破坏。
function c49681811.disop(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsActiveType(TYPE_SPELL) then return end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return end
	if not e:GetHandler():IsRelateToEffect(re) then return end
	-- 取得当前连锁的效果对象卡组，用于确认本卡是否被该魔法卡选为对象。
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or g:GetCount()==0 then return end
	if g:IsContains(e:GetHandler()) then
		-- 若成功将当前连锁的魔法卡效果无效，且那张魔法卡仍与该效果关联，则继续执行破坏处理。
		if Duel.NegateEffect(ev,true) and re:GetHandler():IsRelateToEffect(re) then
			-- 以效果原因破坏那张发动中的魔法卡。
			Duel.Destroy(re:GetHandler(),REASON_EFFECT)
		end
	end
end
-- 该效果的发动条件：仅当效果持有者同时也是当前回合玩家时（即自己的抽卡阶段）才满足。
function c49681811.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否为效果持有者，即是否为自己的回合。
	return tp==Duel.GetTurnPlayer()
end
-- 检索筛选条件：从卡组选择1只等级4以下、种族为战士族、且能够加入手卡的怪兽。
function c49681811.filter(c)
	return c:IsLevelBelow(4) and c:IsRace(RACE_WARRIOR) and c:IsAbleToHand()
end
-- 发动时的目标处理：检查自己是否还能进行通常抽卡且卡组中存在符合条件的战士族怪兽；随后设置操作信息，表示为从卡组将1张卡加入手卡。
function c49681811.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若为发动时点检查（chk==0），则确认还可进行通常抽卡且卡组中存在可检索的战士族怪兽，否则不能发动。
	if chk==0 then return aux.IsPlayerCanNormalDraw(tp) and Duel.IsExistingMatchingCard(c49681811.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本次效果的操作信息：从卡组将1张卡加入手卡（不取对象，数量1，位置为卡组）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end
-- 效果处理：先确认仍可通常抽卡并放弃本次通常抽卡；若本卡仍在场上表侧表示，则从自己卡组选1只符合条件的战士族怪兽加入手卡，并向对方展示。
function c49681811.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 若玩家当前已不能进行通常抽卡（例如本回合已抽过卡或受其他限制），则终止效果处理。
	if not aux.IsPlayerCanNormalDraw(tp) then return end
	-- 放弃本次通常抽卡：将本回合的通常抽卡次数设为0并注册限制标记，作为代替抽卡的处理。
	aux.GiveUpNormalDraw(e,tp)
	if not e:GetHandler():IsRelateToEffect(e) or e:GetHandler():IsFacedown() then return end
	-- 显示选择提示‘请选择要加入手牌的卡’，供玩家从卡组中选择符合条件的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己卡组选择1张满足筛选条件的战士族怪兽（等级4以下、战士族、可加入手卡）。
	local g=Duel.SelectMatchingCard(tp,c49681811.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()~=0 then
		-- 将选择的那张卡加入其持有者的手卡（此处即为自己的手卡），原因是效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认所加入手卡的卡片，确保对方可以查看检索到的怪兽。
		Duel.ConfirmCards(1-tp,g)
	end
end
