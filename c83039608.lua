--魔轟神獣アバンク
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡在墓地存在的场合才能发动。从手卡选1只「魔轰神」怪兽丢弃，这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c83039608.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：这张卡在墓地存在的场合才能发动。从手卡选1只「魔轰神」怪兽丢弃，这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(83039608,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_HANDES_SELF)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,83039608)
	e1:SetTarget(c83039608.tg)
	e1:SetOperation(c83039608.op)
	c:RegisterEffect(e1)
end
-- 过滤出玩家手牌中除自身以外的可以作为丢弃代价的「魔轰神」怪兽
function c83039608.dhfilter(c)
	return c:IsSetCard(0x35) and c:IsType(TYPE_MONSTER) and c:IsDiscardable()
end
-- 处理特殊召唤效果发动时的目标检测，确认怪兽区域有空位，且手牌存在可丢弃的「魔轰神」怪兽，且自身可以特殊召唤，并设置特殊召唤的操作信息
function c83039608.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时检测怪兽区域是否存在可用的空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且检测手牌中是否存在除自身以外的「魔轰神」怪兽
		and Duel.IsExistingMatchingCard(c83039608.dhfilter,tp,LOCATION_HAND,0,1,e:GetHandler())
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	-- 设置当前连锁的操作信息为特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 处理从墓地特殊召唤自身的效果，让玩家丢弃1张手牌中的「魔轰神」怪兽并特殊召唤自身，同时为自身注册离场时除外的限制效果
function c83039608.op(e,tp,eg,ep,ev,re,r,rp)
	-- 获取手牌中所有符合条件的「魔轰神」怪兽
	local g=Duel.GetMatchingGroup(c83039608.dhfilter,tp,LOCATION_HAND,0,nil)
	if #g<1 then return end
	if #g==1 then
		-- 如果手牌只有1张符合条件的怪兽，将其丢弃送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)
	else
		-- 提示玩家选择要丢弃的手牌
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
		local sg=g:Select(tp,1,1,e:GetHandler())
		-- 将选中的卡片作为效果丢弃送去墓地
		Duel.SendtoGrave(sg,REASON_EFFECT+REASON_DISCARD)
	end
	local c=e:GetHandler()
	-- 如果这张卡与效果相关联，将其正面表示特殊召唤到场上，并判断是否特召成功
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
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
