--聖秘なる竜騎士
-- 效果：
-- 龙族怪兽＋魔法师族怪兽
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：这张卡的攻击力下降自己的除外状态的卡数量×100。
-- ②：只要融合召唤的这张卡在怪兽区域存在，对方场上的特殊召唤的龙族·魔法师族怪兽不能把效果发动。
-- ③：以自己墓地的龙族和魔法师族的怪兽各1只为对象才能发动。那之内的1只特殊召唤，另1只回到卡组最下面。
local s,id,o=GetID()
-- 初始化函数，注册卡片效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设定融合素材为龙族怪兽和魔法师族怪兽各1只
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsRace,RACE_DRAGON),aux.FilterBoolFunction(Card.IsRace,RACE_SPELLCASTER),true)
	-- ①：这张卡的攻击力下降自己的除外状态的卡数量×100。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	-- ②：只要融合召唤的这张卡在怪兽区域存在，对方场上的特殊召唤的龙族·魔法师族怪兽不能把效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_TRIGGER)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(s.actcon)
	e2:SetTarget(s.acttg)
	c:RegisterEffect(e2)
	-- ③：以自己墓地的龙族和魔法师族的怪兽各1只为对象才能发动。那之内的1只特殊召唤，另1只回到卡组最下面。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))  --"以墓地怪兽为对象"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 计算攻击力下降数值的函数
function s.atkval(e)
	-- 返回自己除外状态的卡数量乘以-100
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_REMOVED,0)*-100
end
-- 判断自身是否为融合召唤状态的条件函数
function s.actcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 过滤对方场上特殊召唤的龙族或魔法师族怪兽
function s.acttg(e,c)
	return c:IsRace(RACE_DRAGON+RACE_SPELLCASTER) and c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 过滤墓地中可以作为效果对象的龙族或魔法师族怪兽
function s.tgfilter(c,e,tp)
	return c:IsCanBeEffectTarget(e) and c:IsRace(RACE_DRAGON+RACE_SPELLCASTER)
		and (c:IsAbleToDeck() or c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- 过滤可以特殊召唤且另一张卡可以回到卡组的怪兽
function s.spfilter(c,g,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and g:IsExists(Card.IsAbleToDeck,1,c)
end
-- 过滤包含龙族和魔法师族怪兽的组合
function s.racefilter(c,g)
	return c:IsRace(RACE_DRAGON) and g:IsExists(Card.IsRace,1,c,RACE_SPELLCASTER)
end
-- 检查选择的2张卡是否满足特殊召唤和回到卡组，且种族分别为龙族和魔法师族
function s.fselect(g,e,tp)
	return g:IsExists(s.spfilter,1,nil,g,e,tp)
		and g:IsExists(s.racefilter,1,nil,g)
end
-- 效果③的发动准备与目标选择函数
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取自己墓地中满足条件的所有怪兽
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_GRAVE,0,e:GetHandler(),e,tp)
	if chkc then return false end
	-- 在发动阶段检查自己场上是否有怪兽空位，且墓地中是否存在满足条件的龙族和魔法师族怪兽组合
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and g:CheckSubGroup(s.fselect,2,2,e,tp) end
	-- 提示玩家选择要操作的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	local sg=g:SelectSubGroup(tp,s.fselect,false,2,2,e,tp)
	-- 将选择的2只怪兽设为效果处理的对象
	Duel.SetTargetCard(sg)
	-- 设置特殊召唤的操作信息，预计从墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
	-- 设置回到卡组的操作信息，预计将1只墓地的怪兽送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
end
-- 效果③的效果处理函数
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与效果相关的对象怪兽
	local g=Duel.GetTargetsRelateToChain()
	-- 若对象怪兽已不存在或自己场上没有空位，则不处理效果
	if #g==0 or Duel.GetLocationCount(tp,LOCATION_MZONE)==0 then return end
	-- 从对象怪兽中过滤出不受王家之谷影响且可以特殊召唤的怪兽
	local sg=g:Filter(aux.NecroValleyFilter(Card.IsCanBeSpecialSummoned),nil,e,0,tp,false,false)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sc=sg:Select(tp,1,1,nil):GetFirst()
	if not sc then return end
	-- 若成功将选择的1只怪兽特殊召唤
	if Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)>0 then
		g:RemoveCard(sc)
		if #g>0 then
			-- 将剩下的另1只怪兽回到卡组最下面
			Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
		end
	end
end
