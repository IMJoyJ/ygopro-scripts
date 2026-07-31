--E・HERO クレイガードマン
local s,id,o=GetID()
-- 初始化卡片效果：注册融合召唤手续、特召成功时卡组特召与伤害效果、以及己方其他「HERO」怪兽战破·效破抗性效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设定融合召唤手续：「E·HERO」怪兽＋战士族怪兽
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x3008),aux.FilterBoolFunction(Card.IsRace,RACE_WARRIOR),true)
	-- ①：这张卡特殊召唤成功的场合才能发动。从卡组把1只「E·HERO」怪兽特殊召唤。那之后，可以给对方造成对方场上的卡数量×400伤害。这个效果发动的回合，自己不是「HERO」怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，这张卡以外的自己场上的「E·HERO」怪兽不会被战斗·效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.indtg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e3)
end
s.material_setcode=0x3008
-- 特殊召唤过滤条件：卡组中可特殊召唤的「E·HERO」怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x3008) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果发动准备：检查怪兽区域空位及卡组可特召怪兽，并设置特殊召唤操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件检查：卡组是否存在满足条件的「E·HERO」怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：从卡组特召1只「E·HERO」怪兽，可追加伤害，并注册本回合额外卡组特召限制
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组选择1只满足条件的「E·HERO」怪兽
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		-- 将选中的怪兽表侧表示特殊召唤
		if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0
			-- 检查对方场上是否存在卡片
			and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil)
			-- 询问玩家是否发动给予伤害的效果
			and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			-- 中断效果处理，使后续给予伤害的操作不同时处理
			Duel.BreakEffect()
			-- 统计对方场上的卡片数量
			local dam=Duel.GetMatchingGroupCount(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
			-- 给予对方对方场上的卡数量×400的伤害
			Duel.Damage(1-tp,dam*400,REASON_EFFECT)
		end
	end
	-- 誓约限制：这个效果发动的回合，自己不是「HERO」怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 为玩家注册回合内额外卡组特殊召唤限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 特殊召唤限制条件：禁止从额外卡组特殊召唤「HERO」以外的怪兽
function s.splimit(e,c)
	return not c:IsSetCard(0x8) and c:IsLocation(LOCATION_EXTRA)
end
-- 破坏抗性保护对象过滤：除自身外的己方「E·HERO」怪兽
function s.indtg(e,c)
	return c:IsSetCard(0x3008) and c~=e:GetHandler()
end
