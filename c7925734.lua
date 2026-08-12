--リンクアップル
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：把手卡的这张卡给对方观看才能发动。自己的额外卡组的里侧表示的卡随机选1张除外。除外的卡是连接怪兽的场合，这张卡特殊召唤。不是的场合，这张卡从手卡丢弃，自己从卡组抽1张。
function c7925734.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：把手卡的这张卡给对方观看才能发动。自己的额外卡组的里侧表示的卡随机选1张除外。除外的卡是连接怪兽的场合，这张卡特殊召唤。不是的场合，这张卡从手卡丢弃，自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(7925734,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_HANDES_SELF+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,7925734)
	e1:SetCost(c7925734.spcost)
	e1:SetTarget(c7925734.sptg)
	e1:SetOperation(c7925734.spop)
	c:RegisterEffect(e1)
end
-- 效果发动Cost：检查手牌的这张卡是否未给对方观看（未公开状态）
function c7925734.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 过滤函数：筛选额外卡组里侧表示且可以除外的卡
function c7925734.rmfilter(c)
	return c:IsFacedown() and c:IsAbleToRemove()
end
-- 效果发动准备：检查额外卡组是否有里侧卡、玩家是否能抽卡、是否有怪兽区域空位、自身是否能特殊召唤
function c7925734.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己额外卡组是否存在至少1张里侧表示且可以除外的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c7925734.rmfilter,tp,LOCATION_EXTRA,0,1,nil)
		-- 检查自己是否可以抽卡，且自己场上是否有可用的怪兽区域
		and Duel.IsPlayerCanDraw(tp,1) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理的操作信息：从额外卡组除外1张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：洗切额外卡组并随机除外1张里侧卡，根据除外卡是否为连接怪兽，执行特殊召唤或丢弃并抽卡
function c7925734.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取自己额外卡组所有里侧表示且可以除外的卡片组
	local g=Duel.GetMatchingGroup(c7925734.rmfilter,tp,LOCATION_EXTRA,0,nil)
	if g:GetCount()==0 then return end
	-- 洗切自己的额外卡组
	Duel.ShuffleExtra(tp)
	local tc=g:RandomSelect(tp,1):GetFirst()
	-- 将随机选出的卡表侧表示除外，并确认其已成功移至除外区
	if Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_REMOVED)
		and c:IsRelateToEffect(e) then
		if tc:IsType(TYPE_LINK) then
			-- 中断当前效果处理，使后续的特殊召唤不与除外同时处理
			Duel.BreakEffect()
			-- 将手牌的这张卡表侧表示特殊召唤
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		else
			-- 中断当前效果处理，使后续的丢弃与抽卡不与除外同时处理
			Duel.BreakEffect()
			-- 将手牌的这张卡作为效果丢弃送去墓地，并确认是否成功送墓
			if Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT+REASON_DISCARD)~=0 then
				-- 从卡组抽1张卡
				Duel.Draw(tp,1,REASON_EFFECT)
			end
		end
	end
end
