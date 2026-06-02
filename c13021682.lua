--スタージャンク・シンクロン
-- 效果：
-- 这张卡可以作为「同调士」调整的代替而成为同调素材。这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在的场合，以自己墓地1只2星以下的怪兽为对象才能发动。这张卡特殊召唤，作为对象的怪兽效果无效特殊召唤。这个回合，自己不是同调怪兽不能从额外卡组特殊召唤。
-- ②：把墓地的这张卡除外才能发动。这个回合中，自己场上的「废品战士」不会被对方的效果破坏。
local s,id,o=GetID()
-- 注册卡片的效果
function s.initial_effect(c)
	-- 记录这张卡的效果关系到「废品战士」(60800381)的卡名
	aux.AddCodeList(c,60800381)
	-- 这张卡可以作为「同调士」调整的代替而成为同调素材。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(20932152)
	c:RegisterEffect(e0)
	-- ①：这张卡在手卡存在的场合，以自己墓地1只2星以下的怪兽为对象才能发动。这张卡特殊召唤，作为对象的怪兽效果无效特殊召唤。这个回合，自己不是同调怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。这个回合中，自己场上的「废品战士」不会被对方的效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"破坏耐性"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	-- 把墓地的这张卡除外作为发动的代价
	e2:SetCost(aux.bfgcost)
	e2:SetCountLimit(1,id+o)
	e2:SetOperation(s.immop)
	c:RegisterEffect(e2)
end
-- 过滤自己墓地等级2以下的、可以特殊召唤的怪兽
function s.spfilter(c,e,tp)
	return c:IsLevelBelow(2) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①发动的可行性检测与效果目标处理
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己场上可用的怪兽区域空格数是否大于1
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查自己墓地是否存在可特殊召唤的等级2以下的怪兽
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 给玩家发送提示信息以选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家选择自己墓地中1只等级2以下的怪兽作为对象
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	g:AddCard(c)
	-- 设置特殊召唤操作信息（自身和墓地怪兽特殊召唤）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,0,0)
end
-- 效果①的处理逻辑，特殊召唤自身及墓地怪兽，并赋予召唤限制和效果无效限制
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 这张卡特殊召唤，作为对象的怪兽效果无效特殊召唤。这个回合，自己不是同调怪兽不能从额外卡组特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetTarget(s.splimit)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 对玩家注册这个回合不能从额外卡组特殊召唤同调怪兽以外怪兽的限制效果
	Duel.RegisterEffect(e3,tp)
	-- 获取选择的墓地怪兽对象
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍合法，并应用王家长眠之谷的过滤检查
	if tc:IsRelateToChain() and not aux.NecroValleyFilter()(tc) then return false end
	if c:IsRelateToChain()
		-- 尝试特殊召唤手卡中的这张卡本身
		and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		if tc:IsRelateToChain()
			and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
			and not Duel.IsPlayerAffectedByEffect(tp,59822133) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
			-- 尝试特殊召唤作为对象的怪兽
			if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
				-- 作为对象的怪兽效果无效特殊召唤。
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1)
				-- 作为对象的怪兽效果无效特殊召唤。
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				e2:SetValue(RESET_TURN_SET)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e2)
			end
		end
		-- 完成批量特殊召唤手续
		Duel.SpecialSummonComplete()
	end
end
-- 额外卡组特殊召唤限制规则过滤函数，仅允许特殊召唤同调怪兽
function s.splimit(e,c)
	return not c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_EXTRA)
end
-- 效果②的处理逻辑，赋予场上「废品战士」不会被对方效果破坏的抗性
function s.immop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 这个回合中，自己场上的「废品战士」不会被对方的效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	-- 设置不受对方卡片效果破坏的保护机制
	e1:SetValue(aux.indoval)
	e1:SetTargetRange(LOCATION_ONFIELD,0)
	-- 设置效果作用目标为场上的「废品战士」
	e1:SetTarget(aux.TargetBoolFunction(Card.IsCode,60800381))
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 对玩家注册这个回合的抗性效果
	Duel.RegisterEffect(e1,tp)
end
