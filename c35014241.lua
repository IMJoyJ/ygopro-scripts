--リミットオーバー・ドライブ
-- 效果：
-- 「破限疾驰」在1回合只能发动1张。
-- ①：让自己场上1只同调怪兽调整和1只调整以外的同调怪兽回到额外卡组才能发动。和那2只怪兽的等级合计相同等级的1只同调怪兽无视召唤条件从额外卡组特殊召唤。
function c35014241.initial_effect(c)
	-- 「破限疾驰」在1回合只能发动1张。①：让自己场上1只同调怪兽调整和1只调整以外的同调怪兽回到额外卡组才能发动。和那2只怪兽的等级合计相同等级的1只同调怪兽无视召唤条件从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,35014241+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c35014241.cost)
	e1:SetTarget(c35014241.target)
	e1:SetOperation(c35014241.activate)
	c:RegisterEffect(e1)
end
-- 过滤第1只返回额外卡组的素材：必须是表侧表示的同调怪兽且是调整，并可作为代价返回额外卡组；同时场上还存在第2只调整以外的同调怪兽以满足发动条件。
function c35014241.cfilter1(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsType(TYPE_TUNER) and c:IsAbleToExtraAsCost()
		-- 确认场上存在另一只调整以外的同调怪兽，以保证能够凑齐两只返回额外卡组的素材。
		and Duel.IsExistingMatchingCard(c35014241.cfilter2,tp,LOCATION_MZONE,0,1,nil,e,tp,c)
end
-- 过滤第2只返回额外卡组的素材：必须是表侧表示的同调怪兽且不是调整，并可作为代价返回额外卡组；同时额外卡组中存在等级等于两只素材等级合计的同调怪兽可特殊召唤。
function c35014241.cfilter2(c,e,tp,tc)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and not c:IsType(TYPE_TUNER) and c:IsAbleToExtraAsCost()
		-- 确认额外卡组中存在等级为两只素材等级合计、且能特殊召唤的同调怪兽，保证代价支付后必定有目标可特殊召唤。
		and Duel.IsExistingMatchingCard(c35014241.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c:GetLevel()+tc:GetLevel(),Group.FromCards(c,tc))
end
-- 过滤特殊召唤的目标同调怪兽：等级必须与两只素材等级合计相同，无视召唤条件且能被特殊召唤，并且额外怪兽区域有空位。
function c35014241.spfilter(c,e,tp,lv,mg)
	return c:IsType(TYPE_SYNCHRO) and c:IsLevel(lv) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
		-- 检查在素材返回额外卡组后，自己场上是否有足够的额外怪兽区域空格来特殊召唤目标同调怪兽。
		and Duel.GetLocationCountFromEx(tp,tp,mg,c)>0
end
-- 发动代价处理：选择自己场上的1只同调怪兽调整和1只调整以外的同调怪兽返回额外卡组，并将两只怪兽的等级合计存入标签，供后续特殊召唤使用。
function c35014241.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	-- 代价检测：确认自己场上存在至少一组满足条件的素材（同调调整+调整以外的同调），否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c35014241.cfilter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 显示选择提示，提示玩家选择要返回卡组的第1只怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择第1只作为代价的怪兽：自己场上表侧表示的同调怪兽调整。
	local g1=Duel.SelectMatchingCard(tp,c35014241.cfilter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 显示选择提示，提示玩家选择要返回卡组的第2只怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择第2只作为代价的怪兽：自己场上表侧表示、调整以外的同调怪兽，并以第1只怪兽为参数进行条件过滤。
	local g2=Duel.SelectMatchingCard(tp,c35014241.cfilter2,tp,LOCATION_MZONE,0,1,1,nil,e,tp,g1:GetFirst())
	e:SetLabel(g1:GetFirst():GetLevel()+g2:GetFirst():GetLevel())
	g1:Merge(g2)
	-- 将选中的两只同调怪兽返回额外卡组（置于卡组顶端并标记需要洗牌），完成代价支付。
	Duel.SendtoDeck(g1,nil,SEQ_DECKTOP,REASON_COST)
end
-- 效果发动时点确认：检查代价阶段已成功选择素材并记录等级，随后设定本次效果的特殊召唤操作信息。
function c35014241.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		return true
	end
	-- 设置操作信息：本次效果将进行1只同调怪兽的特殊召唤，特殊召唤来源为额外卡组。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理阶段：从额外卡组选择1只等级等于已记录等级合计的同调怪兽，无视召唤条件进行特殊召唤。
function c35014241.activate(e,tp,eg,ep,ev,re,r,rp)
	local lv=e:GetLabel()
	-- 显示选择提示，提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择1只符合条件的同调怪兽（等级与两只素材等级合计相同）作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c35014241.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,lv,nil)
	if g:GetCount()>0 then
		-- 将选择的同调怪兽无视召唤条件、表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end
