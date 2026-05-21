--トリックスター・ヒヨス
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡作为「淘气仙星」连接怪兽的连接素材送去墓地的场合才能发动。这张卡从墓地特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c86825114.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：这张卡作为「淘气仙星」连接怪兽的连接素材送去墓地的场合才能发动。这张卡从墓地特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(86825114,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetCountLimit(1,86825114)
	e1:SetCondition(c86825114.spcon)
	e1:SetTarget(c86825114.sptg)
	e1:SetOperation(c86825114.spop)
	c:RegisterEffect(e1)
end
-- 检查发动条件：这张卡是否作为「淘气仙星」连接怪兽的连接素材送去墓地
function c86825114.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and r==REASON_LINK and c:GetReasonCard():IsSetCard(0xfb)
end
-- 检查发动时的可行性：己方场上有空位且这张卡可以特殊召唤
function c86825114.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查己方主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果处理：将这张卡特殊召唤，并适用离场时除外的效果
function c86825114.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若卡片仍存在于墓地，则将这张卡表侧表示特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
