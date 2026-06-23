--ミニャーマドルチェ・ニャカロン
-- 效果：
-- 包含「魔偶甜点」怪兽的效果怪兽2只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡连接召唤的场合才能发动。从卡组把1张「魔偶甜点」卡加入手卡。
-- ②：以自己墓地1只怪兽为对象才能发动。从手卡把1只「魔偶甜点」怪兽特殊召唤，作为对象的怪兽回到卡组。这个效果的发动后，直到回合结束时自己不能把「魔偶甜点」怪兽以外的怪兽的效果发动。
local s,id,o=GetID()
-- 初始化效果函数，设置连接召唤手续、启用复活限制，并注册两个效果
function s.initial_effect(c)
	-- 为该卡添加连接召唤手续，要求连接素材中至少包含1只效果怪兽
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),2,99,s.lcheck)
	c:EnableReviveLimit()
	-- 注册效果①，发动条件为该卡连接召唤成功，效果为从卡组检索1张「魔偶甜点」卡加入手牌
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- 注册效果②，发动条件为以自己墓地1只怪兽为对象，效果为特殊召唤1只「魔偶甜点」怪兽并让对象怪兽返回卡组，且本回合不能发动非「魔偶甜点」怪兽的效果
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 连接召唤检查函数，确保连接素材中包含「魔偶甜点」卡组的怪兽
function s.lcheck(g)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0x71)
end
-- 效果①的发动条件，判断该卡是否为连接召唤成功
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 检索卡牌过滤函数，筛选「魔偶甜点」卡组且能加入手牌的卡
function s.thfilter(c)
	return c:IsSetCard(0x71) and c:IsAbleToHand()
end
-- 效果①的发动准备函数，检查是否满足发动条件并设置操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足效果①的发动条件，即卡组中是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果①的操作信息，表示将从卡组检索1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的发动处理函数，选择并执行检索操作
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡加入手牌
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方能看到被加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 特殊召唤卡牌过滤函数，筛选「魔偶甜点」卡组且能特殊召唤的怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x71) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 返回卡组卡牌过滤函数，筛选能返回卡组的怪兽
function s.tdfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 效果②的发动准备函数，检查是否满足发动条件并设置操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.tdfilter(chkc) end
	-- 检查是否满足效果②的发动条件，即场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否满足效果②的发动条件，即墓地是否有满足条件的怪兽
		and Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE,0,1,nil)
		-- 检查是否满足效果②的发动条件，即手牌是否有满足条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择满足条件的墓地怪兽作为对象
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果②的操作信息，表示将对象怪兽返回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
	-- 设置效果②的操作信息，表示将手牌中的怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果②的发动处理函数，执行特殊召唤和返回卡组操作，并设置后续限制
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否满足效果②的发动条件，即场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的手牌怪兽进行特殊召唤
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		-- 执行特殊召唤操作并判断是否成功
		if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
			-- 获取当前连锁的目标卡
			local tc=Duel.GetFirstTarget()
			if tc:IsRelateToEffect(e) then
				-- 将目标卡返回卡组并洗牌
				Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
			end
		end
	end
	-- 注册效果②的后续限制效果，禁止发动非「魔偶甜点」怪兽的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册该限制效果到玩家
	Duel.RegisterEffect(e1,tp)
end
-- 限制效果的判断函数，判断是否为非「魔偶甜点」怪兽的效果
function s.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER) and not re:GetHandler():IsSetCard(0x71)
end
