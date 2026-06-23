--星逢の天河
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把手卡1只仪式怪兽给对方观看才能发动。和那只怪兽是卡名不同并是等级相同的1只仪式怪兽从卡组加入手卡。
-- ②：把墓地的这张卡除外，从手卡把1张仪式魔法卡送去墓地才能发动。这个效果变成和那张仪式魔法卡发动时的仪式召唤效果相同。
local s,id,o=GetID()
-- 注册两个效果，分别为①效果和②效果
function s.initial_effect(c)
	-- ①：把手卡1只仪式怪兽给对方观看才能发动。和那只怪兽是卡名不同并是等级相同的1只仪式怪兽从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，从手卡把1张仪式魔法卡送去墓地才能发动。这个效果变成和那张仪式魔法卡发动时的仪式召唤效果相同。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCost(s.rscost)
	e2:SetTarget(s.rstg)
	e2:SetOperation(s.rsop)
	c:RegisterEffect(e2)
end
-- ①效果的费用处理，设置标签为100
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
-- 筛选手卡中满足条件的仪式怪兽（未公开且卡组中有同等级不同名的仪式怪兽）
function s.cfilter(c,tp)
	return bit.band(c:GetType(),0x81)==0x81 and not c:IsPublic()
		-- 检查卡组中是否存在满足条件的仪式怪兽
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,c)
end
-- 筛选卡组中满足条件的仪式怪兽（不同名、同等级、可加入手牌）
function s.thfilter(c,rc)
	return not c:IsCode(rc:GetCode()) and c:IsLevel(rc:GetLevel())
		and bit.band(c:GetType(),0x81)==0x81
		and c:IsAbleToHand()
end
-- ①效果的发动条件判断与处理，选择并确认手卡中的仪式怪兽，设置操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 检查手卡中是否存在满足条件的仪式怪兽
		return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil,tp)
	end
	-- 提示玩家选择要给对方确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 选择手卡中的仪式怪兽
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil,tp)
	e:SetLabelObject(g:GetFirst())
	-- 向对方确认所选的卡
	Duel.ConfirmCards(1-tp,g)
	-- 洗切自己的手牌
	Duel.ShuffleHand(tp)
	-- 设置操作信息，表示将从卡组检索1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的处理，选择并加入手牌
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	local rc=e:GetLabelObject()
	-- 选择卡组中满足条件的仪式怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,rc)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 筛选手卡中满足条件的仪式魔法卡（可作为发动代价且有发动效果）
function s.rtfilter(c)
	return c:GetType()==TYPE_SPELL+TYPE_RITUAL and c:IsAbleToGraveAsCost() and c:CheckActivateEffect(true,true,false)~=nil
end
-- ②效果的费用处理，设置标签为1
function s.rscost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- ②效果的发动条件判断与处理，选择并处理仪式魔法卡
function s.rstg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		if e:GetLabel()==0 then return false end
		e:SetLabel(0)
		-- 检查手卡中是否存在满足条件的仪式魔法卡
		return Duel.IsExistingMatchingCard(s.rtfilter,tp,LOCATION_HAND,0,1,nil)
			and c:IsAbleToRemoveAsCost()
	end
	e:SetLabel(0)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择手卡中的仪式魔法卡
	local g=Duel.SelectMatchingCard(tp,s.rtfilter,tp,LOCATION_HAND,0,1,1,nil)
	local te=g:GetFirst():CheckActivateEffect(true,true,false)
	e:SetLabelObject(te)
	-- 将选中的仪式魔法卡送去墓地
	Duel.SendtoGrave(g,REASON_COST)
	-- 将自身从墓地除外
	Duel.Remove(c,POS_FACEUP,REASON_COST)
	e:SetProperty(te:GetProperty())
	local tg=te:GetTarget()
	if tg then tg(e,tp,eg,ep,ev,re,r,rp,1) end
	-- 清除当前连锁的操作信息
	Duel.ClearOperationInfo(0)
end
-- ②效果的处理，执行选中仪式魔法卡的发动效果
function s.rsop(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if not te then return end
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
end
