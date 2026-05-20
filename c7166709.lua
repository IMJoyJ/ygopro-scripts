--Steel-Stringed Sacrifice
-- 效果：
-- 这张卡在手卡·墓地存在的场合：可以把手卡1只5星以上的怪兽给对方出示，从以下效果选择1个发动（「钢弦祭他手」的以下效果1回合各能选择1次），发动后，这个回合中自己没有把出示怪兽或者原本卡名和那只怪兽相同的怪兽召唤的场合，结束阶段让自己失去1000基本分。
-- ●这张卡从手卡特殊召唤。
-- ●这张卡从自己墓地加入手卡。
-- ●从自己墓地把这张卡除外，从自己墓地把1只5星以上的怪兽加入手卡。
local s,id,o=GetID()
-- 注册卡片效果：手牌特召效果（e1）、墓地回手效果（e2）、墓地除外并回收墓地5星以上怪兽效果（e3）。
function s.initial_effect(c)
	-- ●这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ●这张卡从自己墓地加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetDescription(aux.Stringid(id,2))  --"加入手卡"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- ●从自己墓地把这张卡除外，从自己墓地把1只5星以上的怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))  --"这张卡除外"
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.thtg2)
	e3:SetOperation(s.thop2)
	c:RegisterEffect(e3)
end
-- 过滤条件：手牌中5星以上的非公开怪兽。
function s.cfilter(c)
	return c:IsLevelAbove(5) and c:IsType(TYPE_MONSTER) and not c:IsPublic()
end
-- 效果发动Cost：把手卡1只5星以上的怪兽给对方出示，并记录该怪兽的原本卡名。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在可以给对方出示的5星以上怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要给对方确认的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 玩家选择手牌中1只满足条件的5星以上怪兽。
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选择的怪兽给对方玩家确认。
	Duel.ConfirmCards(1-tp,g)
	local tc=g:GetFirst()
	-- 洗切手牌。
	Duel.ShuffleHand(tp)
	e:SetLabel(tc:GetOriginalCodeRule())
end
-- 效果1（手牌特召）的发动准备：检查怪兽区域是否有空位，以及自身是否可以特殊召唤，并设置操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果1（手牌特召）的处理：特殊召唤自身，并注册检测召唤和结束阶段扣血的延迟效果。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将这张卡以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 发动后，这个回合中自己没有把出示怪兽或者原本卡名和那只怪兽相同的怪兽召唤的场合
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetLabel(e:GetLabel())
	e1:SetOperation(s.regop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册全局效果，用于监测本回合是否通常召唤了出示的怪兽。
	Duel.RegisterEffect(e1,tp)
	-- 结束阶段让自己失去1000基本分。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetCondition(s.damcon)
	e2:SetOperation(s.damop)
	e2:SetLabelObject(e1)
	-- 注册全局效果，在结束阶段检查是否需要扣除基本分。
	Duel.RegisterEffect(e2,tp)
end
-- 过滤条件：由自己召唤成功且原本卡名与出示怪兽相同的怪兽。
function s.regfilter(c,tp,code)
	return c:IsSummonPlayer(tp) and c:IsOriginalCodeRule(code)
end
-- 召唤检测处理：若召唤了出示的怪兽，则将标记重置为0（代表已召唤，不扣血）。
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then return end
	if eg:IsExists(s.regfilter,1,nil,tp,e:GetLabel()) then
		e:SetLabel(0)
	end
end
-- 扣血条件：结束阶段时，召唤检测标记不为0（即本回合未召唤出示的怪兽）。
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():GetLabel()~=0
end
-- 扣血处理：使自己失去1000基本分。
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 将自己的基本分减少1000。
	Duel.SetLP(tp,Duel.GetLP(tp)-1000)
end
-- 效果2（墓地回手）的发动准备：检查自身是否可以加入手牌，并设置操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置将自身加入手牌的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果2（墓地回手）的处理：将自身加入手牌并给对方确认，同时注册检测召唤和结束阶段扣血的延迟效果。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查这张卡是否仍存在于墓地且不受王家长眠之谷影响。
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将这张卡加入手牌。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		-- 将加入手牌的这张卡给对方确认。
		Duel.ConfirmCards(1-tp,c)
	end
	-- 发动后，这个回合中自己没有把出示怪兽或者原本卡名和那只怪兽相同的怪兽召唤的场合
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetLabel(e:GetLabel())
	e1:SetOperation(s.regop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册全局效果，用于监测本回合是否通常召唤了出示的怪兽。
	Duel.RegisterEffect(e1,tp)
	-- 结束阶段让自己失去1000基本分。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetCondition(s.damcon)
	e2:SetOperation(s.damop)
	e2:SetLabelObject(e1)
	-- 注册全局效果，在结束阶段检查是否需要扣除基本分。
	Duel.RegisterEffect(e2,tp)
end
-- 过滤条件：自己墓地中可以加入手牌的5星以上怪兽。
function s.thfilter(c)
	return c:IsLevelAbove(5) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果3（除外自身并回收墓地怪兽）的发动准备：检查自身是否可以除外、墓地是否有其他5星以上怪兽，并设置操作信息。
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己墓地是否存在除自身以外的5星以上怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,c)
		and c:IsAbleToRemove() end
	-- 设置从墓地将1张卡加入手牌的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
	-- 设置将自身除外的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,c,1,0,0)
end
-- 效果3（除外自身并回收墓地怪兽）的处理：将自身除外，并选择墓地1只5星以上怪兽加入手牌，同时注册检测召唤和结束阶段扣血的延迟效果。
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自身是否在墓地且不受王家长眠之谷影响，并尝试将自身除外。
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) and Duel.Remove(c,0,REASON_EFFECT)~=0 then
		-- 提示玩家选择要加入手牌的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 玩家选择自己墓地1只不受王家长眠之谷影响的5星以上怪兽。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选择的怪兽加入手牌。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 将加入手牌的怪兽给对方确认。
			Duel.ConfirmCards(1-tp,g)
		end
	end
	-- 发动后，这个回合中自己没有把出示怪兽或者原本卡名和那只怪兽相同的怪兽召唤的场合
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetLabel(e:GetLabel())
	e1:SetOperation(s.regop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册全局效果，用于监测本回合是否通常召唤了出示的怪兽。
	Duel.RegisterEffect(e1,tp)
	-- 结束阶段让自己失去1000基本分。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetCondition(s.damcon)
	e2:SetOperation(s.damop)
	e2:SetLabelObject(e1)
	-- 注册全局效果，在结束阶段检查是否需要扣除基本分。
	Duel.RegisterEffect(e2,tp)
end
