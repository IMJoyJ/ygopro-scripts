--破械式鬼シャラ
local s,id,o=GetID()
-- 注册卡片效果的初始化函数（在自己·对方主要阶段从手牌丢弃以从手牌特殊召唤1只恶魔族怪兽并破坏自己场上1张卡的效果，以及在墓地存在时当场上的卡被战斗或自己以外效果破坏时可特召或回手牌的效果）
function s.initial_effect(c)
	-- 注册检测该卡是否已被送去墓地的标记检测效果，防止在同一连锁中重复判定
	local e0=aux.AddThisCardInGraveAlreadyCheck(c)
	-- 自己·对方的主要阶段，把这张卡从手卡丢弃才能发动。从手卡把1只恶魔族怪兽特殊召唤.那之后，自己场上1张卡破坏
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(TIMING_MAIN_END)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 这张卡在墓地存在的状态，场上的卡被战斗或者「破械式鬼 奢罗」以外的卡的效果破坏的场合才能发动。这张卡加入手卡或特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合回到卡组最下面
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_GRAVE_SPSUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetLabelObject(e0)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 效果①从手牌特召并破坏卡片的发动条件函数
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为主要阶段
	return Duel.IsMainPhase()
end
-- 效果①的发动代价函数
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将这张卡从手牌丢弃送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 过滤手牌中可以特殊召唤的恶魔族怪兽的过滤函数
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_FIEND) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备与检查函数
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在chk==0时，检查当前玩家场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查手牌中（除自身外）是否存在可以特殊召唤的恶魔族怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,e:GetHandler(),e,tp) end
	-- 设置效果处理的分类为特殊召唤，数量为1，目标位置为手牌
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	-- 获取当前玩家场上的所有卡（用于后续设定破坏的操作信息）
	local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,0)
	if g:GetCount()>0 then
		-- 设置效果处理的分类为破坏，数量为1，目标位置为自己场上
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	end
end
-- 效果①特殊召唤与破坏自己场上卡片的效果处理函数
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若没有可用的怪兽区域，则结束效果处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌中选择1只符合条件的恶魔族怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	-- 如果选择了恶魔族怪兽，并且成功将其以表侧表示特殊召唤
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 中断效果处理，使后续的破坏操作与特殊召唤不视为同时处理
		Duel.BreakEffect()
		-- 提示玩家选择要破坏的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 让玩家在自己场上选择1张卡
		local sg=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,0,1,1,nil)
		if sg:GetCount()>0 then
			-- 在场上显式标出被选为破坏对象的卡
			Duel.HintSelection(sg)
			-- 破坏选择的自己场上的卡
			Duel.Destroy(sg,REASON_EFFECT)
		end
	end
end
-- 过滤在场上被战斗或自身效果以外破坏的卡的过滤函数
function s.cfilter(c,tp,se,re)
	return c:IsPreviousLocation(LOCATION_ONFIELD)
		and (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and not re:GetHandler():IsCode(id)))
		and (se==nil or c:GetReasonEffect()~=se)
end
-- 效果②特召或加入手牌的发动条件函数
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local se=e:GetLabelObject():GetLabelObject()
	return eg:IsExists(s.cfilter,1,c,tp,se,re)
end
-- 效果②特召或加入手牌的发动准备与检查函数
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand()
		-- 或者检查自己场上是否有空余的怪兽区域且该卡是否能特殊召唤
		or (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)) end
end
-- 效果②特召或加入手牌的效果处理函数
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() then return end
	-- 进行王家长眠之谷的否定检查，若受到影响则无效效果
	if aux.NecroValleyNegateCheck(c) then return end
	-- 检查该卡是否不受王家长眠之谷效果的影响
	if not aux.NecroValleyFilter()(c) then return end
	local b1=c:IsAbleToHand()
	-- 检查自己场上是否有可用的怪兽区域并且该卡是否可以特殊召唤
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	local op=0
	if b1 and not b2 then
		op=1
	elseif not b1 and b2 then
		op=2
	else
		-- 让玩家在“加入手牌”或“特殊召唤”中选择一个选项
		op=aux.SelectFromOptions(tp,{b1,1190},{b2,1152})
	end
	if op==1 then
		-- 将这张卡加入手牌
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
	-- 如果选择了特殊召唤选项，并且成功将这张卡特殊召唤
	if op==2 and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合回到卡组最下面
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_DECKBOT)
		c:RegisterEffect(e1,true)
	end
end
