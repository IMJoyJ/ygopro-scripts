--ジェムナイトレディ・ブリリアント・ダイヤ
-- 效果：
-- 「宝石骑士」怪兽×3
-- 这张卡用以上记的卡为融合素材的融合召唤才能从额外卡组特殊召唤。自己对「宝石骑士女郎·亮钻」1回合只能有1次特殊召唤。
-- ①：1回合1次，自己主要阶段才能发动。自己场上1只表侧表示的「宝石骑士」怪兽送去墓地，从额外卡组把1只「宝石骑士」融合怪兽无视召唤条件特殊召唤。
function c19355597.initial_effect(c)
	c:SetSPSummonOnce(19355597)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用3个「宝石骑士」融合怪兽为融合素材进行融合召唤
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x1047),3,false)
	-- ①：1回合1次，自己主要阶段才能发动。自己场上1只表侧表示的「宝石骑士」怪兽送去墓地，从额外卡组把1只「宝石骑士」融合怪兽无视召唤条件特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c19355597.splimit)
	c:RegisterEffect(e1)
	-- ①：1回合1次，自己主要阶段才能发动。自己场上1只表侧表示的「宝石骑士」怪兽送去墓地，从额外卡组把1只「宝石骑士」融合怪兽无视召唤条件特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c19355597.sptg)
	e2:SetOperation(c19355597.spop)
	c:RegisterEffect(e2)
end
-- 限制此卡只能通过融合召唤从额外卡组特殊召唤
function c19355597.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA) or bit.band(st,SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
end
-- 筛选场上1只表侧表示的「宝石骑士」怪兽，且该怪兽存在可特殊召唤的「宝石骑士」融合怪兽
function c19355597.tgfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x1047)
		-- 确保场上选中的「宝石骑士」怪兽可以发动效果，即存在可特殊召唤的「宝石骑士」融合怪兽
		and Duel.IsExistingMatchingCard(c19355597.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
end
-- 筛选额外卡组中1只「宝石骑士」融合怪兽，满足特殊召唤条件且有召唤空位
function c19355597.spfilter(c,e,tp,tc)
	return c:IsSetCard(0x1047) and c:IsType(TYPE_FUSION)
		-- 确保该「宝石骑士」融合怪兽可以被特殊召唤且场上存在召唤空位
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false) and Duel.GetLocationCountFromEx(tp,tp,tc,c)>0
end
-- 设置效果发动时的处理信息，确定将要特殊召唤的卡的数量和位置
function c19355597.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件，即场上存在符合条件的「宝石骑士」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c19355597.tgfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表示将要特殊召唤1只额外卡组的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 执行效果处理，先选择1只怪兽送去墓地，再从额外卡组特殊召唤1只融合怪兽
function c19355597.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择场上1只符合条件的「宝石骑士」怪兽送去墓地
	local tg=Duel.SelectMatchingCard(tp,c19355597.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	local tc=tg:GetFirst()
	-- 确认所选怪兽成功送去墓地后，继续执行后续处理
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE) then
		-- 提示玩家选择要特殊召唤的融合怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从额外卡组选择1只符合条件的「宝石骑士」融合怪兽
		local g=Duel.SelectMatchingCard(tp,c19355597.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
		-- 将选中的融合怪兽无视召唤条件特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end
