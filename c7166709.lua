--鉄絃の犠打職人
-- 效果：
-- 这张卡在手卡·墓地存在的场合：可以把手卡1只5星以上的怪兽给对方出示，从以下效果选择1个发动（「钢弦祭他手」的以下效果1回合各能选择1次），发动后，这个回合中自己没有把出示怪兽或者原本卡名和那只怪兽相同的怪兽召唤的场合，结束阶段让自己失去1000基本分。
-- ●这张卡从手卡特殊召唤。
-- ●这张卡从自己墓地加入手卡。
-- ●从自己墓地把这张卡除外，从自己墓地把1只5星以上的怪兽加入手卡。
local s,id,o=GetID()
-- 初始化卡片效果：注册①手牌特召效果、②墓地回收自身效果、③墓地除外自身回收5星以上怪兽效果
function s.initial_effect(c)
	-- ●这张卡从手牌特殊召唤。
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
	-- ●这张卡从自己墓地加入手牌。
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
	-- ●从自己墓地把这张卡除外，从自己墓地把1只5星以上的怪兽加入手牌。
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
-- Cost过滤条件：手牌中5星以上的怪兽且未给对方出示过
function s.cfilter(c)
	return c:IsLevelAbove(5) and c:IsType(TYPE_MONSTER) and not c:IsPublic()
end
-- 效果发动Cost：把手牌1只5星以上的怪兽给对方确认，并记录其原本卡名
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- Cost检查：手牌中是否存在可给对方确认的5星以上怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要给对方确认的手牌怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从手牌选择1只5星以上的怪兽
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 向对方确认选中的手牌怪兽
	Duel.ConfirmCards(1-tp,g)
	local tc=g:GetFirst()
	-- 将手牌重新洗牌
	Duel.ShuffleHand(tp)
	e:SetLabel(tc:GetOriginalCodeRule())
end
-- ①效果发动准备：检查主要怪兽区域空位与自身特召条件，并设置特召操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动条件检查：主要怪兽区域有空位且自身可以特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息：特殊召唤自身1张
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果处理：特殊召唤自身，并注册检查召唤该怪兽的全局效果与未召唤扣除1000LP的结束阶段效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将此卡表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 注册持续到回合结束的监听效果：记录本回合是否召唤了出示的怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetLabel(e:GetLabel())
	e1:SetOperation(s.regop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 为玩家注册召唤监听效果
	Duel.RegisterEffect(e1,tp)
	-- 注册结束阶段触发效果：若本回合未召唤出示的怪兽则失去1000LP
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetCondition(s.damcon)
	e2:SetOperation(s.damop)
	e2:SetLabelObject(e1)
	-- 为玩家注册结束阶段扣除LP的全局效果
	Duel.RegisterEffect(e2,tp)
end
-- 召唤检测过滤：玩家召唤的原本卡名与出示怪兽相同的怪兽
function s.regfilter(c,tp,code)
	return c:IsSummonPlayer(tp) and c:IsOriginalCodeRule(code)
end
-- 召唤监听处理：若成功召唤了出示的怪兽，则清空Label标记（避免扣除LP）
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then return end
	if eg:IsExists(s.regfilter,1,nil,tp,e:GetLabel()) then
		e:SetLabel(0)
	end
end
-- 扣除LP发动条件：Label标记未被清空（即本回合未召唤出示的怪兽）
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():GetLabel()~=0
end
-- 扣除LP效果处理：玩家失去1000基本分
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 将玩家的基本分减少1000
	Duel.SetLP(tp,Duel.GetLP(tp)-1000)
end
-- ②效果发动准备：设置将墓地的此卡加入手牌的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置连锁操作信息：将墓地的此卡1张加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- ②效果处理：将墓地的此卡加入手牌，并注册召唤监听与结束阶段扣除LP的效果
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否仍关联连锁且不受「王家长眠之谷」影响
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将此卡加入手牌
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,c)
	end
	-- 注册持续到回合结束的监听效果：记录本回合是否召唤了出示的怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetLabel(e:GetLabel())
	e1:SetOperation(s.regop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 为玩家注册召唤监听效果
	Duel.RegisterEffect(e1,tp)
	-- 注册结束阶段触发效果：若本回合未召唤出示的怪兽则失去1000LP
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetCondition(s.damcon)
	e2:SetOperation(s.damop)
	e2:SetLabelObject(e1)
	-- 为玩家注册结束阶段扣除LP的全局效果
	Duel.RegisterEffect(e2,tp)
end
-- 墓地回收怪兽过滤条件：5星以上的怪兽且可加入手牌
function s.thfilter(c)
	return c:IsLevelAbove(5) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ③效果发动准备：检查墓地回收目标与自身除外条件，并设置回收和除外的操作信息
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动条件检查：墓地中存在除自身以外5星以上的怪兽且自身可以除外
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,c)
		and c:IsAbleToRemove() end
	-- 设置连锁操作信息：从墓地将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
	-- 设置连锁操作信息：将墓地的自身除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,c,1,0,0)
end
-- ③效果处理：除外墓地的此卡，从墓地把1只5星以上怪兽加入手牌，并注册召唤监听与结束阶段扣除LP的效果
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡关联连锁且不受墓谷影响，成功将此卡除外后继续处理
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) and Duel.Remove(c,0,REASON_EFFECT)~=0 then
		-- 提示玩家选择要加入手牌的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从墓地选择1只5星以上的怪兽
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的怪兽加入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方确认加入手牌的卡
			Duel.ConfirmCards(1-tp,g)
		end
	end
	-- 注册持续到回合结束的监听效果：记录本回合是否召唤了出示的怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetLabel(e:GetLabel())
	e1:SetOperation(s.regop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 为玩家注册召唤监听效果
	Duel.RegisterEffect(e1,tp)
	-- 注册结束阶段触发效果：若本回合未召唤出示的怪兽则失去1000LP
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetCondition(s.damcon)
	e2:SetOperation(s.damop)
	e2:SetLabelObject(e1)
	-- 为玩家注册结束阶段扣除LP的全局效果
	Duel.RegisterEffect(e2,tp)
end
