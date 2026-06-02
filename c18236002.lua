--プランキッズ・ランプ
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡作为「调皮宝贝」怪兽的所用融合素材或者所用连接素材送去墓地的场合才能发动。给与对方500伤害。那之后，可以从手卡·卡组把「调皮宝贝·火灯娃」以外的1只「调皮宝贝」怪兽守备表示特殊召唤。
function c18236002.initial_effect(c)
	-- ①：这张卡作为「调皮宝贝」怪兽的所用融合素材或者所用连接素材送去墓地的场合才能发动。给与对方500伤害。那之后，可以从手卡·卡组把「调皮宝贝·火灯娃」以外的1只「调皮宝贝」怪兽守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,18236002)
	e1:SetCondition(c18236002.damcon)
	e1:SetTarget(c18236002.damtg)
	e1:SetOperation(c18236002.damop)
	c:RegisterEffect(e1)
end
-- 判断是否满足发动条件：自身作为「调皮宝贝」怪兽的融合或连接素材送去墓地
function c18236002.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	return c:IsLocation(LOCATION_GRAVE) and rc:IsSetCard(0x120) and r&(REASON_FUSION+REASON_LINK)~=0 and not c:IsReason(REASON_RETURN)
end
-- 设置效果发动的靶向与操作信息，在效果发动时确认会造成伤害
function c18236002.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果分类为给与对方500点生命值伤害的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 过滤条件：手卡·卡组中除「调皮宝贝·火灯娃」以外，可以守备表示特殊召唤的「调皮宝贝」怪兽
function c18236002.spfilter(c,e,tp)
	return c:IsSetCard(0x120) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) and not c:IsCode(18236002)
end
-- 效果处理：给与对方500伤害，之后可选择将手卡·卡组1只「调皮宝贝·火灯娃」以外的「调皮宝贝」怪兽守备表示特殊召唤
function c18236002.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取手卡和卡组中满足特殊召唤过滤条件的「调皮宝贝」怪兽
	local g=Duel.GetMatchingGroup(c18236002.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,nil,e,tp)
	-- 若成功给与伤害，且自己场上有怪兽区域空位、有符合条件的怪兽时，玩家可选择是否特殊召唤
	if Duel.Damage(1-tp,500,REASON_EFFECT)~=0 and #g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(18236002,0)) then  --"是否特殊召唤？"
		-- 中断当前效果，使之后的特殊召唤与伤害不视为同时处理
		Duel.BreakEffect()
		-- 提示玩家选择要特殊召唤的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选定的怪兽以表侧守备表示特殊召唤到自己场上
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
