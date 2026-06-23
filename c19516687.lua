--リブロマンサー・エージェント
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把手卡1只仪式怪兽给对方观看才能发动。这张卡从手卡特殊召唤。
-- ②：以「书灵师·代理人」以外的自己墓地1张「书灵师」卡为对象才能发动。那张卡加入手卡。这个效果把魔法·陷阱卡加入手卡的场合，再选自己1张手卡回到卡组最下面。
local s,id,o=GetID()
-- 创建两个效果，分别对应①②效果
function s.initial_effect(c)
	-- ①：把手卡1只仪式怪兽给对方观看才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：以「书灵师·代理人」以外的自己墓地1张「书灵师」卡为对象才能发动。那张卡加入手卡。这个效果把魔法·陷阱卡加入手卡的场合，再选自己1张手卡回到卡组最下面。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.g2htg)
	e2:SetOperation(s.g2hop)
	c:RegisterEffect(e2)
end
-- 检索满足条件的仪式怪兽（未公开）
function s.spcostfilter(c)
	return c:IsType(TYPE_RITUAL) and c:IsType(TYPE_MONSTER) and not c:IsPublic()
end
-- 检查是否满足①效果的发动条件并选择1只仪式怪兽给对方确认
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否满足①效果的发动条件
	if chk==0 then return Duel.IsExistingMatchingCard(s.spcostfilter,tp,LOCATION_HAND,0,1,c) end
	-- 提示玩家选择要给对方确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 选择1只仪式怪兽给对方确认
	local g=Duel.SelectMatchingCard(tp,s.spcostfilter,tp,LOCATION_HAND,0,1,1,c)
	-- 向对方确认选择的卡
	Duel.ConfirmCards(1-tp,g)
	-- 洗切自己的手牌
	Duel.ShuffleHand(tp)
end
-- 设置①效果的发动条件
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否满足①效果的发动条件
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置①效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 处理①效果的发动
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将该卡特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 检索满足条件的「书灵师」卡
function s.g2hfilter(c)
	return c:IsSetCard(0x17c) and not c:IsCode(id) and c:IsAbleToHand()
end
-- 设置②效果的发动条件
function s.g2htg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.g2hfilter(chkc) end
	-- 检查是否满足②效果的发动条件
	if chk==0 then return Duel.IsExistingTarget(s.g2hfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择1张墓地的「书灵师」卡
	local g=Duel.SelectTarget(tp,s.g2hfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置②效果的处理信息（回手）
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,LOCATION_GRAVE)
	if g:GetFirst():IsType(TYPE_SPELL+TYPE_TRAP) then
		-- 设置②效果的处理信息（回卡组）
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,0,LOCATION_HAND)
	end
end
-- 处理②效果的发动
function s.g2hop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的目标卡
	local tc=Duel.GetFirstTarget()
	-- 确认目标卡是否有效并将其加入手牌
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0
		and tc:IsLocation(LOCATION_HAND) and tc:IsType(TYPE_SPELL+TYPE_TRAP) then
		-- 洗切自己的手牌
		Duel.ShuffleHand(tp)
		-- 提示玩家选择要返回卡组的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 选择1张手卡返回卡组最下面
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
		if #g>0 then
			-- 中断当前效果
			Duel.BreakEffect()
			-- 将选择的手卡返回卡组最下面
			Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
		end
	end
end
