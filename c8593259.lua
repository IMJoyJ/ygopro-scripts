--E・HERO クレイガードマン
local s,id,o=GetID()
-- 初始化卡片信息，添加融合手续并注册各个效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，用带有「元素英雄」字段的卡和战士族怪兽各1只作为融合素材
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x3008),aux.FilterBoolFunction(Card.IsRace,RACE_WARRIOR),true)
	-- 这张卡特殊召唤成功的场合才能发动。从卡组把1只「元素英雄」怪兽特殊召唤。那之后，可以给与对方场上卡片数量×400的伤害。
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
	-- 只要这张卡在怪兽区域存在，自己场上的其他「元素英雄」怪兽不会被战斗·效果破坏。
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
-- 检查怪兽是否带有「元素英雄」字段并且可以被特殊召唤
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x3008) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 检查自己场上的可用怪兽区数量是否大于0，且卡组中存在满足条件的怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上的可用怪兽区数量是否大于0
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只满足条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置从卡组特殊召唤的效果操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 从卡组特殊召唤怪兽，并根据玩家选择给与伤害，最后附加自肃效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上的可用怪兽区数量是否大于0
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 向玩家发送选择要特殊召唤的怪兽的提示信息
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从卡组选择1只满足特殊召唤条件的怪兽
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		-- 检查是否成功选中怪兽并将该怪兽特殊召唤出场
		if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0
			-- 检查场上是否存在至少1张卡片
			and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil)
			-- 询问玩家是否发动伤害效果
			and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			-- 中断当前效果，使前后的效果处理视为不同时处理
			Duel.BreakEffect()
			-- 获取场上所有卡片的数量
			local dam=Duel.GetMatchingGroupCount(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
			-- 给与对方场上卡片数量×400的伤害
			Duel.Damage(1-tp,dam*400,REASON_EFFECT)
		end
	end
	-- 这个效果发动的回合，自己不是「英雄」怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将特殊召唤限制的自肃效果注册给全局环境
	Duel.RegisterEffect(e1,tp)
end
-- 检查卡片是否不带有「英雄」字段并且位于额外卡组
function s.splimit(e,c)
	return not c:IsSetCard(0x8) and c:IsLocation(LOCATION_EXTRA)
end
-- 检查卡片是否带有「元素英雄」字段且不是这张卡自身
function s.indtg(e,c)
	return c:IsSetCard(0x3008) and c~=e:GetHandler()
end
