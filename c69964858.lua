--ウィッチクラフト・ピューピルズ
local s,id,o=GetID()
-- 初始化效果，设置融合召唤条件并注册两个效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，需要满足条件的怪兽各1只作为融合素材
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x128),s.matfilter,true)
	-- 效果1：可以在主要阶段或战斗阶段发动，检索一张魔法卡或让对方确认手牌中的一张魔法/速攻卡并使用其效果
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END+TIMING_BATTLE_START+TIMING_BATTLE_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.cecon)
	e1:SetCost(s.cecost)
	e1:SetTarget(s.cetg)
	e1:SetOperation(s.ceop)
	c:RegisterEffect(e1)
	-- 效果2：在结束阶段发动，将墓地里的一张witchcraft族卡送去墓地
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.tgcon)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
end
-- 融合素材过滤器，判断是否为魔法师族怪兽
function s.matfilter(c)
	return c:IsRace(RACE_SPELLCASTER)
end
-- 效果1的发动条件，判断是否为主阶段或战斗阶段
function s.cecon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为主阶段或战斗阶段
	return Duel.IsMainPhase() or Duel.IsBattlePhase()
end
-- 检索过滤器，判断是否为witchcraft族魔法卡且可加入手牌
function s.thfilter(c)
	return c:IsSetCard(0x128) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 确认过滤器，判断是否为witchcraft族魔法/速攻卡且未公开且存在可发动效果
function s.cpfilter(c)
	return c:IsSetCard(0x128) and (c:GetType()==TYPE_SPELL or c:IsType(TYPE_QUICKPLAY)) and not c:IsPublic()
		and c:CheckActivateEffect(true,true,false)~=nil
end
-- 效果1的费用支付函数，选择检索魔法卡或确认手牌中的一张魔法/速攻卡
function s.cecost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足检索条件的魔法卡
	local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	-- 检查手牌中是否存在满足确认条件的魔法/速攻卡
	local b2=Duel.IsExistingMatchingCard(s.cpfilter,tp,LOCATION_HAND,0,1,nil)
	if chk==0 then return b1 or b2 end
	-- 让玩家从选项中选择一个操作
	local op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,2),1},
			{b2,aux.Stringid(id,3),2})
	e:SetLabel(op)
	if op==2 then
		-- 提示玩家选择要给对方确认的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		-- 选择一张满足确认条件的手牌
		local g=Duel.SelectMatchingCard(tp,s.cpfilter,tp,LOCATION_HAND,0,1,1,nil)
		-- 向对方确认所选的卡
		Duel.ConfirmCards(1-tp,g)
		e:SetLabelObject(g:GetFirst())
		-- 将手牌洗切
		Duel.ShuffleHand(tp)
	end
end
-- 效果1的目标设定函数，根据选择的操作设置不同的处理方式
function s.cetg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 判断是否可以检索魔法卡或确认手牌中的魔法/速攻卡
		return Duel.IsExistingMatchingCard(s.cpfilter,tp,LOCATION_HAND,0,1,nil) or Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	end
	local cpel=0
	local op=e:GetLabel()
	if op==1 then
		e:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
		-- 设置操作信息为检索一张魔法卡并送入手牌
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	elseif op==2 then
		local te,ceg,cep,cev,cre,cr,crp=e:GetLabelObject():CheckActivateEffect(true,true,false)
		-- 清除当前连锁的对象
		Duel.ClearTargetCard()
		local tg=te:GetTarget()
		if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
		cpel=e:GetLabel()
		te:SetLabelObject(e:GetLabelObject())
		e:SetProperty(te:GetProperty()&EFFECT_FLAG_CARD_TARGET)
		e:SetLabelObject(te)
		e:SetCategory(0)
		-- 清除当前连锁的操作信息
		Duel.ClearOperationInfo(0)
	end
	e:SetLabel(cpel,op)
end
-- 效果1的发动处理函数，根据选择的操作执行不同的效果
function s.ceop(e,tp,eg,ep,ev,re,r,rp)
	local cpel,op=e:GetLabel()
	if op==1 then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组中选择一张满足检索条件的魔法卡
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的魔法卡送入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方确认所选的魔法卡
			Duel.ConfirmCards(1-tp,g)
		end
	elseif op==2 then
		local te=e:GetLabelObject()
		if not te then return end
		e:SetLabelObject(te:GetLabelObject())
		local ope=te:GetOperation()
		e:SetLabel(cpel)
		if ope then ope(e,tp,eg,ep,ev,re,r,rp) end
	end
end
-- 效果2的发动条件，判断是否为自己的回合
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为自己的回合
	return Duel.GetTurnPlayer()==tp
end
-- 墓地卡过滤器，判断是否为witchcraft族且可送去墓地且正面表示
function s.tgfilter(c)
	return c:IsSetCard(0x128) and c:IsAbleToGrave() and c:IsFaceup()
end
-- 效果2的目标设定函数，检查是否存在满足条件的墓地卡
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查是否存在满足墓地卡过滤条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_REMOVED,0,1,nil) end
end
-- 效果2的发动处理函数，选择一张满足条件的墓地卡并将其送去墓地
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从墓地中选择一张满足条件的卡
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	if g:GetCount() then
		-- 将选中的卡送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_RETURN)
	end
end
