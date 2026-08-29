--黒薔薇と荊棘の魔女
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡同调召唤的场合才能发动。从卡组·额外卡组各把最多1只植物族怪兽送去墓地。这个效果的发动后，直到回合结束时自己不是同调怪兽不能从额外卡组特殊召唤。
-- ②：自己场上的植物族怪兽不会被效果破坏。
-- ③：这张卡在墓地存在的状态，场上的卡被效果破坏的场合才能发动。这张卡特殊召唤。
local s,id,o=GetID()
-- 初始化卡片的同调召唤手续、苏生限制，并注册①的送墓诱发效果、②的植物族抗性永续效果、③的墓地特殊召唤诱发效果。
function s.initial_effect(c)
	-- 为这张卡添加同调召唤手续：调整＋调整以外的怪兽1只以上（此处为任意调整＋任意调整以外怪兽，至少1只）。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 这个卡名的①③的效果1回合各能使用1次。①：这张卡同调召唤的场合才能发动。从卡组·额外卡组各把最多1只植物族怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"送去墓地"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.tgcon)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	-- ②：自己场上的植物族怪兽不会被效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.indfilter)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 这个卡名的①③的效果1回合各能使用1次。③：这张卡在墓地存在的状态，场上的卡被效果破坏的场合才能发动。这张卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- ①的发动条件：这张卡的这次特殊召唤为同调召唤。
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 筛选满足条件的植物族怪兽：种族为植物且可以送去墓地。
function s.tgfilter(c)
	return c:IsRace(RACE_PLANT) and c:IsAbleToGrave()
end
-- ①的发动目标：获取自己卡组·额外卡组中所有符合条件的植物族怪兽；确认存在至少1张，并登记送去墓地的操作信息。
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己卡组·额外卡组中所有满足s.tgfilter（植物族且可送墓）的怪兽集合。
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_EXTRA+LOCATION_DECK,0,nil)
	if chk==0 then return g:GetCount()>0 end
	-- 登记操作信息：效果处理时将把卡送去墓地，涉及区域为卡组·额外卡组。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_EXTRA+LOCATION_DECK)
end
-- s.lncheck检查所选卡的位置种类数是否等于数量，保证从卡组和额外卡组各最多选1张，不会从同一位置选2张。
function s.lncheck(g)
	return g:GetClassCount(Card.GetLocation)==g:GetCount()
end
-- ①的效果处理：从卡组·额外卡组选择最多2张植物族怪兽（且两个区域各最多1张）送去墓地；之后给发动玩家附加自肃：直到回合结束时，自己不是同调怪兽不能从额外卡组特殊召唤。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，让玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 获取可选的植物族怪兽集合（卡组·额外卡组）。
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_EXTRA+LOCATION_DECK,0,nil)
	-- 设置额外选择限制为s.lncheck，确保从卡组和额外卡组各最多选1张。
	aux.GCheckAdditional=s.lncheck
	-- 让玩家从集合中选择1~2张卡（满足s.lncheck限制），返回选中的组sg。
	local sg=g:SelectSubGroup(tp,aux.TRUE,false,1,2)
	-- 清除额外选择限制，恢复默认选择逻辑。
	aux.GCheckAdditional=nil
	if sg then
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
	-- 对应①的后半句：“这个效果的发动后，直到回合结束时自己不是同调怪兽不能从额外卡组特殊召唤。”；②：“自己场上的植物族怪兽不会被效果破坏。”；③：“这张卡在墓地存在的状态，场上的卡被效果破坏的场合才能发动。这张卡特殊召唤。”
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃效果e1注册到玩家tp（对tp适用）。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃判定：位于额外卡组且不是同步怪兽的卡不能特殊召唤。
function s.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_SYNCHRO)
end
-- ②的判定：植物族怪兽不会被效果破坏。
function s.indfilter(e,c)
	return c:IsRace(RACE_PLANT)
end
-- ③的触发筛选：被破坏的卡必须是因效果破坏且之前位于场上。
function s.sfilter(c)
	return c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- ③的触发条件：本次被破坏的怪兽集合中存在满足s.sfilter的卡，且这张卡（墓地中的此卡）不在被破坏集合中。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.sfilter,1,nil) and not eg:IsContains(e:GetHandler())
end
-- ③的发动目标：检查自己场上有空位且此卡可以被特殊召唤；满足则登记特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时判定：自己主要怪兽区有空位，且此卡能够被特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记操作信息：将特殊召唤此卡的信息加入连锁，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ③的效果处理：若此卡仍与连锁关联且不受王家长眠之谷影响，则将其表侧表示特殊召唤到自己场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否仍与当前连锁关联，且不受王家长眠之谷效果限制。
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将此卡以表侧表示特殊召唤到自己场上，不检查召唤条件与苏生限制。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
