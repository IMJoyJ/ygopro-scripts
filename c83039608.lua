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
-- 丢弃用的过滤函数：判断该卡是否为可以丢弃的「魔轰神」怪兽（种族系列编号0x35）。
function c83039608.dhfilter(c)
	return c:IsSetCard(0x35) and c:IsType(TYPE_MONSTER) and c:IsDiscardable()
end
-- 效果的发动条件判定：要求我方主要怪兽区有空位、手卡有这张卡以外可以丢弃的「魔轰神」怪兽，并且这张卡可以特殊召唤。
function c83039608.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查我方主要怪兽区是否存在可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在这张卡以外至少1只可以丢弃的「魔轰神」怪兽。
		and Duel.IsExistingMatchingCard(c83039608.dhfilter,tp,LOCATION_HAND,0,1,e:GetHandler())
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	-- 设置操作信息：本效果确定要把这张卡从墓地特殊召唤（CATEGORY_SPECIAL_SUMMON）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：从手卡选1只「魔轰神」怪兽丢弃，然后把墓地的这张卡特殊召唤，并赋予其从场上离开时被除外的效果。
function c83039608.op(e,tp,eg,ep,ev,re,r,rp)
	-- 获取手卡中所有满足丢弃条件的「魔轰神」怪兽组成卡组。
	local g=Duel.GetMatchingGroup(c83039608.dhfilter,tp,LOCATION_HAND,0,nil)
	if #g<1 then return end
	if #g==1 then
		-- 手卡中满足条件的卡只有1张时，直接将该卡以效果原因丢弃送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)
	else
		-- 向玩家提示「请选择要丢弃的手牌」。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
		local sg=g:Select(tp,1,1,e:GetHandler())
		-- 将玩家选中的1只「魔轰神」怪兽以效果原因丢弃送去墓地。
		Duel.SendtoGrave(sg,REASON_EFFECT+REASON_DISCARD)
	end
	local c=e:GetHandler()
	-- 若这张卡仍与效果关联，则将其从墓地以正面表示特殊召唤到我方场上，并确认特殊召唤成功。
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
