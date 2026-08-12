--狂惑の落とし穴
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：对方对怪兽的特殊召唤成功的回合，以对方场上1只攻击力2000以上的怪兽为对象才能发动。那只怪兽破坏。那之后，自己墓地有「洞」通常陷阱卡或者「落穴」通常陷阱卡存在的场合，可以从对方墓地选1只怪兽除外。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：对方对怪兽的特殊召唤成功的回合，以对方场上1只攻击力2000以上的怪兽为对象才能发动。那只怪兽破坏。那之后，自己墓地有「洞」通常陷阱卡或者「落穴」通常陷阱卡存在的场合，可以从对方墓地选1只怪兽除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_REMOVE+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 效果发动条件判定函数：对方在当前回合进行过特殊召唤
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方玩家在当前回合进行特殊召唤的次数是否大于0
	return Duel.GetActivityCount(1-tp,ACTIVITY_SPSUMMON)>0
end
-- 过滤条件：表侧表示且攻击力在2000以上的怪兽
function s.filter(c)
	return c:IsFaceup() and c:IsAttackAbove(2000)
end
-- 效果发动时的目标选择与处理函数（检查合法性、选择对象并设置破坏操作信息）
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) and chkc:IsControler(1-tp) end
	-- 发动检测：检查对方场上是否存在至少1只满足条件的怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择对方场上1只满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁信息，表明该效果包含破坏1张卡的操作
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 过滤条件：属于「洞」或「落穴」的通常陷阱卡
function s.cfilter(c)
	return c:GetType()==TYPE_TRAP and c:IsSetCard(0x4c,0x89)
end
-- 过滤条件：可以被除外的怪兽卡
function s.rmfilter(c)
	return c:IsAbleToRemove() and c:IsType(TYPE_MONSTER)
end
-- 效果处理的核心逻辑：破坏对象怪兽，并根据条件决定是否除外对方墓地的怪兽
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的第一个对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e)
		-- 判定对象怪兽是否因效果成功被破坏
		and Duel.Destroy(tc,REASON_EFFECT)>0 then
		-- 获取自己墓地中所有满足条件的「洞」或「落穴」通常陷阱卡
		local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_GRAVE,0,nil)
		-- 获取对方墓地中所有可以除外且不受「王家之谷」影响的怪兽
		local rg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.rmfilter),tp,0,LOCATION_GRAVE,nil)
		-- 检查自己墓地是否有「洞」或「落穴」陷阱卡且对方墓地有可除外怪兽，并询问玩家是否进行除外
		if #g>0 and #rg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then  --"是否从对方墓地选1只怪兽除外？"
			-- 中断当前效果处理，使后续的除外处理与前面的破坏处理不视为同时进行
			Duel.BreakEffect()
			-- 提示玩家选择要除外的卡片
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
			local mg=rg:Select(tp,1,1,nil)
			-- 将选中的对方墓地怪兽以表侧表示除外
			Duel.Remove(mg,POS_FACEUP,REASON_EFFECT)
		end
	end
end
