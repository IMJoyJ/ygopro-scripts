--魔轟神獣チャワ
-- 效果：
-- ①：这张卡在手卡存在的场合才能发动。从手卡选1只「魔轰神」怪兽丢弃，这张卡特殊召唤。
function c29905795.initial_effect(c)
	-- ①：这张卡在手卡存在的场合才能发动。从手卡选1只「魔轰神」怪兽丢弃，这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(29905795,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetTarget(c29905795.tg)
	e1:SetOperation(c29905795.op)
	c:RegisterEffect(e1)
end
-- 筛选函数：判断卡片是否为「魔轰神」怪兽，用于选择可丢弃的候选卡。
function c29905795.filter(c)
	return c:IsSetCard(0x35) and c:IsType(TYPE_MONSTER)
end
-- 效果发动的条件判定：自己场上存在可用怪兽区、手牌有可丢弃的「魔轰神」怪兽且此卡可以被特殊召唤时，允许发动。
function c29905795.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域（用于特殊召唤）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在除自身以外满足条件的「魔轰神」怪兽作为丢弃对象。
		and Duel.IsExistingMatchingCard(c29905795.filter,tp,LOCATION_HAND,0,1,e:GetHandler())
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	-- 登记操作信息：标记本效果将特殊召唤此卡，供后续连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：从手卡选择1只「魔轰神」怪兽丢弃，成功后在此卡仍与效果关联时将其特殊召唤。
function c29905795.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取此卡自身（若仍与当前效果关联），用于在可选对象中排除此卡。
	local ec=aux.ExceptThisCard(e)
	-- 获取手卡中所有满足条件的「魔轰神」怪兽（不含此卡），作为丢弃候选集合。
	local g=Duel.GetMatchingGroup(c29905795.filter,tp,LOCATION_HAND,0,ec)
	if #g==0 and ec then
		g:AddCard(ec)
	end
	-- 弹出选择提示，要求玩家从候选中选出1张要丢弃的手牌。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	local tc=g:Select(tp,1,1,nil):GetFirst()
	-- 条件判定：成功丢弃所选卡且此卡仍与效果关联，则继续处理特殊召唤。
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT+REASON_DISCARD)>0 and c:IsRelateToEffect(e) then
		-- 将此卡以表侧攻击表示特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
