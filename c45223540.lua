--沼地の魔道王
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡在手卡存在的场合才能发动。额外卡组1只融合怪兽给对方观看，那只怪兽有卡名记述的1只融合素材怪兽从卡组除外。那之后，这张卡特殊召唤。这个回合，把这个效果特殊召唤的这张卡作为融合素材的场合，可以当作这个效果除外的怪兽的同名卡使用。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- ①：这张卡在手卡存在的场合才能发动。额外卡组1只融合怪兽给对方观看，那只怪兽有卡名记述的1只融合素材怪兽从卡组除外。那之后，这张卡特殊召唤。这个回合，把这个效果特殊召唤的这张卡作为融合素材的场合，可以当作这个效果除外的怪兽的同名卡使用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
-- 过滤额外卡组中可以通过除外卡组内其记述的融合素材来展示的融合怪兽
function s.ffilter(c,tp)
	-- 怪兽是融合怪兽，且自己的卡组中存在该卡作为融合素材记述的怪兽
	return c:IsType(TYPE_FUSION) and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_DECK,0,1,nil,c)
end
-- 过滤卡组中作为目标融合怪兽的融合素材记述、且可以被除外的怪兽的条件
function s.cfilter(c,tc)
	-- 该卡记述在融合怪兽的融合素材卡名列表中，且可以被除外且是怪兽卡
	return aux.IsMaterialListCode(tc,c:GetCode()) and c:IsAbleToRemove() and c:IsType(TYPE_MONSTER)
end
-- 手卡效果的发动判定与效果分类设置函数
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动判定的第一阶段，检查自己场上是否存在可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 且额外卡组中存在可以展示且有其素材存在于卡组中的融合怪兽
		and Duel.IsExistingMatchingCard(s.ffilter,tp,LOCATION_EXTRA,0,1,nil,tp) end
	-- 设置效果处理的连锁操作信息，为特殊召唤手牌中的这张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 设置效果处理的连锁操作信息，为从卡组除外1张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
-- 手卡特殊召唤并除外卡组素材效果的处理主函数
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 向当前玩家提示选择给对方确认的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 玩家从自己的额外卡组选择1只满足条件的融合怪兽
	local tc=Duel.SelectMatchingCard(tp,s.ffilter,tp,LOCATION_EXTRA,0,1,1,nil,tp):GetFirst()
	if tc then
		-- 向对方玩家展示选择的融合怪兽
		Duel.ConfirmCards(1-tp,tc)
		-- 向当前玩家提示选择要除外的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 玩家从自己的卡组选择1只记述在该融合怪兽上的融合素材怪兽
		local sg=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_DECK,0,1,1,nil,tc)
		local sc=sg:GetFirst()
		-- 如果成功将所选的卡组怪兽表侧表示除外，且手牌中的这张卡仍能正常处理
		if sc and Duel.Remove(sc,POS_FACEUP,REASON_EFFECT)~=0 and c:IsRelateToChain()
			-- 且这张卡从手牌成功以表侧表示特殊召唤
			and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
			-- 这个回合，把这个效果特殊召唤的这张卡作为融合素材的场合，可以当作这个效果除外的怪兽的同名卡使用。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(aux.Stringid(id,1))  --"「沼地的魔道王」效果适用中"
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_ADD_FUSION_CODE)
			e1:SetProperty(EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetRange(LOCATION_MZONE)
			e1:SetValue(sc:GetCode())
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			c:RegisterEffect(e1)
		end
	end
end
