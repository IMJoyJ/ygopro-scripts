--ウィッチクラフト・ピューピルズ
local s,id,o=GetID()
-- 注册卡片效果的入口函数，定义并注册此卡的效果。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 注册融合素材限制：以「魔女术」怪兽＋魔法师族怪兽为融合素材
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x128),s.matfilter,true)
	-- ①：自己·对方的主要阶段及战斗阶段，可以从以下效果选择1个发动。●从卡组把1张「魔女术」魔法卡加入手牌。●把手牌1张「魔女术」魔法卡给对方观看可以发动。这个效果变成和那张魔法卡发动时的效果相同。
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
	-- ②：自己结束阶段，可以从自己被除外的卡中选择1张「魔女术」卡为对象发动。那张卡回到墓地。
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
-- 定义融合素材过滤函数，用于判断怪兽是否为魔法师族
function s.matfilter(c)
	return c:IsRace(RACE_SPELLCASTER)
end
-- 定义快速效果（效果①）的发动条件判断函数
function s.cecon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为主要阶段或战斗阶段
	return Duel.IsMainPhase() or Duel.IsBattlePhase()
end
-- 定义过滤函数，筛选卡组中可加入手牌的「魔女术」魔法卡
function s.thfilter(c)
	return c:IsSetCard(0x128) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 定义过滤函数，筛选手牌中非表侧表示且拥有可复制发动效果的「魔女术」魔法卡
function s.cpfilter(c)
	return c:IsSetCard(0x128) and (c:GetType()==TYPE_SPELL or c:IsType(TYPE_QUICKPLAY)) and not c:IsPublic()
		and c:CheckActivateEffect(true,true,false)~=nil
end
-- 定义快速效果（效果①）的代价检查与展示手牌处理函数（Cost）
function s.cecost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断卡组中是否存在可检索的「魔女术」魔法卡以适用效果分支1
	local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	-- 判断手牌中是否存在可展示并复制的「魔女术」魔法卡以适用效果分支2
	local b2=Duel.IsExistingMatchingCard(s.cpfilter,tp,LOCATION_HAND,0,1,nil)
	if chk==0 then return b1 or b2 end
	-- 让玩家选择分支1（检索魔法）还是分支2（复制效果）
	local op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,2),1},
			{b2,aux.Stringid(id,3),2})
	e:SetLabel(op)
	if op==2 then
		-- 给玩家提示：选择要向对方展示的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		-- 让玩家在手牌中选择1张符合条件的「魔女术」魔法卡以准备展示
		local g=Duel.SelectMatchingCard(tp,s.cpfilter,tp,LOCATION_HAND,0,1,1,nil)
		-- 将选定的「魔女术」魔法卡展示给对方确认
		Duel.ConfirmCards(1-tp,g)
		e:SetLabelObject(g:GetFirst())
		-- 洗涤手牌以打乱顺序
		Duel.ShuffleHand(tp)
	end
end
-- 定义快速效果（效果①）的发动准备与检查函数（Target）
function s.cetg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查是否至少有一个效果分支可以适用并发动
		return Duel.IsExistingMatchingCard(s.cpfilter,tp,LOCATION_HAND,0,1,nil) or Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	end
	local cpel=0
	local op=e:GetLabel()
	if op==1 then
		e:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
		-- 设置将卡片从卡组加入手牌的操作信息
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	elseif op==2 then
		local te,ceg,cep,cev,cre,cr,crp=e:GetLabelObject():CheckActivateEffect(true,true,false)
		-- 清除当前已注册的目标卡片信息以进行重新指向
		Duel.ClearTargetCard()
		local tg=te:GetTarget()
		if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
		cpel=e:GetLabel()
		te:SetLabelObject(e:GetLabelObject())
		e:SetProperty(te:GetProperty()&EFFECT_FLAG_CARD_TARGET)
		e:SetLabelObject(te)
		e:SetCategory(0)
		-- 清除之前设置的操作分类等注册信息，之后直接复制被选定卡的效果
		Duel.ClearOperationInfo(0)
	end
	e:SetLabel(cpel,op)
end
-- 定义快速效果（效果①）的实际执行逻辑函数（Operation）
function s.ceop(e,tp,eg,ep,ev,re,r,rp)
	local cpel,op=e:GetLabel()
	if op==1 then
		-- 给玩家提示：选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让玩家在卡组中选择1张符合条件的「魔女术」魔法卡
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选定的「魔女术」魔法卡加入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 展示加入手牌的魔法卡给对方确认
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
-- 定义被除外卡回到墓地效果（效果②）的发动条件判断函数
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认当前是否为我方的回合
	return Duel.GetTurnPlayer()==tp
end
-- 定义过滤函数，筛选我方除外状态且可以送入墓地的表侧表示的「魔女术」卡片
function s.tgfilter(c)
	return c:IsSetCard(0x128) and c:IsAbleToGrave() and c:IsFaceup()
end
-- 定义回到墓地效果（效果②）的发动准备与检查函数（Target）
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查我方除外状态是否存在可以回到墓地的「魔女术」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_REMOVED,0,1,nil) end
end
-- 定义回到墓地效果（效果②）的实际执行逻辑函数（Operation）
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家提示：选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从除外状态选择1张符合条件的「魔女术」卡片
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	if g:GetCount() then
		-- 将选定的「魔女术」卡送回墓地
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_RETURN)
	end
end
