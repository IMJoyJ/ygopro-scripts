--ロード・ウォリアー
-- 效果：
-- 「王道同调士」＋调整以外的怪兽2只以上
-- ①：1回合1次，自己主要阶段才能发动。从卡组把1只2星以下的战士族·机械族怪兽特殊召唤。
function c2322421.initial_effect(c)
	-- 为怪兽添加允许使用的素材代码列表，指定素材必须为卡号71971554
	aux.AddMaterialCodeList(c,71971554)
	-- 设置该怪兽的同调召唤手续，要求1只调整（满足tfilter条件）+2只调整以外的怪兽
	aux.AddSynchroProcedure(c,c2322421.tfilter,aux.NonTuner(nil),2)
	c:EnableReviveLimit()
	-- ①：1回合1次，自己主要阶段才能发动。从卡组把1只2星以下的战士族·机械族怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2322421,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c2322421.tg)
	e1:SetOperation(c2322421.op)
	c:RegisterEffect(e1)
end
c2322421.material_setcode=0x1017
-- tfilter函数用于判断是否为调整或具有特定效果的怪兽（卡号20932152的效果）
function c2322421.tfilter(c)
	return c:IsCode(71971554) or c:IsHasEffect(20932152)
end
-- filter函数用于筛选满足条件的怪兽：等级不超过2星、种族为战士族或机械族、可以被特殊召唤
function c2322421.filter(c,e,tp)
	return c:IsLevelBelow(2) and c:IsRace(RACE_WARRIOR+RACE_MACHINE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- tg函数用于判断效果是否可以发动：检查场上是否有空位且卡组中是否存在满足条件的怪兽
function c2322421.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有空位用于特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家卡组中是否存在至少1张满足filter条件的怪兽
		and Duel.IsExistingMatchingCard(c2322421.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果发动时的操作信息，表示将从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- op函数用于执行效果的处理流程：选择并特殊召唤满足条件的怪兽
function c2322421.op(e,tp,eg,ep,ev,re,r,rp)
	-- 再次检查场上是否有空位，若无则不执行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1张满足filter条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c2322421.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
