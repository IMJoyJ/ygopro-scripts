--ペンデュラムーチョ
-- 效果：
-- ←0 【灵摆】 0→
-- ①：这张卡发动的回合的自己主要阶段只有1次，从自己墓地的怪兽或者除外的自己怪兽之中以「灵摆多福鸟」以外的1只灵摆怪兽为对象才能发动。那只灵摆怪兽表侧表示加入自己的额外卡组。
-- 【怪兽效果】
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从自己的额外卡组把「灵摆多福鸟」以外的1只表侧表示的1星灵摆怪兽特殊召唤。这个效果特殊召唤的怪兽从场上离开的场合除外。
function c18210764.initial_effect(c)
	-- 为这张卡注册灵摆怪兽属性（灵摆召唤、可放置灵摆区等）；active_effect=false 表示不注册灵摆卡“卡的发动”效果，因为这里自行用e1处理发动。
	aux.EnablePendulumAttribute(c,false)
	-- “这张卡发动的回合的自己主要阶段只有1次”（灵摆效果①的条件部分；e1/reg用于记录这张卡已在本次发动）
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(1160)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c18210764.reg)
	c:RegisterEffect(e1)
	-- ①：这张卡发动的回合的自己主要阶段只有1次，从自己墓地的怪兽或者除外的自己怪兽之中以「灵摆多福鸟」以外的1只灵摆怪兽为对象才能发动。那只灵摆怪兽表侧表示加入自己的额外卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(18210764,0))  --"加入额外卡组"
	e2:SetCategory(CATEGORY_TOEXTRA)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetCondition(c18210764.tecon)
	e2:SetTarget(c18210764.tetg)
	e2:SetOperation(c18210764.teop)
	c:RegisterEffect(e2)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从自己的额外卡组把「灵摆多福鸟」以外的1只表侧表示的1星灵摆怪兽特殊召唤。这个效果特殊召唤的怪兽从场上离开的场合除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(18210764,2))  --"额外卡组灵摆怪兽特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetTarget(c18210764.sptg)
	e3:SetOperation(c18210764.spop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
-- 作为灵摆卡发动时的代价：chk=0时返回true表示满足发动代价；实际发动时给本卡注册一个‘已发动’标记（FlagEffect 18210764），该标记在结束阶段重置，并带EFFECT_FLAG_OATH（誓约标记），用来限定‘这张卡发动的回合’才能使用灵摆效果①，且配合一回合一次限制。
function c18210764.reg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:GetHandler():RegisterFlagEffect(18210764,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- 灵摆效果①的发动条件：检查本卡是否持有“已发动”标记（即本回合这张卡作为灵摆卡发动过）。只有在该回合的主要阶段且标记存在时才能发动。
function c18210764.tecon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(18210764)>0
end
-- 选择对象的过滤条件：对象必须是灵摆怪兽，且位于自己墓地（任意）或自己除外区（仅限表侧表示，因为里侧除外不能确认是否为灵摆怪兽），并且卡名不是「灵摆多福鸟」。
function c18210764.tefilter(c)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsType(TYPE_PENDULUM)
		and not c:IsCode(18210764)
end
-- 发动时的目标选择流程：若检查对象合法性，则验证对象位于自己墓地/除外区、控制者是自己且满足tefilter；若无合法对象则不能发动；否则提示玩家选择1张符合条件的卡，将选中卡设为效果对象，并登记操作信息：该卡将加入额外卡组；若对象在墓地，同时登记涉及墓地卡移动的信息以应对“王家长眠之谷”等限制。
function c18210764.tetg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and c18210764.tefilter(chkc) end
	-- 发动条件判定：确认自己墓地或除外区存在至少1张满足tefilter的灵摆怪兽可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c18210764.tefilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	-- 向玩家显示选择提示，提示文案为“请选择要加入自己的额外卡组的卡”，用于接下来的选卡界面。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(18210764,1))  --"请选择要加入自己的额外卡组的卡"
	-- 让玩家从自己墓地或除外区选择1张满足tefilter的灵摆怪兽作为效果对象；Duel.SelectTarget会自动把所选卡与当前连锁建立联系。
	local g=Duel.SelectTarget(tp,c18210764.tefilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	-- 登记操作信息：本效果处理将把1张对象卡加入额外卡组（CATEGORY_TOEXTRA），为后续时点/效果检测提供依据。
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,g,1,0,0)
	if g:GetFirst():IsLocation(LOCATION_GRAVE) then
		-- 如果选择的对象位于墓地，额外登记操作信息为涉及墓地卡离开墓地（CATEGORY_LEAVE_GRAVE），以正确联动「王家长眠之谷」等影响墓地卡移动的效果。
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	end
end
-- 效果处理：获取本效果的对象卡，若该卡仍与效果有联系（未被无效、未离场等），则将其以表侧表示加入其持有者的额外卡组。
function c18210764.teop(e,tp,eg,ep,ev,re,r,rp)
	-- 取出当前连锁中本效果确定的唯一对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以表侧表示送往其持有者的额外卡组，原因记为效果（REASON_EFFECT），实现‘表侧表示加入自己的额外卡组’。
		Duel.SendtoExtraP(tc,nil,REASON_EFFECT)
	end
end
-- 额外卡组特召的候选过滤函数：候选卡需为表侧表示、灵摆怪兽、等级1、卡名不是「灵摆多福鸟」，且能够被当前效果特殊召唤；此外，从额外卡组特召到场上需要有可用主怪兽区空格（用Duel.GetLocationCountFromEx检查）。
function c18210764.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsLevel(1)
		-- 过滤条件后半段：排除同名卡「灵摆多福鸟」；确认该卡可被效果特殊召唤；并且己方场上有足够空格可以容纳从额外卡组来的这只怪兽。
		and not c:IsCode(18210764) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 怪兽效果①的发动条件与目标：检查己方额外卡组是否存在至少1张满足spfilter的表侧表示灵摆怪兽；若存在则登记操作信息：本效果进行1次从额外卡组的特殊召唤。
function c18210764.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件判定：确认己方额外卡组中有1张符合条件的表侧表示1星灵摆怪兽可以特殊召唤。
	if chk==0 then return Duel.IsExistingMatchingCard(c18210764.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 登记操作信息：本效果处理时将从额外卡组特殊召唤1只怪兽（CATEGORY_SPECIAL_SUMMON，来源LOCATION_EXTRA）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：从额外卡组选择1只符合条件的灵摆怪兽特殊召唤；成功后给该怪兽附加一个不可无效的‘离场时改为除外’的效果，该效果在怪兽离场时重置。
function c18210764.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示选择提示“请选择要特殊召唤的卡”，用于从额外卡组选择要特召的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从己方额外卡组的表侧灵摆怪兽中选择1张满足spfilter的卡作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c18210764.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	-- 若仍有可选卡且特殊召唤成功（返回实际特召数量不为0），则继续为特召出的怪兽附加离场除外的效果；若特召未成功则不附加。
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- “这个效果特殊召唤的怪兽从场上离开的场合除外。”
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		g:GetFirst():RegisterEffect(e1,true)
	end
end
