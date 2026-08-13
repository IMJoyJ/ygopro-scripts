--超越進化薬β
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己的手卡·场上把包含恐龙族怪兽的2只怪兽解放才能发动。把持有解放的怪兽的攻击力合计以上的攻击力的1只5星以上的恐龙族怪兽从卡组·额外卡组特殊召唤。这张卡的发动后，直到回合结束时自己不是龙族·恐龙族·海龙族·幻龙族怪兽不能从额外卡组特殊召唤。
local s,id,o=GetID()
-- 注册“超越进化药β”的魔法卡发动效果：作为通常魔法可在自由时点发动，设置同名卡1回合只能发动1次（誓约限制），效果分类为特殊召唤；指定发动前选择解放怪兽的目标处理和发动后从卡组·额外卡组特殊召唤恐龙族怪兽并附加自肃的效果处理。
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从自己的手卡·场上把包含恐龙族怪兽的2只怪兽解放才能发动。把持有解放的怪兽的攻击力合计以上的攻击力的1只5星以上的恐龙族怪兽从卡组·额外卡组特殊召唤。这张卡的发动后，直到回合结束时自己不是龙族·恐龙族·海龙族·幻龙族怪兽不能从额外卡组特殊召唤。
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
-- 筛选解放代价的候选怪兽：返回控制者是己方或是表侧表示（即属于自己手卡·场上可作为解放素材）的怪兽。
function s.costfilter(c,tp)
	return c:IsControler(tp) or c:IsFaceup()
end
-- 检查选中的2只解放怪兽组是否成立：组内至少包含1只恐龙族怪兽，并且卡组·额外卡组中存在1只可特殊召唤的怪兽，其攻击力不低于该组怪兽攻击力合计，等级≥5且为恐龙族。
function s.gcheck(g,e,tp)
	return g:IsExists(Card.IsRace,1,nil,RACE_DINOSAUR)
		-- 检查卡组·额外卡组中是否存在至少1张满足特殊召唤条件的恐龙族怪兽，条件基于解放组g的攻击力合计（作为atk参数）。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp,g,g:GetSum(Card.GetAttack))
end
-- 判定某张卡能否作为“从卡组·额外卡组特殊召唤恐龙族怪兽”的对象：根据其所在位置确认怪兽区空格是否足够（卡组需有主怪兽区空格，额外卡组需有额外召唤空格），且满足等级≥5、恐龙族、攻击力≥指定值，并能被效果特殊召唤。
function s.spfilter(c,e,tp,g,atk)
	local check=false
	if c:IsLocation(LOCATION_DECK) then
		-- 当候选卡位于卡组时，检查把解放组g解放后自己场上是否有空余的怪兽区可用于特殊召唤。
		check=Duel.GetMZoneCount(tp,g)>0
	elseif c:IsLocation(LOCATION_EXTRA) then
		-- 当候选卡位于额外卡组时，检查把解放组g离场后自己场上是否有足够的空格用于从额外卡组特殊召唤该卡。
		check=Duel.GetLocationCountFromEx(tp,tp,g,c)>0
	end
	return check and c:IsLevelAbove(5) and c:IsRace(RACE_DINOSAUR) and c:IsAttackAbove(atk)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的目标检测阶段：获取可解放的候选怪兽组；在chk==0时，确认已经完成代价检测，并检查能否从候选组中选出2只满足gcheck条件的怪兽（包含恐龙族且能特殊召唤对应攻击力的恐龙族）。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 取得玩家tp当前可解放（包括手卡）的怪兽集合，并用costfilter过滤出可作为这张卡解放代价的怪兽，作为发动的候选组。
	local g=Duel.GetReleaseGroup(tp,true):Filter(s.costfilter,nil,tp)
	if chk==0 then return e:IsCostChecked()
		and g:CheckSubGroup(s.gcheck,2,2,e,tp) end
	-- 向玩家弹出选择提示，要求其选择要解放的卡（界面显示“请选择要解放的卡”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local sg=g:SelectSubGroup(tp,s.gcheck,false,2,2,e,tp)
	local atk=sg:GetSum(Card.GetAttack)
	-- 将选中的2只怪兽组sg作为效果发动代价解放（REASON_COST），此时不触发因效果离场时的连锁，并支付发动条件。
	Duel.Release(sg,REASON_COST)
	e:SetLabel(atk)
	-- 设置当前连锁的操作信息：本效果将进行1次特殊召唤，可能从卡组或额外卡组特殊召唤，操作者为tp，用于其他卡片的时点检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
-- 效果处理阶段：从自己卡组·额外卡组选择1只满足条件的恐龙族怪兽特殊召唤；随后，若发动效果成功适用，给己方附加直到回合结束不能从额外卡组特殊召唤龙族·恐龙族·海龙族·幻龙族以外怪兽的自肃。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local atk=e:GetLabel()
	-- 向玩家弹出选择提示，要求其选择要特殊召唤的卡（界面显示“请选择要特殊召唤的卡”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己卡组·额外卡组中选出1张满足s.spfilter条件的恐龙族怪兽（等级≥5、攻击力不低于记录的解放攻击力合计、可特殊召唤），作为这次特殊召唤的对象。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp,nil,atk)
	if #g>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上（检查召唤条件和苏生限制）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 这张卡的发动后，直到回合结束时自己不是龙族·恐龙族·海龙族·幻龙族怪兽不能从额外卡组特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1,0)
		e1:SetTarget(s.splimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将自肃效果e1注册给玩家tp，使其在结束阶段前持续适用：不能从额外卡组特殊召唤非指定种族的怪兽。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 自肃效果的判定函数：若一张卡不属于龙族·恐龙族·海龙族·幻龙族，且位于额外卡组，则不能将其特殊召唤。
function s.splimit(e,c)
	return not c:IsRace(RACE_DRAGON+RACE_DINOSAUR+RACE_SEASERPENT+RACE_WYRM) and c:IsLocation(LOCATION_EXTRA)
end
