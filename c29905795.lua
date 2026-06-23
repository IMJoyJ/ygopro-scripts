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
-- 过滤函数，用于筛选手卡中属于「魔轰神」的怪兽卡片
function c29905795.filter(c)
	return c:IsSetCard(0x35) and c:IsType(TYPE_MONSTER)
end
-- 效果的发动条件判断函数，检查是否满足特殊召唤的条件
function c29905795.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断玩家场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断玩家手卡中是否存在至少1张「魔轰神」怪兽
		and Duel.IsExistingMatchingCard(c29905795.filter,tp,LOCATION_HAND,0,1,e:GetHandler())
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	-- 设置效果处理时将要特殊召唤的卡片信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果的处理函数，执行特殊召唤的具体操作
function c29905795.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前效果所作用的卡片本身，用于后续判断
	local ec=aux.ExceptThisCard(e)
	-- 获取满足条件的「魔轰神」怪兽数组
	local g=Duel.GetMatchingGroup(c29905795.filter,tp,LOCATION_HAND,0,ec)
	if #g==0 and ec then
		g:AddCard(ec)
	end
	-- 提示玩家选择要丢弃的手牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	local tc=g:Select(tp,1,1,nil):GetFirst()
	-- 将选中的卡片送去墓地并确认效果是否有效
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT+REASON_DISCARD)>0 and c:IsRelateToEffect(e) then
		-- 将自身特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
