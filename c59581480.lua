--耀聖の波詩ディーナ
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②③的效果1回合各能使用1次。
-- ①：这张卡可以从手卡往自己的中央的主要怪兽区域特殊召唤。
-- ②：自己主要阶段才能发动。从卡组把1张「耀圣」永续魔法卡在自己场上表侧表示放置。
-- ③：对方回合才能发动。自己的主要怪兽区域的这张卡和中央的怪兽的位置交换。那之后，可以把对方手卡随机选1张直到结束阶段表侧除外。
local s,id,o=GetID()
-- 注册卡片效果：①手卡特殊召唤、②放置「耀圣」永续魔法、③交换位置并除外对方手卡。
function s.initial_effect(c)
	-- ①：这张卡可以从手卡往自己的中央的主要怪兽区域特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	e1:SetValue(s.spval)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。从卡组把1张「耀圣」永续魔法卡在自己场上表侧表示放置。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"放置魔法"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.ptg)
	e2:SetOperation(s.pop)
	c:RegisterEffect(e2)
	-- ③：对方回合才能发动。自己的主要怪兽区域的这张卡和中央的怪兽的位置交换。那之后，可以把对方手卡随机选1张直到结束阶段表侧除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"交换位置"
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END+TIMING_END_PHASE)
	e3:SetCondition(s.chcon)
	e3:SetTarget(s.chtg)
	e3:SetOperation(s.chop)
	c:RegisterEffect(e3)
end
-- 手卡特殊召唤效果的条件函数：检查自己场上中央的主要怪兽区域是否可用。
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上中央的主要怪兽区域（第3格/sequence 2）是否有空位。
	return Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,0x4)>0
end
-- 设定特殊召唤的规则：无需解放，且必须召唤到中央的主要怪兽区域（第3格/sequence 2）。
function s.spval(e,c)
	return 0,0x4
end
-- 过滤卡组中满足条件的「耀圣」永续魔法卡。
function s.pfilter(c,tp)
	return c:IsAllTypes(TYPE_CONTINUOUS+TYPE_SPELL) and c:IsSetCard(0x1d8)
		and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- 放置魔法效果的发动准备函数：检查魔陷区空位及卡组中是否存在可放置的卡。
function s.ptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的魔法与陷阱区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查卡组中是否存在满足条件的「耀圣」永续魔法卡。
		and Duel.IsExistingMatchingCard(s.pfilter,tp,LOCATION_DECK,0,1,nil,tp) end
end
-- 放置魔法效果的处理函数：从卡组选择1张「耀圣」永续魔法卡在自己场上表侧表示放置。
function s.pop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上没有可用的魔法与陷阱区域，则不进行处理。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 提示玩家选择要放置到场上的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从卡组中选择1张满足条件的「耀圣」永续魔法卡。
	local tc=Duel.SelectMatchingCard(tp,s.pfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	-- 若成功选择，则将该卡在自己的魔法与陷阱区域表侧表示放置。
	if tc then Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) end
end
-- 交换位置效果的发动条件函数：检查自身是否在主要怪兽区域，且当前是否为对方回合。
function s.chcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回这张卡是否在主要怪兽区域（第1-5格）且当前为对方回合。
	return e:GetHandler():GetSequence()<5 and Duel.GetTurnPlayer()==1-tp
end
-- 过滤位于中央主要怪兽区域（第3格/sequence 2）的怪兽。
function s.chfilter(c)
	return c:GetSequence()==2
end
-- 交换位置效果的发动准备函数：检查中央的主要怪兽区域是否存在除这张卡以外的怪兽。
function s.chtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查中央的主要怪兽区域是否存在其他怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.chfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
end
-- 交换位置效果的处理函数：将这张卡与中央怪兽区域的怪兽交换位置，之后可随机除外对方1张手卡直到结束阶段。
function s.chop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cs=c:GetSequence()
	if not c:IsRelateToChain() or not c:IsControler(tp) or cs>4 or cs==2 then return end
	-- 获取位于中央主要怪兽区域的怪兽。
	local g=Duel.GetMatchingGroup(s.chfilter,tp,LOCATION_MZONE,0,nil)
	if g:GetCount()==1 then
		local tc=g:GetFirst()
		-- 交换这张卡与中央怪兽的位置。
		Duel.SwapSequence(c,tc)
		if c:GetSequence()==cs then return end
		-- 检查对方手卡是否存在可以被除外的卡。
		if Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_HAND,1,nil)
			-- 询问玩家是否选择发动“随机除外对方1张手卡”的效果。
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否除外手卡？"
			-- 中断当前效果处理，使后续的除外处理与位置交换不视为同时进行。
			Duel.BreakEffect()
			-- 提示玩家选择要操作的手卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
			-- 从对方手卡中随机选择1张卡。
			local rg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_HAND,nil):RandomSelect(tp,1)
			-- 向双方玩家展示被随机选中的手卡。
			Duel.HintSelection(rg)
			local rc=rg:GetFirst()
			-- 对选中的手卡进行确认处理（在ygopro中通过送回手卡实现公开）。
			Duel.SendtoHand(rg,nil,REASON_EFFECT)
			-- 将选中的卡片表侧表示除外。
			Duel.Remove(rc,POS_FACEUP,REASON_EFFECT)
			-- 洗切对方的手卡。
			Duel.ShuffleHand(1-tp)
			local fid=c:GetFieldID()
			-- 直到结束阶段表侧除外。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetCountLimit(1)
			e1:SetLabel(fid)
			e1:SetLabelObject(rc)
			e1:SetCondition(s.retcon)
			e1:SetOperation(s.retop)
			e1:SetReset(RESET_PHASE+PHASE_END)
			-- 注册在回合结束阶段适用的延迟效果（用于将被除外的卡送回手卡）。
			Duel.RegisterEffect(e1,tp)
			rc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,fid,aux.Stringid(id,3))  --"直到结束阶段除外"
		end
	end
end
-- 结束阶段效果的条件函数：检查被除外的卡片是否仍带有该效果的标记。
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(id)==e:GetLabel() then
		return true
	else
		e:Reset()
		return false
	end
end
-- 结束阶段效果的处理函数：将被除外的卡片送回对方手卡。
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 在场上显示该卡（狄娜）发动效果的动画提示。
	Duel.Hint(HINT_CARD,0,id)
	local tc=e:GetLabelObject()
	-- 将被除外的卡片送回持有者的手卡。
	Duel.SendtoHand(tc,nil,REASON_EFFECT)
end
