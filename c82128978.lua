--リブロマンサー・マジガール
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把手卡1只仪式怪兽给对方观看才能发动。这张卡从手卡特殊召唤。
-- ②：对方回合才能发动。等级合计直到变成仪式召唤的怪兽的等级以上为止，把自己的手卡·场上的怪兽解放，从手卡把1只「书灵师」仪式怪兽仪式召唤。
local s,id,o=GetID()
-- 注册卡片效果：①手卡特殊召唤，②对方回合仪式召唤「书灵师」仪式怪兽
function s.initial_effect(c)
	-- ①：把手卡1只仪式怪兽给对方观看才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 注册一个仪式召唤效果，用于从手卡仪式召唤满足过滤条件的「书灵师」仪式怪兽，解放等级合计直到变成仪式怪兽等级以上
	local e2=aux.AddRitualProcGreater2(c,s.ritfilter,LOCATION_HAND,nil,nil,true)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.ritcond)
	c:RegisterEffect(e2)
end
-- 效果②的发动条件判定函数：当前回合不是自己的回合（即对方回合）
function s.ritcond(e,tp)
	-- 检查当前回合玩家是否不等于效果发动者，即是否为对方回合
	return Duel.GetTurnPlayer()~=tp
end
-- 仪式召唤的目标过滤函数：必须是「书灵师」字段的卡
function s.ritfilter(c)
	return c:IsSetCard(0x17c)
end
-- 过滤手卡中未给对方观看的仪式怪兽
function s.spcostfilter(c)
	return c:IsType(TYPE_RITUAL) and c:IsType(TYPE_MONSTER) and not c:IsPublic()
end
-- 效果①的发动代价（Cost）处理：从手卡选择1只仪式怪兽给对方确认
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查手卡中是否存在除自身以外的仪式怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.spcostfilter,tp,LOCATION_HAND,0,1,c) end
	-- 提示玩家选择要给对方确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 玩家选择手卡中1只满足条件的仪式怪兽
	local g=Duel.SelectMatchingCard(tp,s.spcostfilter,tp,LOCATION_HAND,0,1,1,c)
	-- 将选中的仪式怪兽给对方玩家确认
	Duel.ConfirmCards(1-tp,g)
	-- 重新洗切手卡
	Duel.ShuffleHand(tp)
end
-- 效果①的发动目标（Target）判定：检查怪兽区域是否有空位，以及自身是否可以特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上的主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理信息：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果①的效果处理（Operation）：如果自身仍在手卡，则将自身特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将自身以表侧表示特殊召唤到自己的场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
