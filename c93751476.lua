--猛炎星－テンレイ
-- 效果：
-- 这张卡被卡的效果破坏送去墓地的回合的结束阶段时，可以从卡组把「猛炎星-鹿明」以外的1只名字带有「炎星」的4星怪兽特殊召唤。这张卡被名字带有「炎星」的同调怪兽的同调召唤使用送去墓地的场合，可以从卡组选1张名字带有「炎舞」的魔法卡在自己场上盖放。
function c93751476.initial_effect(c)
	-- 这张卡被卡的效果破坏送去墓地的回合的结束阶段时，可以从卡组把「猛炎星-鹿明」以外的1只名字带有「炎星」的4星怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetOperation(c93751476.regop)
	c:RegisterEffect(e1)
	-- 这张卡被名字带有「炎星」的同调怪兽的同调召唤使用送去墓地的场合，可以从卡组选1张名字带有「炎舞」的魔法卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(93751476,1))  --"盖放"
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCondition(c93751476.setcon)
	e2:SetTarget(c93751476.settg)
	e2:SetOperation(c93751476.setop)
	c:RegisterEffect(e2)
end
-- 在送去墓地时，若满足被效果破坏的条件，则注册一个在结束阶段发动的特殊召唤效果
function c93751476.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsReason(REASON_EFFECT) and c:IsReason(REASON_DESTROY) then
		-- 这张卡被卡的效果破坏送去墓地的回合的结束阶段时，可以从卡组把「猛炎星-鹿明」以外的1只名字带有「炎星」的4星怪兽特殊召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(93751476,0))  --"特殊召唤"
		e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetRange(LOCATION_GRAVE)
		e1:SetTarget(c93751476.sptg)
		e1:SetOperation(c93751476.spop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 过滤卡组中卡名不为「猛炎星-鹿明」的4星「炎星」怪兽，且该怪兽可以被特殊召唤
function c93751476.spfilter(c,e,tp)
	return c:IsSetCard(0x79) and c:IsLevel(4) and not c:IsCode(93751476) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的发动准备，检查怪兽区域空位及卡组中是否存在可特召的怪兽，并设置操作信息
function c93751476.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在满足特召条件的「炎星」怪兽
		and Duel.IsExistingMatchingCard(c93751476.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理的分类为从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 特殊召唤效果的实际处理，从卡组选择1只满足条件的「炎星」怪兽特殊召唤到场上
function c93751476.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域空格，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组中选择1只满足特召条件的「炎星」怪兽
	local g=Duel.SelectMatchingCard(tp,c93751476.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 检查此卡是否在墓地，且作为「炎星」同调怪兽的同调素材送去墓地
function c93751476.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
		and e:GetHandler():GetReasonCard():IsSetCard(0x79)
end
-- 过滤卡组中可以盖放的「炎舞」魔法卡
function c93751476.filter(c)
	return c:IsSetCard(0x7c) and c:IsType(TYPE_SPELL) and c:IsSSetable()
end
-- 盖放效果的发动准备，检查卡组中是否存在可盖放的「炎舞」魔法卡
function c93751476.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可盖放的「炎舞」魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c93751476.filter,tp,LOCATION_DECK,0,1,nil) end
end
-- 盖放效果的实际处理，从卡组选择1张「炎舞」魔法卡在场上盖放
function c93751476.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家从卡组中选择1张满足条件的「炎舞」魔法卡
	local g=Duel.SelectMatchingCard(tp,c93751476.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的「炎舞」魔法卡在自己场上盖放
		Duel.SSet(tp,g:GetFirst())
	end
end
