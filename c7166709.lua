--鉄絃の犠打職人
-- 效果：
-- 这张卡在手卡·墓地存在的场合：可以把手卡1只5星以上的怪兽给对方出示，从以下效果选择1个发动（「钢弦祭他手」的以下效果1回合各能选择1次），发动后，这个回合中自己没有把出示怪兽或者原本卡名和那只怪兽相同的怪兽召唤的场合，结束阶段让自己失去1000基本分。
-- ●这张卡从手卡特殊召唤。
-- ●这张卡从自己墓地加入手卡。
-- ●从自己墓地把这张卡除外，从自己墓地把1只5星以上的怪兽加入手卡。
local s,id,o=GetID()
-- 初始化卡片效果：注册①出示5星以上怪兽特召自身、②出示5星以上怪兽回收自身、③出示5星以上怪兽除外自身回收墓地5星以上怪兽的效果
function s.initial_effect(c)
	-- ●这张卡在手卡存在的场合：可以把手卡1只5星以上的怪兽给对方出示；这张卡从手卡特殊召唤。
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
	-- ●这张卡在墓地存在的场合：可以把手卡1只5星以上的怪兽给对方出示；这张卡从自己墓地加入手卡。
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
	-- ●这张卡在墓地存在的场合：可以把手卡1只5星以上的怪兽给对方出示，从自己墓地把这张卡除外；从自己墓地把1只5星以上的怪兽加入手卡。
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
-- Cost过滤条件：手牌中未公开的5星以上的怪兽
function s.cfilter(c)
	return c:IsLevelAbove(5) and c:IsType(TYPE_MONSTER) and not c:IsPublic()
end
-- 通用Cost：出示手牌1只5星以上怪兽，并记录其原本卡名规则
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- Cost检查：手牌是否存在未公开的5星以上怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要出示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从手牌选择1只5星以上的怪兽
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 向对方玩家展示选中的怪兽
	Duel.ConfirmCards(1-tp,g)
	local tc=g:GetFirst()
	-- 洗切出示卡片后的手牌
	Duel.ShuffleHand(tp)
	e:SetLabel(tc:GetOriginalCodeRule())
end
-- ①效果发动准备：检查怪兽区域空位并设置特召操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动条件检查：怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息：特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果处理：特殊召唤自身，并注册没召唤同名怪兽扣1000LP的延迟检查效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将此卡表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 注册本回合召唤检测效果：记录出示怪兽的卡名召唤情况
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetLabel(e:GetLabel())
	e1:SetOperation(s.regop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 在玩家身上注册召唤检测持续效果
	Duel.RegisterEffect(e1,tp)
	-- 注册结束阶段判定效果：若本回合未召唤同名怪兽则扣除1000LP
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetCondition(s.damcon)
	e2:SetOperation(s.damop)
	e2:SetLabelObject(e1)
	-- 在玩家身上注册结束阶段扣LP持续效果
	Duel.RegisterEffect(e2,tp)
end
-- 召唤成功检测过滤：确认召唤的怪兽原本卡名与出示怪兽相同
function s.regfilter(c,tp,code)
	return c:IsSummonPlayer(tp) and c:IsOriginalCodeRule(code)
end
-- 召唤检测处理：若成功召唤同名怪兽则清除扣分标记
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then return end
	if eg:IsExists(s.regfilter,1,nil,tp,e:GetLabel()) then
		e:SetLabel(0)
	end
end
-- 扣LP条件检查：确认本回合未召唤过出示卡名的怪兽
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():GetLabel()~=0
end
-- 结束阶段扣LP处理：玩家失去1000基本分
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 将玩家基本分减少1000点
	Duel.SetLP(tp,Duel.GetLP(tp)-1000)
end
-- ②效果发动准备：检查自身能否加入手牌并设置回收操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置连锁操作信息：将墓地的此卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- ②效果处理：将此卡加入手牌，并注册没召唤同名怪兽扣1000LP的延迟检查效果
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否仍关联连锁且不受王谷影响
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将此卡加入手牌
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的此卡
		Duel.ConfirmCards(1-tp,c)
	end
	-- 注册本回合召唤检测效果：记录出示怪兽的卡名召唤情况
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetLabel(e:GetLabel())
	e1:SetOperation(s.regop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 在玩家身上注册召唤检测持续效果
	Duel.RegisterEffect(e1,tp)
	-- 注册结束阶段判定效果：若本回合未召唤同名怪兽则扣除1000LP
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetCondition(s.damcon)
	e2:SetOperation(s.damop)
	e2:SetLabelObject(e1)
	-- 在玩家身上注册结束阶段扣LP持续效果
	Duel.RegisterEffect(e2,tp)
end
-- 墓地回收对象过滤：5星以上的怪兽
function s.thfilter(c)
	return c:IsLevelAbove(5) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ③效果发动准备：检查墓地回收目标及自身除外条件，并设置操作信息
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动条件检查：墓地是否存在自身以外可回收的5星以上怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,c)
		and c:IsAbleToRemove() end
	-- 设置连锁操作信息：从墓地将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
	-- 设置连锁操作信息：除外墓地的此卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,c,1,0,0)
end
-- ③效果处理：除外自身并将墓地1只5星以上怪兽加入手牌，同时注册召唤检测与扣LP效果
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 除外墓地中的此卡并确认成功除外
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) and Duel.Remove(c,0,REASON_EFFECT)~=0 then
		-- 提示玩家选择要加入手牌的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从墓地选择1只5星以上的怪兽
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的怪兽加入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方玩家确认加入手牌的怪兽
			Duel.ConfirmCards(1-tp,g)
		end
	end
	-- 注册本回合召唤检测效果：记录出示怪兽的卡名召唤情况
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetLabel(e:GetLabel())
	e1:SetOperation(s.regop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 在玩家身上注册召唤检测持续效果
	Duel.RegisterEffect(e1,tp)
	-- 注册结束阶段判定效果：若本回合未召唤同名怪兽则扣除1000LP
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetCondition(s.damcon)
	e2:SetOperation(s.damop)
	e2:SetLabelObject(e1)
	-- 在玩家身上注册结束阶段扣LP持续效果
	Duel.RegisterEffect(e2,tp)
end
