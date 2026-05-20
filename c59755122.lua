--ドラグニティ－ファランクス
-- 效果：
-- ①：这张卡装备中的场合，1回合1次，自己主要阶段才能发动。这张卡特殊召唤。
function c59755122.initial_effect(c)
	-- ①：这张卡装备中的场合，1回合1次，自己主要阶段才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(59755122,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTarget(c59755122.sptg)
	e1:SetOperation(c59755122.spop)
	c:RegisterEffect(e1)
end
-- 特殊召唤效果的发动准备与条件判断：检查怪兽区空位、自身是否处于装备状态以及是否能被特殊召唤
function c59755122.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查当前玩家的主要怪兽区域是否有可用的空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:GetEquipTarget() and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理信息为将1张自身卡片特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 特殊召唤效果的处理：检查卡片是否与效果相关联，并执行特殊召唤
function c59755122.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将自身以表侧表示特殊召唤到发动玩家的场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
