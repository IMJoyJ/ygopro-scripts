--プランキッズ・ランプ
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡作为「调皮宝贝」怪兽的所用融合素材或者所用连接素材送去墓地的场合才能发动。给与对方500伤害。那之后，可以从手卡·卡组把「调皮宝贝·火灯娃」以外的1只「调皮宝贝」怪兽守备表示特殊召唤。
function c18236002.initial_effect(c)
	-- 创建一个诱发选发效果，用于处理作为融合或连接素材送去墓地时的伤害与特殊召唤效果
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
-- 效果发动的条件：这张卡作为「调皮宝贝」怪兽的融合或连接素材送去墓地时
function c18236002.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	return c:IsLocation(LOCATION_GRAVE) and rc:IsSetCard(0x120) and r&REASON_FUSION+REASON_LINK~=0
end
-- 设置效果处理时的伤害信息，给与对方500伤害
function c18236002.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息，包含伤害效果
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 筛选手卡和卡组中满足条件的「调皮宝贝」怪兽（排除火灯娃自身）
function c18236002.spfilter(c,e,tp)
	return c:IsSetCard(0x120) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) and not c:IsCode(18236002)
end
-- 执行效果处理：造成500伤害并询问是否特殊召唤符合条件的怪兽
function c18236002.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 检索满足特殊召唤条件的「调皮宝贝」怪兽（不包括火灯娃）
	local g=Duel.GetMatchingGroup(c18236002.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,nil,e,tp)
	-- 判断是否满足发动条件：造成伤害成功、有可特殊召唤的怪兽、场上存在召唤区域、玩家选择特殊召唤
	if Duel.Damage(1-tp,500,REASON_EFFECT)~=0 and #g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(18236002,0)) then  --"是否特殊召唤？"
		-- 中断当前效果处理，使后续效果视为错时处理
		Duel.BreakEffect()
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的怪兽以守备表示特殊召唤到场上
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
