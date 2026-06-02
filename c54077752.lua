--Stare of the Snake Hair
-- 效果：
-- 可以把这张卡丢弃；从卡组把1张「活死人的呼声」或者有那个卡名记述的魔法·陷阱卡加入手卡。
-- 这张卡特殊召唤的场合：可以以对方场上1只表侧攻击表示怪兽为对象；那只表侧表示怪兽不能攻击，效果无效化，不能作为融合·同调·超量·连接召唤的素材。
-- 「美杜莎的凝视」的每个效果1回合各能使用1次。
local s,id,o=GetID()
-- 注册卡片的效果：①手牌起动检索卡片效果，②特殊召唤成功时诱发取对象限制敌方表侧攻击表示怪兽、使其不能攻击、效果无效且不能作为特殊召唤素材的效果。
function s.initial_effect(c)
	-- 在当前卡片的数据中，注册其效果文本中记载了「活死人的呼声」（97077563）的事实。
	aux.AddCodeList(c,97077563)
	-- 可以把这张卡丢弃；从卡组把1张「活死人的呼声」或者有那个卡名记述的魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- 这张卡特殊召唤的场合：可以以对方场上1只表侧攻击表示怪兽为对象；那只表侧表示怪兽不能攻击，效果无效化，不能作为融合·同调·超量·连接召唤的素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"效果无效"
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
end
-- 手牌检索效果的发动代价处理函数：确认当前卡片可以被丢弃，并以效果代价的名义将当前卡片送入墓地。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 以发动代价和丢弃原因为由，将当前卡片自身送入墓地。
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 定义检索过滤函数：过滤出属于「活死人的呼声」（97077563）或者文本记载了「活死人的呼声」的魔法·陷阱卡，且能够正常加入手牌的卡片。
function s.filter(c)
	-- 检索过滤的核心条件：目标卡片的卡号为「活死人的呼声」，或者其记载了「活死人的呼声」的代码且卡片类型为魔法或陷阱卡。
	return (c:IsCode(97077563) or (aux.IsCodeListed(c,97077563) and c:IsType(TYPE_SPELL+TYPE_TRAP)))
		and c:IsAbleToHand()
end
-- 手牌检索效果的发动准备和检测：确认卡组存在符合检索条件的卡片，并设置将卡片加入手牌的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 作为效果发动检测，确认卡组中是否至少存在1张符合检索条件的卡片。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：包含从卡组将1张卡加入手牌的分类，目标玩家为自己。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 手牌检索效果的实际处理过程：提示玩家，并让其从卡组中选择1张符合过滤条件的卡片加入手牌，然后向对方玩家展示该卡片进行确认。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送选择提示信息：请选择要加入手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张符合检索过滤条件的卡片。
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将玩家选中的卡片加入其手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示并确认加入手牌的卡片信息。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 定义对象怪兽过滤函数：过滤出在场上表侧表示且处于攻击表示的怪兽。
function s.tgfilter(c)
	return c:IsFaceup() and c:IsAttackPos()
end
-- 特召效果的对象选择处理函数：在 chkc 存在时执行合法性检查；发动时确认对方场上存在表侧攻击表示的怪兽，提示并选择其中1只作为对象，设置使怪兽效果无效的操作信息。
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.tgfilter(chkc) end
	-- 作为效果发动检测，确认对方场上是否至少存在1只表侧攻击表示的怪兽可以成为效果对象。
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家发送选择提示信息：请选择要无效的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 让玩家选择对方场上的1只符合过滤条件的怪兽作为效果的目标对象。
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：包含使该目标怪兽效果无效的分类。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 特召效果的实际处理过程：如果选中的怪兽仍在场上表侧表示，对其施加不能攻击的限制，无效化与其相关的连锁，并使该怪兽的效果和陷阱怪兽效果无效，再对其施加不能作为同调、融合、超量、连接素材的限制效果。
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取在当前连锁中绑定的第一个对象怪兽卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() then
		-- 那只表侧表示怪兽不能攻击
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,2))  --"「美杜莎的凝视」效果适用中"
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 使该目标对象怪兽在场上已发动的效果以及与其相关的效果连锁全部失效。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 效果无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetValue(RESET_TURN_SET)
		tc:RegisterEffect(e3)
		if tc:IsType(TYPE_TRAPMONSTER) then
			local e4=e2:Clone()
			e4:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			tc:RegisterEffect(e4)
		end
		-- 手动立即刷新并更新场上所有卡片受到当前无效效果影响的状态。
		Duel.AdjustInstantly()
		if not tc:IsImmuneToEffect(e) then
			-- 不能作为融合·同调·超量·连接召唤的素材。
			local e5=Effect.CreateEffect(c)
			e5:SetType(EFFECT_TYPE_SINGLE)
			e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
			e5:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
			e5:SetRange(LOCATION_MZONE)
			e5:SetReset(RESET_EVENT+RESETS_STANDARD)
			e5:SetValue(1)
			tc:RegisterEffect(e5)
			local e6=e5:Clone()
			e6:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
			e6:SetValue(s.fuslimit)
			tc:RegisterEffect(e6)
			local e7=e5:Clone()
			e7:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
			tc:RegisterEffect(e7)
			local e8=e5:Clone()
			e8:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
			tc:RegisterEffect(e8)
		end
	end
end
-- 定义融合素材限制判定规则：若当前进行的怪兽召唤类型为融合召唤，则返回限制成功以禁止该素材使用。
function s.fuslimit(e,c,sumtype)
	return sumtype==SUMMON_TYPE_FUSION
end
