--魔界劇団－メロー・マドンナ
-- 效果：
-- ←0 【灵摆】 0→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：支付1000基本分才能发动。从卡组把「魔界剧团-圆熟女主演」以外的1只「魔界剧团」灵摆怪兽加入手卡。这个效果的发动后，直到回合结束时自己不是「魔界剧团」灵摆怪兽不能特殊召唤。
-- 【怪兽效果】
-- 这个卡名的①③的怪兽效果1回合各能使用1次。
-- ①：自己的灵摆怪兽被战斗破坏时才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡的攻击力上升自己墓地的「魔界台本」魔法卡数量×100。
-- ③：「魔界台本」魔法卡的效果发动的场合才能发动。从卡组把1只4星以下的「魔界剧团」灵摆怪兽特殊召唤。这个效果特殊召唤的怪兽在结束阶段回到持有者手卡。
function c78310590.initial_effect(c)
	-- 为怪兽卡注册灵摆怪兽属性（灵摆召唤、灵摆卡的发动等）。
	aux.EnablePendulumAttribute(c)
	-- ①：支付1000基本分才能发动。从卡组把「魔界剧团-圆熟女主演」以外的1只「魔界剧团」灵摆怪兽加入手卡。这个效果的发动后，直到回合结束时自己不是「魔界剧团」灵摆怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(78310590,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,78310590)
	e1:SetCost(c78310590.thcost)
	e1:SetTarget(c78310590.thtg)
	e1:SetOperation(c78310590.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡的攻击力上升自己墓地的「魔界台本」魔法卡数量×100。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c78310590.val)
	c:RegisterEffect(e2)
	-- ①：自己的灵摆怪兽被战斗破坏时才能发动。这张卡从手卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(78310590,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYED)
	e3:SetRange(LOCATION_HAND)
	e3:SetCountLimit(1,78310591)
	e3:SetCondition(c78310590.spcon)
	e3:SetTarget(c78310590.sptg)
	e3:SetOperation(c78310590.spop)
	c:RegisterEffect(e3)
	-- ③：「魔界台本」魔法卡的效果发动的场合才能发动。从卡组把1只4星以下的「魔界剧团」灵摆怪兽特殊召唤。这个效果特殊召唤的怪兽在结束阶段回到持有者手卡。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(78310590,2))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_CHAINING)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,78310592)
	e5:SetCondition(c78310590.spcon2)
	e5:SetTarget(c78310590.sptg2)
	e5:SetOperation(c78310590.spop2)
	c:RegisterEffect(e5)
end
-- 灵摆效果的发动代价（Cost）判定与支付函数。
function c78310590.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能够支付1000点基本分。
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 玩家支付1000点基本分。
	Duel.PayLPCost(tp,1000)
end
-- 过滤卡组中除「魔界剧团-圆熟女主演」以外的「魔界剧团」灵摆怪兽。
function c78310590.thfilter(c)
	return c:IsSetCard(0x10ec) and not c:IsCode(78310590) and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
-- 灵摆效果的靶向（Target）判定与操作信息注册函数。
function c78310590.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在符合检索条件的卡片。
	if chk==0 then return Duel.IsExistingMatchingCard(c78310590.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 注册连锁处理中的操作信息：从卡组将1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 灵摆效果的处理（Operation）函数，包含检索和特殊召唤限制的注册。
function c78310590.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 给玩家发送提示信息，要求选择加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张符合条件的卡。
	local g=Duel.SelectMatchingCard(tp,c78310590.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片因效果加入手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
	-- 这个效果的发动后，直到回合结束时自己不是「魔界剧团」灵摆怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c78310590.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 在全局环境中为玩家注册该特殊召唤限制效果。
	Duel.RegisterEffect(e1,tp)
end
-- 限制不能特殊召唤「魔界剧团」灵摆怪兽以外的怪兽。
function c78310590.splimit(e,c)
	return not (c:IsSetCard(0x10ec) and c:IsType(TYPE_PENDULUM))
end
-- 过滤自己墓地的「魔界台本」魔法卡。
function c78310590.valfilter(c)
	return c:IsSetCard(0x20ec) and c:IsType(TYPE_SPELL)
end
-- 计算攻击力上升值的函数。
function c78310590.val(e,c)
	-- 返回自己墓地「魔界台本」魔法卡数量乘以100的数值。
	return Duel.GetMatchingGroupCount(c78310590.valfilter,c:GetControler(),LOCATION_GRAVE,0,nil)*100
end
-- 过滤被战斗破坏前在自己场上存在的灵摆怪兽。
function c78310590.cfilter(c,tp)
	return c:IsType(TYPE_PENDULUM) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
end
-- 怪兽效果①的发动条件判定：检查是否有自己的灵摆怪兽被战斗破坏。
function c78310590.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c78310590.cfilter,1,nil,tp)
end
-- 怪兽效果①的靶向判定与操作信息注册函数。
function c78310590.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 注册连锁处理中的操作信息：将自身特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 怪兽效果①的处理函数：将自身特殊召唤。
function c78310590.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到自己场上。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 怪兽效果③的发动条件判定：检查是否是「魔界台本」魔法卡的效果发动。
function c78310590.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_SPELL) and re:GetHandler():IsSetCard(0x20ec)
end
-- 过滤卡组中4星以下的「魔界剧团」灵摆怪兽。
function c78310590.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x10ec) and c:IsType(TYPE_PENDULUM) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 怪兽效果③的靶向判定与操作信息注册函数。
function c78310590.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在符合特殊召唤条件的怪兽。
		and Duel.IsExistingMatchingCard(c78310590.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 注册连锁处理中的操作信息：从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK)
end
-- 怪兽效果③的处理函数：特殊召唤怪兽，并注册结束阶段回到手卡的效果。
function c78310590.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有空余的怪兽区域，若无则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	local c=e:GetHandler()
	-- 给玩家发送提示信息，要求选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组中选择1只符合条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c78310590.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		local fid=c:GetFieldID()
		tc:RegisterFlagEffect(78310590,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 这个效果特殊召唤的怪兽在结束阶段回到持有者手卡。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetCondition(c78310590.thcon2)
		e1:SetOperation(c78310590.thop2)
		-- 注册在结束阶段触发的延迟处理效果。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 结束阶段回到手卡效果的发动条件判定：检查目标怪兽是否仍带有相同的标记。
function c78310590.thcon2(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(78310590)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 结束阶段回到手卡效果的处理函数。
function c78310590.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 将特殊召唤的怪兽送回持有者的手卡。
	Duel.SendtoHand(e:GetLabelObject(),nil,REASON_EFFECT)
end
