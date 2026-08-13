--ロード・ウォリアー
-- 效果：
-- 「王道同调士」＋调整以外的怪兽2只以上
-- ①：1回合1次，自己主要阶段才能发动。从卡组把1只2星以下的战士族·机械族怪兽特殊召唤。
function c2322421.initial_effect(c)
	-- 将「王道同调士」的卡名注册为这张卡（王道战士）的同调素材卡名，使其他关联机制能识别该素材。
	aux.AddMaterialCodeList(c,71971554)
	-- 为这张卡添加同调召唤手续：素材必须包含1只满足tfilter（即「王道同调士」或其效果替代）的调整怪兽，调整以外怪兽2只以上。
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
-- 定义同调素材中的调整怪兽过滤条件：该怪兽卡名是「王道同调士」（71971554）或具有效果编号20932152（被当作「王道同调士」使用的调整效果）。
function c2322421.tfilter(c)
	return c:IsCode(71971554) or c:IsHasEffect(20932152)
end
-- 定义被特殊召唤的怪兽过滤条件：等级2以下，属于战士族或机械族，且能够被这次效果特殊召唤。
function c2322421.filter(c,e,tp)
	return c:IsLevelBelow(2) and c:IsRace(RACE_WARRIOR+RACE_MACHINE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动目标的判定：自己主要怪兽区有空位，且卡组中存在符合过滤条件的卡片。
function c2322421.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上主要怪兽区是否有空位，若没有空位则不能发动。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在满足条件的特殊召唤候选卡（1张即可），作为发动条件之一。
		and Duel.IsExistingMatchingCard(c2322421.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置本次连锁的操作信息：将从卡组特殊召唤1只怪兽，用于其他卡的效果互动的判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果的执行处理：再次确认主要怪兽区有空位，让玩家从卡组选择符合条件的怪兽，并将选择的那只怪兽表侧攻击表示特殊召唤到场上。
function c2322421.op(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次检查主要怪兽区是否还有空位，若没有空位则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向当前玩家显示选择提示，提示文字为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 在卡组中筛选并选择1只满足条件的战士族·机械族2星以下怪兽作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c2322421.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到当前玩家场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
