--光天使スケール
-- 效果：
-- ①：这张卡特殊召唤成功时才能发动。从手卡把1只「光天使」怪兽特殊召唤。那之后，可以选自己墓地1只光属性怪兽在卡组最上面放置。
-- ②：包含场上的这张卡的怪兽3只以上为素材作超量召唤的怪兽得到以下效果。
-- ●只要持有超量素材的这张卡在怪兽区域存在，每次自己或者对方从手卡把怪兽特殊召唤，自己从卡组抽1张。这个效果1回合只能适用1次。
function c64726269.initial_effect(c)
	-- ①：这张卡特殊召唤成功时才能发动。从手卡把1只「光天使」怪兽特殊召唤。那之后，可以选自己墓地1只光属性怪兽在卡组最上面放置。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(64726269,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(c64726269.sptg)
	e1:SetOperation(c64726269.spop)
	c:RegisterEffect(e1)
	-- ②：包含场上的这张卡的怪兽3只以上为素材作超量召唤的怪兽得到以下效果。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e2:SetCondition(c64726269.effcon)
	e2:SetOperation(c64726269.effop)
	c:RegisterEffect(e2)
end
-- 过滤条件：手卡中可以特殊召唤的「光天使」怪兽
function c64726269.filter(c,e,tp)
	return c:IsSetCard(0x86) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备与合法性检测
function c64726269.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在至少1只满足特殊召唤条件的「光天使」怪兽
		and Duel.IsExistingMatchingCard(c64726269.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，表示将从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 过滤条件：墓地中可以回到卡组的光属性怪兽
function c64726269.tdfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToDeck()
end
-- 效果①的效果处理（特殊召唤手卡怪兽，并可选将墓地光属性怪兽置于卡组最上方）
function c64726269.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有空余的怪兽区域，若无则直接结束处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只满足条件的「光天使」怪兽
	local g=Duel.SelectMatchingCard(tp,c64726269.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		-- 获取自己墓地中满足条件且不受「王家之谷」影响的光属性怪兽
		local sg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c64726269.tdfilter),tp,LOCATION_GRAVE,0,nil)
		-- 若墓地存在符合条件的怪兽，询问玩家是否要将其放置在卡组最上面
		if sg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(64726269,1)) then  --"是否要选墓地1只光属性怪兽在卡组最上面放置？"
			-- 中断当前效果处理，使后续的放置卡组最上方处理不与特殊召唤同时进行
			Duel.BreakEffect()
			-- 提示玩家选择要返回卡组的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
			local tg=sg:Select(tp,1,1,nil)
			-- 为选中的卡片显示被选择的动画效果
			Duel.HintSelection(tg)
			-- 将选中的怪兽放置在持有者卡组的最上面
			Duel.SendtoDeck(tg,nil,SEQ_DECKTOP,REASON_EFFECT)
		end
	end
end
-- 检查是否是以场上的这张卡为素材，且素材数量在3只以上进行的超量召唤
function c64726269.effcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_XYZ and e:GetHandler():GetReasonCard():GetMaterial():IsExists(Card.IsPreviousLocation,3,nil,LOCATION_MZONE)
end
-- 为超量召唤出的怪兽注册获得的效果，若其不是效果怪兽则为其添加效果怪兽类型
function c64726269.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- ●只要持有超量素材的这张卡在怪兽区域存在，每次自己或者对方从手卡把怪兽特殊召唤，自己从卡组抽1张。这个效果1回合只能适用1次。
	local e1=Effect.CreateEffect(rc)
	e1:SetDescription(aux.Stringid(64726269,2))  --"「光天使 天秤」效果适用中"
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CLIENT_HINT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c64726269.drcon)
	e1:SetOperation(c64726269.drop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	if not rc:IsType(TYPE_EFFECT) then
		-- ●只要持有超量素材的这张卡在怪兽区域存在，每次自己或者对方从手卡把怪兽特殊召唤，自己从卡组抽1张。这个效果1回合只能适用1次。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e2,true)
	end
end
-- 检查超量怪兽是否持有超量素材，且是否有怪兽从手卡特殊召唤
function c64726269.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayCount()~=0 and eg:IsExists(Card.IsPreviousLocation,1,nil,LOCATION_HAND)
end
-- 获得效果的抽卡处理
function c64726269.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 向双方玩家展示「光天使 天秤」的卡片发动动画
	Duel.Hint(HINT_CARD,0,64726269)
	-- 让获得效果的超量怪兽的控制者从卡组抽1张卡
	Duel.Draw(tp,1,REASON_EFFECT)
end
