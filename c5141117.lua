--深淵の相剣龍
-- 效果：
-- 这张卡不能通常召唤，用幻龙族怪兽的效果才能特殊召唤。这个卡名的①②的效果1回合各能使用1次。
-- ①：卡的效果让怪兽被表侧除外的场合才能发动。这张卡从手卡·墓地特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
-- ②：这张卡特殊召唤的场合，以场地区域1张卡和对方的场上·墓地1只怪兽为对象才能发动。那些卡除外。
local s,id,o=GetID()
-- 注册该卡的所有效果：e0标记此卡已在墓地；e1规定此卡只能用幻龙族怪兽的效果特殊召唤；e2为①效果（卡的效果让怪兽被表侧除外时，从手卡·墓地特殊召唤并附加离场除外）；e3为②效果（此卡特殊召唤时，取对象除外场上场地卡和对方场上·墓地1只怪兽）。
function s.initial_effect(c)
	-- 为这张卡注册“已在墓地”的标记检测效果，之后可正确判断它作为墓地中的卡的发动状态。
	local e0=aux.AddThisCardInGraveAlreadyCheck(c)
	-- “这张卡不能通常召唤，用幻龙族怪兽的效果才能特殊召唤。”
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(s.splimit)
	c:RegisterEffect(e1)
	-- “①：卡的效果让怪兽被表侧除外的场合才能发动。这张卡从手卡·墓地特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。”
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"这张卡特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_REMOVE)
	e2:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e2:SetLabelObject(e0)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- “②：这张卡特殊召唤的场合，以场地区域1张卡和对方的场上·墓地1只怪兽为对象才能发动。那些卡除外。”
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.rmtg)
	e3:SetOperation(s.rmop)
	c:RegisterEffect(e3)
end
-- 判定进行特殊召唤的效果是否来自幻龙族怪兽的效果，仅当满足时此卡才允许被特殊召唤（对应“用幻龙族怪兽的效果才能特殊召唤”）。
function s.splimit(e,se,sp,st)
	return se:IsActiveType(TYPE_MONSTER) and se:GetHandler():IsRace(RACE_WYRM)
end
-- 筛选满足①触发条件的怪兽：因卡片效果被表侧除外，且若是从场上除外则此前必须是怪兽区表侧怪兽，同时排除由指定效果（se）自身造成的除外。
function s.egfilter(c,se)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsReason(REASON_EFFECT)
		and (not c:IsPreviousLocation(LOCATION_ONFIELD) or (c:GetPreviousTypeOnField()&TYPE_MONSTER>0 and not c:IsPreviousLocation(LOCATION_SZONE)))
		and (se==nil or c:GetReasonEffect()~=se)
end
-- ①效果的发动条件：本连锁的除外集合中存在至少1只满足s.egfilter的怪兽，即存在“卡的效果让怪兽被表侧除外”这一事件。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local se=e:GetLabelObject():GetLabelObject()
	return eg:IsExists(s.egfilter,1,nil,se)
end
-- ①效果发动时的合法性/目标处理：判定自己怪兽区有空位且此卡可以特殊召唤；可行则登记特殊召唤此卡的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 效果发动判定阶段：确认自己场上主要怪兽区有可用空格，并且这张卡能够被特殊召唤（不检查苏生限制等额外条件）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 将当前连锁的操作信息标记为“特殊召唤1张卡”（对象为此卡），供后续相关效果判断。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果处理：若此卡仍与效果关联，则将其特殊召唤，并给它赋予“从场上离开时改为除外”的持续效果；最后完成特殊召唤流程。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否仍与该效果关联（未被无效或未离场），若是则将其以表侧表示特殊召唤到自己的主要怪兽区。
	if c:IsRelateToEffect(e) and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		c:CompleteProcedure()
		-- 这段代码对应效果原文：“这个效果特殊召唤的这张卡从场上离开的场合除外。②：这张卡特殊召唤的场合，以场地区域1张卡和对方的场上·墓地1只怪兽为对象才能发动。那些卡除外。”
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
	-- 完成由 Duel.SpecialSummonStep 开始的分步特殊召唤，触发特殊召唤成功时的相关时点。
	Duel.SpecialSummonComplete()
end
-- 检查选出的2张卡中恰好有1张在场地区，保证符合“场地区域1张卡”的要求。
function s.gcheck(sg)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_FZONE)==1
end
-- ②效果对象筛选：必须是能被取对象且能够除外的卡；且该卡位于场地区域或为怪兽（对方场上·墓地的怪兽及双方场地的场地魔法满足条件）。
function s.rmfilter(c,e)
	if not c:IsCanBeEffectTarget(e) or not c:IsAbleToRemove() then return false end
	return c:IsLocation(LOCATION_FZONE+LOCATION_MZONE) or c:IsType(TYPE_MONSTER)
end
-- ②效果发动时的取对象处理：从候选组中选出2张卡（1张场地卡+1只怪兽），设为对象，并登记除外操作信息。
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取②效果所有可选择的候选对象：己方场地区、对方场地区·怪兽区·墓地区中满足s.rmfilter的卡。
	local g=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_FZONE,LOCATION_FZONE+LOCATION_MZONE+LOCATION_GRAVE,nil,e)
	if chk==0 then return g:CheckSubGroup(s.gcheck,2,2) end
	-- 向当前玩家显示选择除外卡的提示信息（消息文本为“请选择要除外的卡”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:SelectSubGroup(tp,s.gcheck,false,2,2)
	-- 将玩家选中的2张卡设置为当前连锁的取对象对象，使其与②效果建立联系。
	Duel.SetTargetCard(sg)
	-- 登记当前连锁将除外的卡片组及数量（sg），供相关效果检测。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,sg,#sg,0,0)
end
-- ②效果处理：取得本连锁的对象卡，过滤仍与效果关联的卡，并将它们表侧除外。
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理时记录的对象卡组，并过滤出仍然与②效果存在关联的卡（未被无效或离场移除关联）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if #g>0 then
		-- 将关联仍然成立的对象卡以表侧表示除外（处理原因是卡片效果）。
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
