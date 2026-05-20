--忍法 落葉舞
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：以自己·对方场上1只「忍者」怪兽或者里侧守备表示怪兽为对象才能把这张卡发动。那只怪兽解放，从卡组把1只「忍者」怪兽特殊召唤。这张卡从场上离开时那只怪兽送去墓地。
-- ②：这张卡表侧表示存在的场合，以自己的魔法与陷阱区域1张「忍法」永续魔法·永续陷阱卡为对象才能发动。那张卡回到持有者手卡。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①效果的发动与离场送墓处理，以及②效果的表侧发动回手牌处理
function s.initial_effect(c)
	-- ①：以自己·对方场上1只「忍者」怪兽或者里侧守备表示怪兽为对象才能把这张卡发动。那只怪兽解放，从卡组把1只「忍者」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- 这张卡从场上离开时那只怪兽送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	-- ②：这张卡表侧表示存在的场合，以自己的魔法与陷阱区域1张「忍法」永续魔法·永续陷阱卡为对象才能发动。那张卡回到持有者手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
-- 过滤条件：场上的表侧表示「忍者」怪兽或里侧守备表示怪兽，且该卡因效果解放后能留出可用的怪兽区域
function s.cfilter(c,tp)
	return (c:IsFaceup() and c:IsSetCard(0x2b) or c:IsPosition(POS_FACEDOWN_DEFENSE))
		-- 判定卡片是否能被效果解放，且该卡解放离开场上后能留出可用的怪兽区域
		and c:IsReleasableByEffect() and Duel.GetMZoneCount(tp,c)>0
end
-- 过滤条件：卡组中可以特殊召唤的「忍者」怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x2b) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动准备与对象选择，检查场上是否有可解放的合法对象以及卡组中是否有可特殊召唤的怪兽
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.cfilter(chkc,tp) end
	-- 检查场上是否存在至少1只满足解放条件的怪兽作为效果对象
	if chk==0 then return Duel.IsExistingTarget(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp)
		-- 检查卡组中是否存在至少1只可以特殊召唤的「忍者」怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 给玩家发送提示信息，提示选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 玩家选择1只满足条件的怪兽作为发动对象
	local g=Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp)
	-- 设置连锁信息，表明此效果包含解放该对象的操作
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,g,1,0,0)
	-- 设置连锁信息，表明此效果包含从卡组特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ①效果的处理：解放作为对象的怪兽，从卡组特殊召唤1只「忍者」怪兽，并建立对象指向关系
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍存在于场上，则将其因效果解放
	if tc:IsRelateToEffect(e) and Duel.Release(tc,REASON_EFFECT)>0
		-- 检查此时自己场上是否有可用的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 给玩家发送提示信息，提示选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 玩家从卡组选择1只满足条件的「忍者」怪兽
		local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
		if not sc then return end
		-- 尝试将选择的怪兽以表侧表示特殊召唤，并建立此卡对该怪兽的对象指向关系
		if Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP) then
			c:SetCardTarget(sc)
		end
		-- 完成特殊召唤的最终处理
		Duel.SpecialSummonComplete()
	end
end
-- 离场时的效果处理：将此卡指向的特殊召唤的怪兽送去墓地
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	-- 若被指向的怪兽仍在怪兽区，则将其送去墓地
	if tc and tc:IsLocation(LOCATION_MZONE) then Duel.SendtoGrave(tc,REASON_EFFECT) end
end
-- ②效果的发动条件：此卡在场上表侧表示存在
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED)
end
-- 过滤条件：自己魔陷区（不含场地区）表侧表示存在的「忍法」永续魔法或永续陷阱卡，且能回到手牌
function s.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x61) and c:IsType(TYPE_CONTINUOUS) and c:GetSequence()<5
		and c:IsAbleToHand()
end
-- ②效果的发动准备与对象选择，检查并选择自己魔陷区1张表侧表示的「忍法」永续魔陷
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	-- 检查自己魔陷区是否存在至少1张满足条件的「忍法」永续魔陷
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_SZONE,0,1,nil) end
	-- 给玩家发送提示信息，提示选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 玩家选择1张满足条件的「忍法」永续魔陷作为发动对象
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_SZONE,0,1,1,nil)
	-- 设置连锁信息，表明此效果包含将选择的卡送回手牌的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果的处理：将作为对象的「忍法」永续魔陷卡回到持有者手卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的「忍法」永续魔陷对象
	local tc=Duel.GetFirstTarget()
	-- 若对象卡仍存在，则将其送回持有者的手牌
	if tc:IsRelateToEffect(e) then Duel.SendtoHand(tc,nil,REASON_EFFECT) end
end
