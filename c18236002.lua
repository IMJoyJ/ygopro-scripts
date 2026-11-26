--プランキッズ・ランプ
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡作为「调皮宝贝」怪兽的所用融合素材或者所用连接素材送去墓地的场合才能发动。给与对方500伤害。那之后，可以从手卡·卡组把「调皮宝贝·火灯娃」以外的1只「调皮宝贝」怪兽守备表示特殊召唤。
function c18236002.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：这张卡作为「调皮宝贝」怪兽的所用融合素材或者所用连接素材送去墓地的场合才能发动。给与对方500伤害。那之后，可以从手卡·卡组把「调皮宝贝·火灯娃」以外的1只「调皮宝贝」怪兽守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,18236002)
	e1:SetCondition(c18236002.damcon)
	e1:SetTarget(c18236002.damtg)
	e1:SetOperation(c18236002.damop)
	c:RegisterEffect(e1)
end
-- 检查发动条件：此卡因作为「调皮宝贝」怪兽的融合或连接素材而送去墓地（非从除外区回到墓地）
function c18236002.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	return c:IsLocation(LOCATION_GRAVE) and rc:IsSetCard(0x120) and r&(REASON_FUSION+REASON_LINK)~=0 and not c:IsReason(REASON_RETURN)
end
-- 目标阶段确认：设置给予对方500点效果伤害的操作信息
function c18236002.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记给予对方500点效果伤害的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 过滤可从手卡或卡组表侧守备表示特殊召唤的、除「调皮宝贝·火灯娃」外的「调皮宝贝」怪兽
function c18236002.spfilter(c,e,tp)
	return c:IsSetCard(0x120) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) and not c:IsCode(18236002)
end
-- 效果处理：给予对方500点伤害后，若己方场上有空位且手卡·卡组存在可特召的「调皮宝贝」怪兽，可选择其中1只表侧守备表示特殊召唤
function c18236002.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 从己方手卡和卡组检索满足条件的其他「调皮宝贝」怪兽组成卡片组
	local g=Duel.GetMatchingGroup(c18236002.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,nil,e,tp)
	-- 给予对方500点效果伤害且确实造成伤害后，若存在可特召怪兽与怪兽区空位，询问玩家是否进行特殊召唤
	if Duel.Damage(1-tp,500,REASON_EFFECT)~=0 and #g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(18236002,0)) then  --"是否特殊召唤？"
		-- 插入效果处理间断，使伤害与后续特殊召唤视为不同时处理
		Duel.BreakEffect()
		-- 向己方发送选择要特殊召唤的怪兽的提示
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的怪兽以表侧守备表示特殊召唤到己方场上
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
