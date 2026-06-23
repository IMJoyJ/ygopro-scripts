--超越進化薬β
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己的手卡·场上把包含恐龙族怪兽的2只怪兽解放才能发动。把持有解放的怪兽的攻击力合计以上的攻击力的1只5星以上的恐龙族怪兽从卡组·额外卡组特殊召唤。这张卡的发动后，直到回合结束时自己不是龙族·恐龙族·海龙族·幻龙族怪兽不能从额外卡组特殊召唤。
local s,id,o=GetID()
-- 创建效果，设置发动条件为自由时点，发动次数限制为1次，目标为特殊召唤，效果操作为s.activate
function s.initial_effect(c)
	-- ①：从自己的手卡·场上把包含恐龙族怪兽的2只怪兽解放才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断是否可以解放该卡
function s.costfilter(c,tp)
	return c:IsControler(tp) or c:IsFaceup()
end
-- 检查所选的2只怪兽中是否包含恐龙族怪兽，并且卡组或额外卡组是否存在满足条件的恐龙族怪兽
function s.gcheck(g,e,tp)
	return g:IsExists(Card.IsRace,1,nil,RACE_DINOSAUR)
		-- 检查卡组或额外卡组是否存在满足条件的恐龙族怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp,g,g:GetSum(Card.GetAttack))
end
-- 特殊召唤的过滤函数，检查目标怪兽是否满足等级、种族、攻击力和特殊召唤条件
function s.spfilter(c,e,tp,g,atk)
	local check=false
	if c:IsLocation(LOCATION_DECK) then
		-- 检查卡组中是否有足够的怪兽区域可以特殊召唤
		check=Duel.GetMZoneCount(tp,g)>0
	elseif c:IsLocation(LOCATION_EXTRA) then
		-- 检查额外卡组中是否有足够的位置可以特殊召唤
		check=Duel.GetLocationCountFromEx(tp,tp,g,c)>0
	end
	return check and c:IsLevelAbove(5) and c:IsRace(RACE_DINOSAUR) and c:IsAttackAbove(atk)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置发动时的处理函数，获取可解放的怪兽组并检查是否满足条件
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家可解放的怪兽组，包括手卡
	local g=Duel.GetReleaseGroup(tp,true):Filter(s.costfilter,nil,tp)
	if chk==0 then return e:IsCostChecked()
		and g:CheckSubGroup(s.gcheck,2,2,e,tp) end
	-- 提示玩家选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local sg=g:SelectSubGroup(tp,s.gcheck,false,2,2,e,tp)
	local atk=sg:GetSum(Card.GetAttack)
	-- 将所选的卡进行解放
	Duel.Release(sg,REASON_COST)
	e:SetLabel(atk)
	-- 设置操作信息，表示将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
-- 发动效果，选择满足条件的怪兽进行特殊召唤，并设置后续限制效果
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local atk=e:GetLabel()
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽进行特殊召唤
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp,nil,atk)
	if #g>0 then
		-- 将所选怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 发动后，直到回合结束时自己不是龙族·恐龙族·海龙族·幻龙族怪兽不能从额外卡组特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1,0)
		e1:SetTarget(s.splimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册限制效果，使玩家不能从额外卡组特殊召唤指定种族的怪兽
		Duel.RegisterEffect(e1,tp)
	end
end
-- 限制效果的过滤函数，判断目标怪兽是否为指定种族且在额外卡组
function s.splimit(e,c)
	return not c:IsRace(RACE_DRAGON+RACE_DINOSAUR+RACE_SEASERPENT+RACE_WYRM) and c:IsLocation(LOCATION_EXTRA)
end
