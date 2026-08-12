--幻獣魔王バフォメット
-- 效果：
-- 种族不同的兽族·恶魔族·幻想魔族怪兽×2
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：这张卡的卡名只要在场上·墓地存在当作「有翼幻兽 奇美拉」使用。
-- ②：这张卡融合召唤的场合才能发动。从卡组把1只兽族·恶魔族·幻想魔族怪兽送去墓地。
-- ③：对方回合把墓地的这张卡除外，以「幻兽魔王 巴风特」以外的自己的除外状态的1只兽族·恶魔族·幻想魔族怪兽为对象才能发动。那只怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化函数，注册卡片的效果：包含融合召唤手续、卡名变更、融合召唤成功时送墓以及对方回合除外特召效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，需要2只满足特定过滤条件（种族不同且为兽族/恶魔族/幻想魔族）的怪兽作为素材
	aux.AddFusionProcFunRep(c,s.mfilter,2,true)
	-- 使这张卡在场上·墓地存在时，卡名当作「有翼幻兽 奇美拉」使用
	aux.EnableChangeCode(c,4796100,LOCATION_GRAVE+LOCATION_MZONE)
	-- ②：这张卡融合召唤的场合才能发动。从卡组把1只兽族·恶魔族·幻想魔族怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.tgcon)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	-- ③：对方回合把墓地的这张卡除外，以「幻兽魔王 巴风特」以外的自己的除外状态的1只兽族·恶魔族·幻想魔族怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCondition(s.spcon)
	-- 设置效果的发动成本（Cost）为：把墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 融合素材过滤条件：属于兽族、恶魔族或幻想魔族，且已选素材中不能存在与当前选择怪兽种族相同的怪兽（即种族不同）
function s.mfilter(c,fc,sub,mg,sg)
	return c:IsRace(RACE_BEAST+RACE_FIEND+RACE_ILLUSION) and (not sg
		or not sg:IsExists(Card.IsRace,1,c,c:GetRace()))
end
-- 效果②（送墓效果）的发动条件：这张卡融合召唤成功
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 过滤条件：卡组中属于兽族、恶魔族或幻想魔族且能送去墓地的怪兽
function s.filter(c)
	return c:IsRace(RACE_BEAST+RACE_FIEND+RACE_ILLUSION) and c:IsAbleToGrave()
end
-- 效果②（送墓效果）的发动准备与合法性检测，并设置连锁中的操作信息
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1只满足条件的兽族、恶魔族或幻想魔族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：从卡组将1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果②（送墓效果）的处理：让玩家从卡组选择1只满足条件的怪兽送去墓地
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家从卡组中选择1只满足条件的兽族、恶魔族或幻想魔族怪兽
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选择的怪兽因效果送去墓地
	Duel.SendtoGrave(g,REASON_EFFECT)
end
-- 效果③（特召效果）的发动条件：必须在对方回合
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为对方
	return Duel.GetTurnPlayer()==1-tp
end
-- 过滤条件：除外状态、表侧表示、属于兽族/恶魔族/幻想魔族、可以特殊召唤，且卡名不为「幻兽魔王 巴风特」的怪兽
function s.sfilter(c,e,tp)
	return c:IsFaceup() and c:IsRace(RACE_BEAST+RACE_FIEND+RACE_ILLUSION)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(id)
end
-- 效果③（特召效果）的发动准备、对象选择与合法性检测
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.sfilter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的除外状态中是否存在至少1只满足条件的怪兽可以作为效果对象
		and Duel.IsExistingTarget(s.sfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家选择1只除外状态的满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.sfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置连锁操作信息：将选中的1张卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果③（特召效果）的处理：将作为对象的怪兽特殊召唤到场上
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果处理中被选为对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍符合效果关联，则将其以表侧表示特殊召唤到发动效果玩家的场上
	if tc:IsRelateToEffect(e) then Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) end
end
