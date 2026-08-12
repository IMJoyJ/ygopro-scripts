--QQエニアゴン
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡在手卡·墓地存在的场合，把「QQ九角火龙」以外的手卡1只9星怪兽给对方观看才能发动。这张卡和给人观看的怪兽共2只守备表示特殊召唤。这个效果的发动后，直到回合结束时自己不是9阶以上的超量怪兽不能从额外卡组特殊召唤。
-- ②：有这张卡在作为超量素材中的9阶以上的超量怪兽得到以下效果。
-- ●这张卡的攻击力·守备力上升900。
local s,id,o=GetID()
-- 注册卡片效果：①手卡·墓地起动效果（特殊召唤自身和手卡1只9星怪兽）；②作为9阶以上超量怪兽的超量素材时使其攻防上升900。
function s.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡在手卡·墓地存在的场合，把「QQ九角火龙」以外的手卡1只9星怪兽给对方观看才能发动。这张卡和给人观看的怪兽共2只守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：有这张卡在作为超量素材中的9阶以上的超量怪兽得到以下效果。●这张卡的攻击力·守备力上升900。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))  --"「QQ九角火龙」效果适用中"
	e2:SetType(EFFECT_TYPE_XMATERIAL)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(900)
	e2:SetCondition(s.gfcon)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
end
-- 过滤函数：筛选手卡中「QQ九角火龙」以外的、可以守备表示特殊召唤的9星怪兽。
function s.spfilter(c,e,tp)
	return not c:IsCode(id) and c:IsLevel(9) and not c:IsPublic()
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果①的发动准备与合法性检测：检查是否不受青眼精灵龙限制、怪兽区域是否有2个以上空位、自身是否能特殊召唤，以及手卡是否存在满足条件的9星怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己场上的主要怪兽区域是否有2个以上的空位。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		-- 检查手卡中是否存在至少1只满足过滤条件的9星怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 向玩家发送选择要特殊召唤的卡片的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只满足过滤条件的9星怪兽。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	-- 将选中的手卡怪兽给对方确认（观看）。
	Duel.ConfirmCards(1-tp,g)
	-- 洗切玩家的手卡。
	Duel.ShuffleHand(tp)
	g:GetFirst():CreateEffectRelation(e)
	e:SetLabelObject(g:GetFirst())
	g:AddCard(c)
	-- 设置特殊召唤2只怪兽的连锁操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,0,0)
end
-- 效果①的效果处理：若自身和展示的怪兽均满足特殊召唤条件，且场上有足够空位，则将它们守备表示特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133) and Duel.GetLocationCount(tp,LOCATION_MZONE)>1 then
		local g=Group.FromCards(c,tc)
		-- 将自身和展示的怪兽以表侧守备表示特殊召唤。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
	-- 这个效果的发动后，直到回合结束时自己不是9阶以上的超量怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTarget(s.splimit)
	-- 注册限制自身特殊召唤的玩家效果。
	Duel.RegisterEffect(e1,tp)
end
-- 限制过滤函数：限制玩家不能从额外卡组特殊召唤9阶以上的超量怪兽以外的怪兽。
function s.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA) and not (c:IsType(TYPE_XYZ) and c:IsRankAbove(9))
end
-- 效果②的适用条件：作为超量素材的怪兽必须是9阶以上的超量怪兽。
function s.gfcon(e)
	local c=e:GetHandler()
	return c:IsType(TYPE_XYZ) and c:IsRankAbove(9)
end
