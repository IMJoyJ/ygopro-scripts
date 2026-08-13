--ジェムナイトレディ・ブリリアント・ダイヤ
-- 效果：
-- 「宝石骑士」怪兽×3
-- 这张卡用以上记的卡为融合素材的融合召唤才能从额外卡组特殊召唤。自己对「宝石骑士女郎·亮钻」1回合只能有1次特殊召唤。
-- ①：1回合1次，自己主要阶段才能发动。自己场上1只表侧表示的「宝石骑士」怪兽送去墓地，从额外卡组把1只「宝石骑士」融合怪兽无视召唤条件特殊召唤。
function c19355597.initial_effect(c)
	c:SetSPSummonOnce(19355597)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：可用任意3只「宝石骑士」怪兽作为融合素材（相同条件，不限定具体卡名），以满足“「宝石骑士」怪兽×3”的融合素材要求。
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x1047),3,false)
	-- 这张卡用以上记的卡为融合素材的融合召唤才能从额外卡组特殊召唤。
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
-- 特殊召唤条件的判定函数：若这张卡不在额外卡组（已在场上等），则允许特殊召唤；若在额外卡组，则必须满足融合召唤方式（SUMMON_TYPE_FUSION）才能特殊召唤，禁止用其他方式从额外卡组特殊召唤。
function c19355597.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA) or bit.band(st,SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
end
-- 选择要送去墓地的「宝石骑士」怪兽的过滤函数：该怪兽须表侧表示且属于「宝石骑士」字段，并且额外卡组有1只符合spfilter条件的融合怪兽可供特殊召唤（即发动条件成立）。
function c19355597.tgfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x1047)
		-- 确认额外卡组存在至少1只满足spfilter过滤条件（即「宝石骑士」融合怪兽且可被特殊召唤）的卡，作为tgfilter的额外判定条件。
		and Duel.IsExistingMatchingCard(c19355597.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
end
-- 选择从额外卡组特殊召唤的「宝石骑士」融合怪兽的过滤函数：须为「宝石骑士」字段、融合怪兽类型，能够被特殊召唤，且将作为素材/送墓的怪兽（tc）离场后，额外怪兽区域仍有空位。
function c19355597.spfilter(c,e,tp,tc)
	return c:IsSetCard(0x1047) and c:IsType(TYPE_FUSION)
		-- 判定该融合怪兽可被特殊召唤（nocheck=true表示不检查召唤条件，即“无视召唤条件”），并且将tc（要送去墓地的怪兽）送墓后腾出的额外怪兽区空格数大于0。
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false) and Duel.GetLocationCountFromEx(tp,tp,tc,c)>0
end
-- 效果发动的目标条件函数：在发动时确认自己场上存在满足tgfilter的怪兽（即表侧表示「宝石骑士」且额外有可特招对象），并登记本次操作信息为从额外卡组特殊召唤1只怪兽。
function c19355597.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时点（chk==0）的合法性检查：只要自己场上存在1只表侧表示的「宝石骑士」怪兽且额外卡组有可特殊召唤的融合怪兽，则效果可以发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c19355597.tgfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 登记连锁处理的操作信息：本效果将进行从额外卡组把1只怪兽特殊召唤的处理，用于响应对应特殊召唤的连锁时点（如星尘龙等）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理函数：玩家选择自己场上1只表侧表示「宝石骑士」怪兽送去墓地，若送墓成功且该卡在墓地中，再从额外卡组选择1只「宝石骑士」融合怪兽无视召唤条件特殊召唤。
function c19355597.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 向操作玩家显示选择提示消息：请选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从自己场上选择1只满足tgfilter的「宝石骑士」怪兽（表侧表示且额外存在可特招对象），作为效果处理中送去墓地的卡。
	local tg=Duel.SelectMatchingCard(tp,c19355597.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	local tc=tg:GetFirst()
	-- 判断选择的怪兽确实存在、并且由于效果（REASON_EFFECT）成功送入墓地且现在位于墓地中，才执行后续特殊召唤处理（防止送墓被替代或除外导致无法继续）。
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE) then
		-- 向操作玩家显示选择提示消息：请选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从额外卡组选择1只满足spfilter的「宝石骑士」融合怪兽作为特殊召唤对象。
		local g=Duel.SelectMatchingCard(tp,c19355597.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
		-- 将选中的「宝石骑士」融合怪兽以表侧表示（POS_FACEUP）特殊召唤到自己的主要怪兽区域；nocheck=true表示不检查该怪兽的召唤条件，即无视召唤条件。
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end
