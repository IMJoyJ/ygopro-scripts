--凍てつく眼光のメデューサ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡从手卡丢弃才能发动。把1张「活死人的呼声」或者有那个卡名记述的魔法·陷阱卡从卡组加入手卡。
-- ②：这张卡特殊召唤的场合，以对方场上1只攻击表示怪兽为对象才能发动。那只表侧表示怪兽不能攻击，效果无效化，不能作为融合·同调·超量·连接召唤的素材。
local s,id,o=GetID()
-- 初始化卡片效果：注册①效果（手卡起动，1回合1次，检索「活死人的呼声」相关卡加入手卡）和②效果（特殊召唤成功的场合诱发，取对象，1回合1次，使对方怪兽不能攻击、效果无效化、不能作为特殊召唤素材）
function s.initial_effect(c)
	-- 记录这张卡的效果文本上记述着「活死人的呼声」（卡号97077563）这一卡名，供记述检测使用
	aux.AddCodeList(c,97077563)
	-- ①：把这张卡从手卡丢弃才能发动。把1张「活死人的呼声」或者有那个卡名记述的魔法·陷阱卡从卡组加入手卡。
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
	-- ②：这张卡特殊召唤的场合，以对方场上1只攻击表示怪兽为对象才能发动。那只表侧表示怪兽不能攻击，效果无效化，不能作为融合·同调·超量·连接召唤的素材。
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
-- 代价函数：发动确认阶段检查这张卡能否从手卡丢弃，处理时将这张卡从手卡丢弃作为发动代价
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 把这张卡以代价·丢弃的原因送去墓地（即从手卡丢弃作为代价）
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 检索过滤函数：筛选「活死人的呼声」本身、或记述了那个卡名的魔法·陷阱卡，且该卡能够加入手卡
function s.filter(c)
	-- 判断该卡是否为「活死人的呼声」（卡号97077563），或效果文本上记述了那个卡名的魔法·陷阱卡
	return (c:IsCode(97077563) or (aux.IsCodeListed(c,97077563) and c:IsType(TYPE_SPELL+TYPE_TRAP)))
		and c:IsAbleToHand()
end
-- 目标函数：确认卡组存在满足检索条件的卡，并设置「从卡组把1张卡加入手卡」的操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件：确认自己卡组至少存在1张满足检索条件（「活死人的呼声」或记述该卡名的魔法·陷阱卡）的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：效果处理时将从卡组把1张卡加入手卡（CATEGORY_TOHAND）
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：让自己玩家从卡组选择1张满足条件的卡加入手卡，并将该卡展示给对方确认
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 向发动玩家发送选择提示：请选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让自己玩家从自己卡组选择1张满足检索条件的卡
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 把选择的卡以效果处理的原因加入持有者手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方玩家确认
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 对象过滤函数：表侧表示的攻击表示怪兽
function s.tgfilter(c)
	return c:IsFaceup() and c:IsAttackPos()
end
-- 目标函数：确认对方场上存在可成为对象的表侧攻击表示怪兽，选择1只为对象，并设置效果无效化的操作信息
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.tgfilter(chkc) end
	-- 发动条件：确认对方怪兽区域存在至少1只可作为效果对象的表侧攻击表示怪兽
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向发动玩家发送选择提示：请选择要无效的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择对方场上1只表侧攻击表示怪兽作为当前效果的对象
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：效果处理时将把对象怪兽的效果无效化（CATEGORY_DISABLE）
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 效果处理：使对象怪兽不能攻击、效果无效化，并且不能作为融合·同调·超量·连接召唤的素材
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得当前连锁所取的那1只对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() then
		-- 那只表侧表示怪兽不能攻击
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,2))  --"「冻结眼光美杜莎」效果适用中"
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 将与对象怪兽有关的连锁全部无效化（变成里侧表示时重置该限制）
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
		-- 手动刷新场上卡片受影响的无效状态，使无效化立即生效
		Duel.AdjustInstantly()
		if not tc:IsImmuneToEffect(e) then
			-- 不能作为融合·同调·超量·连接召唤的素材
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
-- 融合素材限制函数：仅在以融合召唤方式使用素材时适用限制（即该卡不能作为融合召唤的素材）
function s.fuslimit(e,c,sumtype)
	return sumtype==SUMMON_TYPE_FUSION
end
