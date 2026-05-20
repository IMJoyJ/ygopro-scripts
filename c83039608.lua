--魔轟神獣アバンク
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡在墓地存在的场合才能发动。从手卡选1只「魔轰神」怪兽丢弃，这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c83039608.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：这张卡在墓地存在的场合才能发动。从手卡选1只「魔轰神」怪兽丢弃，这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(83039608,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,83039608)
	e1:SetTarget(c83039608.tg)
	e1:SetOperation(c83039608.op)
	c:RegisterEffect(e1)
end
-- 过滤手卡中可以丢弃的「魔轰神」怪兽
function c83039608.dhfilter(c)
	return c:IsSetCard(0x35) and c:IsType(TYPE_MONSTER) and c:IsDiscardable()
end
-- 效果发动的可行性检测（检查怪兽区域空位、手卡是否有可丢弃的「魔轰神」怪兽、自身是否能特殊召唤）
function c83039608.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在至少1只除自身以外可以丢弃的「魔轰神」怪兽
		and Duel.IsExistingMatchingCard(c83039608.dhfilter,tp,LOCATION_HAND,0,1,e:GetHandler())
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	-- 设置连锁处理的操作信息为特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：丢弃手卡的「魔轰神」怪兽，将自身特殊召唤，并添加离场除外的效果
function c83039608.op(e,tp,eg,ep,ev,re,r,rp)
	-- 获取手卡中所有满足条件的「魔轰神」怪兽
	local g=Duel.GetMatchingGroup(c83039608.dhfilter,tp,LOCATION_HAND,0,nil)
	if #g<1 then return end
	if #g==1 then
		-- 将手卡中仅有的1只「魔轰神」怪兽作为效果丢弃送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)
	else
		-- 提示玩家选择要丢弃的手卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
		local sg=g:Select(tp,1,1,e:GetHandler())
		-- 将选中的「魔轰神」怪兽作为效果丢弃送去墓地
		Duel.SendtoGrave(sg,REASON_EFFECT+REASON_DISCARD)
	end
	local c=e:GetHandler()
	-- 检查自身是否仍与效果相关，并以表侧表示特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) then
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
