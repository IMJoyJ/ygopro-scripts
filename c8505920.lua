--合体魔神－ゲート・ガーディアン
-- 效果：
-- 「雷魔神-桑迦」＋「风魔神-修迦」＋「水魔神-斯迦」
-- 把自己的手卡·场上·墓地的上记的卡除外的场合才能特殊召唤。这个卡名的①的效果1回合可以使用最多3次。
-- ①：自己场上的卡为对象的效果由对方发动时才能发动。那个效果无效并破坏。
-- ②：特殊召唤的表侧表示的这张卡因对方从场上离开的场合才能发动。从卡组·额外卡组把1只11星以下的「门之守护神」怪兽无视召唤条件特殊召唤。
function c8505920.initial_effect(c)
	c:EnableReviveLimit()
	-- 设定融合素材为「雷魔神-桑迦」＋「风魔神-修迦」＋「水魔神-斯迦」
	aux.AddFusionProcCode3(c,25955164,62340868,98434877,true,true)
	-- 设定接触融合的特殊召唤手续：将自己手卡·场上·墓地的上述卡表侧表示除外
	aux.AddContactFusionProcedure(c,Card.IsAbleToRemoveAsCost,LOCATION_ONFIELD+LOCATION_HAND+LOCATION_GRAVE,0,Duel.Remove,POS_FACEUP,REASON_COST)
	-- 把自己的手卡·场上·墓地的上记的卡除外的场合才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 这个卡名的①的效果1回合可以使用最多3次。①：自己场上的卡为对象的效果由对方发动时才能发动。那个效果无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(8505920,0))
	e2:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCountLimit(3,8505920)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c8505920.discon)
	e2:SetTarget(c8505920.distg)
	e2:SetOperation(c8505920.disop)
	c:RegisterEffect(e2)
	-- ②：特殊召唤的表侧表示的这张卡因对方从场上离开的场合才能发动。从卡组·额外卡组把1只11星以下的「门之守护神」怪兽无视召唤条件特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(8505920,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(c8505920.spcon)
	e3:SetTarget(c8505920.sptg)
	e3:SetOperation(c8505920.spop)
	c:RegisterEffect(e3)
end
-- 过滤条件：属于自己且在场上的卡
function c8505920.discfilter(c,tp)
	return c:IsControler(tp) and c:IsOnField()
end
-- 效果①的发动条件判定：对方发动了以自己场上的卡为对象的效果，且该效果可以被无效
function c8505920.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	if rp~=1-tp or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁的对象卡片组
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 判定对象中是否存在自己场上的卡，且该连锁效果可以被无效
	return tg and tg:IsExists(c8505920.discfilter,1,nil,tp) and Duel.IsChainDisablable(ev)
end
-- 效果①的发动准备：设置无效与破坏的操作信息
function c8505920.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：使该连锁的效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：破坏发动该效果的卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果①的效果处理：使对方发动的效果无效并破坏该卡
function c8505920.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 若成功无效该效果，且该卡仍与效果关联
	if Duel.NegateEffect(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏该卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 效果②的发动条件判定：特殊召唤的表侧表示的这张卡因对方从场上离开
function c8505920.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and c:GetReasonPlayer()==1-tp
end
-- 过滤条件：11星以下且可以无视召唤条件特殊召唤的「门之守护神」怪兽
function c8505920.spfilter(c,e,tp)
	return c:IsSetCard(0x1052) and c:IsLevelBelow(11) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
		-- 若从卡组特殊召唤，需自己场上有空余的怪兽区域
		and (c:IsLocation(LOCATION_DECK) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 若从额外卡组特殊召唤，需有可用于额外卡组怪兽出场的空余区域
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
end
-- 效果②的发动准备：检查是否存在可特殊召唤的怪兽并设置特殊召唤的操作信息
function c8505920.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组或额外卡组是否存在满足特殊召唤条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c8505920.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置操作信息：从卡组或额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
-- 效果②的效果处理：从卡组或额外卡组选择1只满足条件的怪兽无视召唤条件特殊召唤
function c8505920.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从卡组或额外卡组选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c8505920.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选择的怪兽无视召唤条件表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end
