--雷風魔神－ゲート・ガーディアン
-- 效果：
-- 「雷魔神-桑迦」＋「风魔神-修迦」
-- 把自己场上的上记的卡除外的场合才能特殊召唤。这个卡名的①的效果1回合只能使用1次。
-- ①：自己主要阶段才能发动。把有「雷魔神-桑迦」「风魔神-修迦」「水魔神-斯迦」的卡名全部记述的1张魔法·陷阱卡从卡组加入手卡。
-- ②：特殊召唤的表侧表示的这张卡因对方从场上离开的场合才能发动。自己的除外状态的1只「雷魔神-桑迦」或「风魔神-修迦」特殊召唤。
function c34904525.initial_effect(c)
	c:EnableReviveLimit()
	-- 记录该卡具有「水魔神-斯迦」的卡名
	aux.AddCodeList(c,98434877)
	-- 设置融合召唤需要「雷魔神-桑迦」和「风魔神-修迦」作为融合素材
	aux.AddFusionProcCode2(c,25955164,62340868,true,true)
	-- 添加接触融合的特殊召唤手续，需要将自己场上的怪兽除外作为召唤条件
	aux.AddContactFusionProcedure(c,Card.IsAbleToRemoveAsCost,LOCATION_ONFIELD,0,Duel.Remove,POS_FACEUP,REASON_COST)
	-- 这个卡名的①的效果1回合只能使用1次。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e0)
	-- ①：自己主要阶段才能发动。把有「雷魔神-桑迦」「风魔神-修迦」「水魔神-斯迦」的卡名全部记述的1张魔法·陷阱卡从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(34904525,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,34904525)
	e1:SetTarget(c34904525.thtg)
	e1:SetOperation(c34904525.thop)
	c:RegisterEffect(e1)
	-- ②：特殊召唤的表侧表示的这张卡因对方从场上离开的场合才能发动。自己的除外状态的1只「雷魔神-桑迦」或「风魔神-修迦」特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(34904525,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(c34904525.spcon)
	e2:SetTarget(c34904525.sptg)
	e2:SetOperation(c34904525.spop)
	c:RegisterEffect(e2)
end
-- 检索满足条件的魔法·陷阱卡的过滤函数，要求卡名同时记载「雷魔神-桑迦」「风魔神-修迦」「水魔神-斯迦」
function c34904525.thfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
		-- 过滤函数中检查该卡是否记载了「雷魔神-桑迦」「风魔神-修迦」「水魔神-斯迦」
		and aux.IsCodeListed(c,25955164) and aux.IsCodeListed(c,62340868) and aux.IsCodeListed(c,98434877)
end
-- 设置效果发动时的检索操作信息，确定要从卡组检索1张魔法·陷阱卡加入手牌
function c34904525.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件，即自己卡组中存在满足条件的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c34904525.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，表示将要从卡组检索1张魔法·陷阱卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 处理效果发动时的检索操作，选择并加入手牌，然后确认对方看到该卡
function c34904525.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择满足条件的魔法·陷阱卡
	local tg=Duel.SelectMatchingCard(tp,c34904525.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 如果成功选择并加入手牌，则确认对方看到该卡
	if #tg>0 and Duel.SendtoHand(tg,nil,REASON_EFFECT)>0 then
		-- 确认对方看到该卡
		Duel.ConfirmCards(1-tp,tg)
	end
end
-- 判断该卡是否因对方从场上离开而触发效果，即离开时为特殊召唤且为表侧表示
function c34904525.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and c:GetReasonPlayer()==1-tp
end
-- 特殊召唤过滤函数，筛选可以特殊召唤的「雷魔神-桑迦」或「风魔神-修迦」
function c34904525.spfilter(c,e,tp)
	return c:IsCode(25955164,62340868) and c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果发动时的特殊召唤操作信息，确定要从除外区特殊召唤1只怪兽
function c34904525.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件，即自己场上有足够的特殊召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否满足发动条件，即自己除外区有满足条件的怪兽
		and Duel.IsExistingMatchingCard(c34904525.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表示将要从除外区特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end
-- 处理效果发动时的特殊召唤操作，选择并特殊召唤怪兽
function c34904525.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否满足发动条件，即自己场上有足够的特殊召唤位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从除外区选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c34904525.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
