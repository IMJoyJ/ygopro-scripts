--幻奏の華歌神フラワリング・エトワール
-- 效果：
-- 「幻奏的音姬」怪兽＋「幻奏」怪兽×2
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己·对方回合可以发动。自己场上的「幻奏」怪兽任意数量直到结束阶段除外。那之后，可以让最多有这个效果除外的怪兽数量的对方场上的表侧表示卡回到手卡。
-- ②：融合召唤的表侧表示的这张卡因对方从场上离开的场合才能发动。从卡组·额外卡组把「幻奏的华歌神 花开之埃图瓦勒」以外的1只「幻奏」怪兽特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含融合召唤手续、①效果（自由时点除外并回手）和②效果（融合召唤的此卡因对方离场时特召）
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设定融合召唤素材为1只「幻奏的音姬」怪兽和2只「幻奏」怪兽
	aux.AddFusionProcFunFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x109b),aux.FilterBoolFunction(Card.IsFusionSetCard,0x9b),2,2,true)
	-- ①：自己·对方回合可以发动。自己场上的「幻奏」怪兽任意数量直到结束阶段除外。那之后，可以让最多有这个效果除外的怪兽数量的对方场上的表侧表示卡回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
	-- ②：融合召唤的表侧表示的这张卡因对方从场上离开的场合才能发动。从卡组·额外卡组把「幻奏的华歌神 花开之埃图瓦勒」以外的1只「幻奏」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 过滤自己场上表侧表示、属于「幻奏」系列且可以除外的怪兽
function s.rmfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x9b) and c:IsAbleToRemove()
end
-- ①效果的发动准备，检查自己场上是否存在可除外的「幻奏」怪兽，并设置除外的操作信息
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只表侧表示且可以除外的「幻奏」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 设置效果处理时的操作信息为：从自己场上除外至少1张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_MZONE)
end
-- 过滤对方场上表侧表示且可以送回手牌的卡
function s.rfilter(c)
	return c:IsFaceup() and c:IsAbleToHand()
end
-- ①效果的处理，选择自己场上任意数量的「幻奏」怪兽暂时除外，并根据除外数量选择对方场上的表侧表示卡回到手牌
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有满足除外条件的「幻奏」怪兽
	local g=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_MZONE,0,nil)
	if g:GetCount()==0 then return end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:Select(tp,1,g:GetCount(),nil)
	-- 将选中的怪兽以效果、暂时除外的方式除外，若没有成功除外任何卡则结束处理
	if #sg==0 or Duel.Remove(sg,0,REASON_EFFECT+REASON_TEMPORARY)==0
		or not sg:IsExists(Card.IsLocation,1,nil,LOCATION_REMOVED) then return end
	-- 获取本次操作中实际被除外且目前存在于除外区的卡片组
	local og=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_REMOVED)
	og=og-og:Filter(Card.IsReason,nil,REASON_REDIRECT)
	-- 遍历所有实际被除外的卡片
	for tc in aux.Next(og) do
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
	og:KeepAlive()
	-- ①：自己·对方回合可以发动。自己场上的「幻奏」怪兽任意数量直到结束阶段除外。那之后，可以让最多有这个效果除外的怪兽数量的对方场上的表侧表示卡回到手卡。②：融合召唤的表侧表示的这张卡因对方从场上离开的场合才能发动。从卡组·额外卡组把「幻奏的华歌神 花开之埃图瓦勒」以外的1只「幻奏」怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetLabelObject(og)
	e1:SetCountLimit(1)
	e1:SetCondition(s.retcon)
	e1:SetOperation(s.retop)
	-- 注册在回合结束阶段将除外怪兽返回场上的延迟效果
	Duel.RegisterEffect(e1,tp)
	local ct=#og
	-- 获取对方场上所有表侧表示且可以送回手牌的卡片
	local thg=Duel.GetMatchingGroup(s.rfilter,tp,0,LOCATION_ONFIELD,nil)
	-- 如果有成功除外的怪兽且对方场上有可回手的卡，询问玩家是否发动回手效果
	if ct*#thg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then  --"是否回到手卡？"
		-- 中断当前效果处理，使后续的“回到手卡”处理与前面的“除外”处理不视为同时进行
		Duel.BreakEffect()
		-- 提示玩家选择要返回手牌的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
		local sg2=thg:Select(tp,1,math.min(ct,#thg),nil)
		-- 将选中的对方场上的卡片因效果送回持有者手牌
		Duel.SendtoHand(sg2,nil,REASON_EFFECT)
	end
end
-- 过滤带有此卡效果标记且属于指定玩家控制的卡片
function s.retfilter(c,tp)
	return c:GetFlagEffect(id)~=0 and (not tp or c:IsControler(tp))
end
-- 检查是否存在需要返回场上的卡片，若无则清理卡片组并重置该延迟效果
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetLabelObject():IsExists(s.retfilter,1,nil,nil) then
		e:GetLabelObject():DeleteGroup()
		e:Reset()
		return false
	end
	return true
end
-- 将被除外的怪兽组返回到指定玩家的场上
function s.returngroup(g,tp)
	if #g==0 then return end
	local c
	-- 当需要返回场上的怪兽多于1只且怪兽区有空位时，循环让玩家选择返回场上的顺序
	while #g>1 and Duel.GetMZoneCount(tp)>0 do
		-- 提示玩家选择要返回场上的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
		c=g:Select(tp,1,1,nil):GetFirst()
		-- 将指定的怪兽返回到场上
		Duel.ReturnToField(c)
		g=g-c
	end
	-- 遍历剩余需要返回场上的怪兽
	for oc in aux.Next(g) do
		-- 将剩余的怪兽返回到场上
		Duel.ReturnToField(oc)
	end
end
-- 结束阶段将除外的怪兽返回场上的具体处理，优先处理当前回合玩家的怪兽
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的回合玩家
	local turnp=Duel.GetTurnPlayer()
	local g1=e:GetLabelObject():Filter(s.retfilter,nil,turnp)
	local g2=e:GetLabelObject():Filter(s.retfilter,nil,1-turnp)
	if #g1+#g2==0 then return end
	s.returngroup(g1,turnp)
	s.returngroup(g2,1-turnp)
end
-- ②效果的发动条件：此卡曾是融合召唤且表侧表示存在于自己场上，因对方的操作而离开场上
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP) and c:IsSummonType(SUMMON_TYPE_FUSION) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousControler(tp) and c:GetReasonPlayer()==1-tp
end
-- 过滤卡组或额外卡组中除同名卡以外、可以特殊召唤的「幻奏」怪兽，并检查是否有可用的怪兽区域
function s.spfilter(c,e,tp)
	return not c:IsCode(id) and c:IsSetCard(0x9b) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 若怪兽在卡组，检查主怪兽区是否有空位
		and (c:IsLocation(LOCATION_DECK) and Duel.GetMZoneCount(tp)>0
		-- 若怪兽在额外卡组，检查额外怪兽区或连接端是否有可用于特殊召唤的空位
		or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
end
-- ②效果的发动准备，检查卡组或额外卡组是否存在可特召的「幻奏」怪兽，并设置特殊召唤的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组或额外卡组中存在至少1只满足特召条件的「幻奏」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置效果处理时的操作信息为：从卡组或额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
-- ②效果的处理，从卡组或额外卡组选择1只「幻奏」怪兽特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组或额外卡组选择1只满足条件的「幻奏」怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
