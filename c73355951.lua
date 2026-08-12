--魔法名－「解体し統合せよ」
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以除外的双方怪兽各1只为对象才能发动。作为对象的自己怪兽在对方场上特殊召唤，作为对象的对方怪兽在自己场上特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以除外的双方怪兽各1只为对象才能发动。作为对象的自己怪兽在对方场上特殊召唤，作为对象的对方怪兽在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤出除外状态下，可以被特殊召唤到对方场上（若是自己的怪兽）或自己场上（若是对方的怪兽）的表侧表示怪兽
function s.filter(c,e,tp)
	local p=tp
	if c:IsControler(tp) then p=1-p end
	return c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,p)
end
-- 效果发动时的对象选择与合法性检测函数
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检测自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检测对方场上是否有可用的怪兽区域
		and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		-- 检测自己被除外的怪兽中是否存在可以特殊召唤到对方场上的合法对象
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_REMOVED,0,1,nil,e,tp)
		-- 检测对方被除外的怪兽中是否存在可以特殊召唤到自己场上的合法对象
		and Duel.IsExistingTarget(s.filter,tp,0,LOCATION_REMOVED,1,nil,e,tp)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己被除外的1只怪兽作为效果对象
	local g1=Duel.SelectTarget(tp,s.filter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择对方被除外的1只怪兽作为效果对象
	local g2=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_REMOVED,1,1,nil,e,tp)
	g1:Merge(g2)
	-- 设置效果处理时的操作信息为特殊召唤这2张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g1,2,0,0)
end
-- 效果处理的执行函数，将作为对象的双方怪兽分别特殊召唤到对方和自己场上
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与效果关联的对象卡片
	local g=Duel.GetTargetsRelateToChain()
	local sc1=g:Filter(Card.IsControler,nil,tp):GetFirst()
	local sc2=g:Filter(Card.IsControler,nil,1-tp):GetFirst()
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if sc1 and Duel.SpecialSummonStep(sc1,0,tp,1-tp,false,false,POS_FACEUP) and sc2 and not Duel.IsPlayerAffectedByEffect(tp,59822133) then
		-- 将作为对象的对方怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummonStep(sc2,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 完成所有怪兽的特殊召唤处理
	Duel.SpecialSummonComplete()
end
