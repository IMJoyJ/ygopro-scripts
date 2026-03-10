--深淵の相剣龍
-- 效果：
-- 这张卡不能通常召唤，用幻龙族怪兽的效果才能特殊召唤。这个卡名的①②的效果1回合各能使用1次。
-- ①：卡的效果让怪兽被表侧除外的场合才能发动。这张卡从手卡·墓地特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
-- ②：这张卡特殊召唤的场合，以场地区域1张卡和对方的场上·墓地1只怪兽为对象才能发动。那些卡除外。
local s,id,o=GetID()
-- 初始化卡片效果，注册三个效果：墓地状态检查、除外时特殊召唤、特殊召唤成功时除外效果
function s.initial_effect(c)
	-- 为该卡注册一个监听送入墓地事件的单次持续效果，用于判断是否从墓地发动效果
	local e0=aux.AddThisCardInGraveAlreadyCheck(c)
	-- 设置该卡的特殊召唤条件，必须由幻龙族怪兽的效果特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(s.splimit)
	c:RegisterEffect(e1)
	-- 设置①效果：卡的效果让怪兽被表侧除外时才能发动，从手卡或墓地特殊召唤，且特殊召唤的这张卡离开场上的场合除外
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
	-- 设置②效果：这张卡特殊召唤成功时发动，选择场地区域1张卡和对方场上·墓地1只怪兽除外
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
-- 判断特殊召唤条件是否满足，即由幻龙族怪兽的效果特殊召唤
function s.splimit(e,se,sp,st)
	return se:IsActiveType(TYPE_MONSTER) and se:GetHandler():IsRace(RACE_WYRM)
end
-- 过滤被除外的怪兽，确保是表侧表示的怪兽且因效果被除外
function s.egfilter(c,se)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsReason(REASON_EFFECT)
		and (not c:IsPreviousLocation(LOCATION_ONFIELD) or (c:GetPreviousTypeOnField()&TYPE_MONSTER>0 and not c:IsPreviousLocation(LOCATION_SZONE)))
		and (se==nil or c:GetReasonEffect()~=se)
end
-- 判断是否满足①效果发动条件，即是否有符合条件的怪兽被除外
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local se=e:GetLabelObject():GetLabelObject()
	return eg:IsExists(s.egfilter,1,nil,se)
end
-- 设置①效果的发动条件和目标，检查是否有足够的召唤位置并能特殊召唤该卡
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否满足①效果的发动条件，即是否有足够的召唤位置且该卡可以被特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置①效果的发动信息，表示将要特殊召唤该卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 处理①效果的发动，执行特殊召唤并设置离开场上时除外的效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查该卡是否与效果相关联且能否进行特殊召唤步骤
	if c:IsRelateToEffect(e) and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		c:CompleteProcedure()
		-- 为特殊召唤的卡设置离开场上时自动除外的效果，确保其被除外
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
	-- 完成特殊召唤流程，结束特殊召唤步骤
	Duel.SpecialSummonComplete()
end
-- 检查所选卡片组中是否包含场地区域的卡
function s.gcheck(sg)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_FZONE)==1
end
-- 过滤可被除外的卡片，包括场地区域和对方怪兽区/墓地的怪兽
function s.rmfilter(c,e)
	if not c:IsCanBeEffectTarget(e) or not c:IsAbleToRemove() then return false end
	return c:IsLocation(LOCATION_FZONE+LOCATION_MZONE) or c:IsType(TYPE_MONSTER)
end
-- 设置②效果的目标选择逻辑，筛选符合条件的卡片并提示选择
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取所有符合条件的可除外卡片组，包括场地区域和对方场上·墓地的怪兽
	local g=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_FZONE,LOCATION_FZONE+LOCATION_MZONE+LOCATION_GRAVE,nil,e)
	if chk==0 then return g:CheckSubGroup(s.gcheck,2,2) end
	-- 向玩家发送提示信息，提示选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:SelectSubGroup(tp,s.gcheck,false,2,2)
	-- 设置当前连锁的目标卡片为所选的卡片组
	Duel.SetTargetCard(sg)
	-- 设置②效果的发动信息，表示将要除外这些卡片
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,sg,#sg,0,0)
end
-- 处理②效果的发动，执行除外操作
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标卡片，并筛选出与效果相关的卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if #g>0 then
		-- 将目标卡片组以外除
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
