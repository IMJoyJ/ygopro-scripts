--ガガガマジシャン－ガガガマジック
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡在手卡存在的场合才能发动。「我我我魔术师-我我我魔导」以外的自己的手卡·墓地1只「刷拉拉」、「我我我」、「隆隆隆」、「怒怒怒」怪兽和这张卡特殊召唤，只用那2只为素材进行1只「刷拉拉」、「我我我」、「隆隆隆」、「怒怒怒」、「魔人」、「英豪冠军」、「No.」、「异热同心武器」、「异热同心从者」超量怪兽的超量召唤。那个时候，要作为超量素材的1只怪兽的等级当作和另1只怪兽相同等级使用。
local s,id,o=GetID()
-- 注册卡片的效果
function s.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：这张卡在手卡存在的场合才能发动。「我我我魔术师-我我我魔导」以外的自己的手卡·墓地1只「刷拉拉」、「我我我」、「隆隆隆」、「怒怒怒」怪兽和这张卡特殊召唤，只用那2只为素材进行1只「刷拉拉」、「我我我」、「隆隆隆」、「怒怒怒」、「魔人」、「英豪冠军」、「No.」、「异热同心武器」、「异热同心从者」超量怪兽的超量召唤。那个时候，要作为超量素材的1只怪兽的等级当作和另1只怪兽相同等级使用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
-- 改变超量素材等级的辅助函数，使其中一只怪兽的等级当作和另一只怪兽相同等级使用
function s.xyzlv(e,c,rc)
	return e:GetHandler():GetLevel() | (e:GetLabel() << 16)
end
-- 检查额外卡组是否存在可以以指定怪兽组合为素材进行超量召唤的「刷拉拉」、「我我我」、「隆隆隆」、「怒怒怒」、「魔人」、「英豪冠军」、「No.」、「异热同心武器」、「异热同心从者」超量怪兽
function s.xyzfiltr(c,g)
	return c:IsSetCard(0x8f,0x54,0x59,0x82,0x206f,0x6d,0x48,0x107e,0x207e)
		and c:IsXyzSummonable(g,2,2)
end
-- 创建并注册一个使怪兽等级临时变为另一只怪兽等级的超量素材等级变更效果
function s.CreateTempSwapLevelEffect(ec,c1,c2)
	-- 这个卡名的效果1回合只能使用1次。①：这张卡在手卡存在的场合才能发动。「我我我魔术师-我我我魔导」以外的自己的手卡·墓地1只「刷拉拉」、「我我我」、「隆隆隆」、「怒怒怒」怪兽和这张卡特殊召唤，只用那2只为素材进行1只「刷拉拉」、「我我我」、「隆隆隆」、「怒怒怒」、「魔人」、「英豪冠军」、「No.」、「异热同心武器」、「异热同心从者」超量怪兽的超量召唤。那个时候，要作为超量素材的1只怪兽的等级当作和另1只怪兽相同等级使用。
	local e1=Effect.CreateEffect(ec)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_XYZ_LEVEL)
	e1:SetValue(s.xyzlv)
	e1:SetLabel(c2:GetLevel())
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c1:RegisterEffect(e1,true)
	return e1
end
-- 临时将要作为超量素材的2只怪兽的等级当作相同等级使用的辅助处理函数
function s.SetTempSwapLevel(ec,c,callback)
	local e1=nil
	local e2=nil
	if ec:IsLevelAbove(1) then
		e1=s.CreateTempSwapLevelEffect(ec,c,ec)
	end
	if c:IsLevelAbove(1) then
		e2=s.CreateTempSwapLevelEffect(c,ec,c)
	end
	local res,resetflag = callback()
	if resetflag then
		if e1 then e1:Reset() end
		if e2 then e2:Reset() end
	end
	return res
end
-- 过滤手卡或墓地中满足特殊召唤条件的「刷拉拉」、「我我我」、「隆隆隆」、「怒怒怒」怪兽，且与自身作为素材时存在可超量召唤的合法目标
function s.spfilter(c,e,tp,ec)
	if not (not c:IsCode(id) and c:IsSetCard(0x8f,0x54,0x59,0x82) and c:IsLevelAbove(1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)) then return false end
	return s.SetTempSwapLevel(ec,c,function()
		-- 在临时修改等级后，检查额外卡组是否存在可超量召唤的合法怪兽，并返回检查结果及重置标记
		return Duel.IsExistingMatchingCard(s.xyzfiltr,tp,LOCATION_EXTRA,0,1,nil,Group.FromCards(c,ec)), true
	end)
end
-- 效果发动的可行性检测与效果目标处理
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查玩家是否能够进行2个怪兽的特殊召唤
		and Duel.IsPlayerCanSpecialSummonCount(tp,2)
		-- 检查玩家场上是否有2个以上的怪兽区域空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查手牌或墓地是否存在满足特殊召唤及超量召唤条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp,c) end
	-- 设置特殊召唤操作信息（自身特殊召唤）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果处理逻辑，特殊召唤自身及手卡/墓地的怪兽并进行超量召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() then return end
	if not c:IsCanBeSpecialSummoned(e,0,tp,false,false) then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 如果玩家场上的怪兽区域空位不足2个，则直接结束处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 给玩家发送提示信息以选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家选择手卡或墓地中的1只「刷拉拉」、「我我我」、「隆隆隆」、「怒怒怒」怪兽
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp,c):GetFirst()
	if tc then
		local g=Group.FromCards(c,tc)
		-- 如果将这两张卡都成功以表侧表示特殊召唤
		if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)==2
			and g:IsExists(Card.IsLocation,2,nil,LOCATION_MZONE)
			and g:IsExists(Card.IsFaceup,2,nil) then
			s.SetTempSwapLevel(c,tc,function()
				-- 立刻刷新场地信息（确认怪兽状态及等级）
				Duel.AdjustAll()
				-- 获取额外卡组中能够以这两只怪兽为素材进行超量召唤的合法怪兽
				local xyzg=Duel.GetMatchingGroup(s.xyzfiltr,tp,LOCATION_EXTRA,0,nil,g)
				if xyzg:GetCount()>0 then
					-- 给玩家发送提示信息以选择要超量召唤的怪兽
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
					local xyz=xyzg:Select(tp,1,1,nil):GetFirst()
					-- 将这两只怪兽作为素材进行超量召唤
					Duel.XyzSummon(tp,xyz,g)
					return nil, false
				end
				return nil, true
			end)
		end
	end
end
