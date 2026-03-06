--紅蓮地帯を飛ぶ鷹
-- 效果：
-- 这张卡被同调怪兽的同调召唤使用送去墓地的场合自己墓地有名字带有「熔岩」的怪兽3种类以上存在的场合，这张卡可以在自己场上特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合从游戏中除外。
function c26381750.initial_effect(c)
	-- 创建一个诱发选发效果，用于在特定条件下特殊召唤此卡
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(26381750,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetCondition(c26381750.spcon)
	e1:SetTarget(c26381750.sptg)
	e1:SetOperation(c26381750.spop)
	c:RegisterEffect(e1)
end
-- 效果发动条件：此卡在墓地且因同调召唤被作为素材
function c26381750.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
		-- 满足条件：自己墓地名字带有「熔岩」的怪兽种类数不少于3种
		and Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_GRAVE,0,nil,0x39):GetClassCount(Card.GetCode)>=3
end
-- 效果处理条件：场上存在空位且此卡可被特殊召唤
function c26381750.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置此效果的处理信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理函数：检查墓地熔岩怪兽种类数，若满足则特殊召唤此卡并设置离场时除外效果
function c26381750.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若墓地熔岩怪兽种类数少于3种则不执行效果
	if Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_GRAVE,0,nil,0x39):GetClassCount(Card.GetCode)<3 then return end
	local c=e:GetHandler()
	-- 确认此卡存在于场上且成功特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 此卡从场上离开时从游戏中除外
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
