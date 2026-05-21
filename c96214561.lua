--招神鳥シムルグ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤成功时才能发动。从卡组把「招神鸟 斯摩夫」以外的1张「斯摩夫」卡加入手卡。
-- ②：这张卡在墓地存在，对方的魔法与陷阱区域没有卡存在的场合才能发动。这张卡守备表示特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。这个效果的发动后，直到回合结束时自己不是鸟兽族怪兽不能特殊召唤。
function c96214561.initial_effect(c)
	-- ①：这张卡召唤成功时才能发动。从卡组把「招神鸟 斯摩夫」以外的1张「斯摩夫」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(96214561,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,96214561)
	e1:SetTarget(c96214561.thtg)
	e1:SetOperation(c96214561.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，对方的魔法与陷阱区域没有卡存在的场合才能发动。这张卡守备表示特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。这个效果的发动后，直到回合结束时自己不是鸟兽族怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(96214561,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,96214562)
	e2:SetCondition(c96214561.spcon)
	e2:SetTarget(c96214561.sptg)
	e2:SetOperation(c96214561.spop)
	c:RegisterEffect(e2)
end
-- 过滤卡组中「招神鸟 斯摩夫」以外的「斯摩夫」卡片
function c96214561.thfilter(c)
	return c:IsSetCard(0x12d) and not c:IsCode(96214561) and c:IsAbleToHand()
end
-- ①号效果的发动准备与效果分类声明
function c96214561.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以加入手卡的「招神鸟 斯摩夫」以外的「斯摩夫」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c96214561.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息，声明该效果包含将卡组的1张卡加入手卡的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①号效果的实际处理（从卡组选择并加入手卡）
function c96214561.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足过滤条件的「斯摩夫」卡
	local g=Duel.SelectMatchingCard(tp,c96214561.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片因效果加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤对方魔法与陷阱区域（不含场地区）的卡片
function c96214561.cfilter(c)
	return c:GetSequence()<5
end
-- ②号效果的发动条件判断（对方魔陷区没有卡存在）
function c96214561.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方的魔法与陷阱区域（第1-5格）是否存在卡片
	return not Duel.IsExistingMatchingCard(c96214561.cfilter,tp,0,LOCATION_SZONE,1,nil)
end
-- ②号效果的发动准备与效果分类声明
function c96214561.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域，且墓地的这张卡是否可以特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置连锁处理的操作信息，声明该效果包含将自身特殊召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②号效果的实际处理（特殊召唤自身、添加离场除外约束及特殊召唤种族限制）
function c96214561.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡仍存在于墓地，则将其以表侧守备表示特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		c:RegisterEffect(e1,true)
	end
	-- 这个效果的发动后，直到回合结束时自己不是鸟兽族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c96214561.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 在全局环境中注册该特殊召唤限制效果，影响玩家自身
	Duel.RegisterEffect(e1,tp)
end
-- 限制不能特殊召唤非鸟兽族的怪兽
function c96214561.splimit(e,c)
	return not c:IsRace(RACE_WINDBEAST)
end
