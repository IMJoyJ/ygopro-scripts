--紅蓮地帯を飛ぶ鷹
-- 效果：
-- 这张卡被同调怪兽的同调召唤使用送去墓地的场合自己墓地有名字带有「熔岩」的怪兽3种类以上存在的场合，这张卡可以在自己场上特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合从游戏中除外。
function c26381750.initial_effect(c)
	-- 这张卡被同调怪兽的同调召唤使用送去墓地的场合自己墓地有名字带有「熔岩」的怪兽3种类以上存在的场合，这张卡可以在自己场上特殊召唤。
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
-- 特殊召唤效果的发动条件：此卡当前在墓地，且是作为同调怪兽的同调召唤素材被送去墓地，同时自己墓地有「熔岩」怪兽3种类以上。
function c26381750.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
		-- 检查自己墓地中名字带有「熔岩」的怪兽是否按卡名计算达到3种类以上。
		and Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_GRAVE,0,nil,0x39):GetClassCount(Card.GetCode)>=3
end
-- 特殊召唤效果发动时确认：自己场上存在可用的主要怪兽区域，且此卡能够被特殊召唤。
function c26381750.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动检查阶段（chk==0），要求自己场上至少有一个可用的主要怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，标明本效果将把这张卡特殊召唤（数量1），供连锁判定和系统检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理阶段：若墓地「熔岩」怪兽种类仍不少于3，则将此卡特殊召唤；成功后为这张卡附加‘离场时除外’的持续效果。
function c26381750.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认墓地「熔岩」怪兽种类不少于3，若不满足则终止处理。
	if Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_GRAVE,0,nil,0x39):GetClassCount(Card.GetCode)<3 then return end
	local c=e:GetHandler()
	-- 若这张卡仍与效果关联，则将其表侧攻击表示特殊召唤到自己场上；特殊召唤成功时才继续处理离场除外效果。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合从游戏中除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
