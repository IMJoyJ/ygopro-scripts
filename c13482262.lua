--魔神儀の隠れ房
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：作为这张卡的发动时的效果处理，可以把手卡1只「魔神仪」怪兽给对方观看，那2只同名怪兽从卡组特殊召唤。那之后，给人观看的怪兽回到卡组。
-- ②：1回合1次，自己场上有仪式怪兽特殊召唤的场合，以场上1张卡为对象才能发动。那张卡破坏。
function c13482262.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：作为这张卡的发动时的效果处理，可以把手卡1只「魔神仪」怪兽给对方观看，那2只同名怪兽从卡组特殊召唤。那之后，给人观看的怪兽回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,13482262+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(c13482262.activate)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己场上有仪式怪兽特殊召唤的场合，以场上1张卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(13482262,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCondition(c13482262.descon)
	e2:SetTarget(c13482262.destg)
	e2:SetOperation(c13482262.desop)
	c:RegisterEffect(e2)
end
-- 过滤条件：检查手卡的卡是否为未公开、可回卡组且卡组中存在2只可特招同名卡的「魔神仪」怪兽。
function c13482262.filter(c,e,tp)
	return c:IsSetCard(0x117) and c:IsType(TYPE_MONSTER) and not c:IsPublic() and c:IsAbleToDeck()
		-- 检查卡组中是否存在至少2只与该手卡怪兽同名且可特殊召唤的怪兽。
		and Duel.IsExistingMatchingCard(c13482262.spfilter,tp,LOCATION_DECK,0,2,nil,e,tp,c:GetCode())
end
-- 过滤条件：检查卡组中的怪兽是否与指定卡号同名且可以特殊召唤。
function c13482262.spfilter(c,e,tp,code)
	return c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的处理函数：检查发动时条件，确认是否公开手卡「魔神仪」怪兽以从卡组特招2只同名怪兽并将原卡放回卡组。
function c13482262.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if not e:GetHandler():IsRelateToEffect(e) or Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 获取自己手卡中满足条件（卡组有2只同名可特招且自身可回卡组）的「魔神仪」怪兽组。
	local g=Duel.GetMatchingGroup(c13482262.filter,tp,LOCATION_HAND,0,nil,e,tp)
	-- 若手卡存在符合条件的怪兽，询问玩家是否发动发动时的可选效果进行特殊召唤。
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(13482262,0)) then  --"是否特殊召唤？"
		-- 发送提示信息，引导玩家选择给对方确认观看的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		local tc=g:Select(tp,1,1,nil):GetFirst()
		-- 从卡组获取所有与所选怪兽同名且可特殊召唤的怪兽组。
		local tg=Duel.GetMatchingGroup(c13482262.spfilter,tp,LOCATION_DECK,0,nil,e,tp,tc:GetCode())
		local sg
		if #tg>2 then
			-- 当卡组同名怪兽超过2只时，发送提示信息引导玩家选择要特殊召唤的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			sg=tg:Select(tp,2,2,nil)
		else
			sg=tg:Clone()
		end
		-- 将选定的2只同名「魔神仪」怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		-- 中断当前效果处理，使之后的回卡组与之前的特殊召唤视为不同时处理。
		Duel.BreakEffect()
		-- 将之前给对方观看的手卡「魔神仪」怪兽以效果洗回持有者卡组。
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 过滤条件：检查怪兽是否为己方控制且表侧表示的仪式怪兽。
function c13482262.cfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_RITUAL) and c:IsControler(tp)
end
-- ②效果的发动条件：检查本次特殊召唤成功的怪兽中是否包含己方的表侧表示仪式怪兽。
function c13482262.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c13482262.cfilter,1,nil,tp)
end
-- ②效果的目标处理函数：验证对象合法性并让玩家选择场上1张卡作为破坏对象。
function c13482262.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 发动条件检查：确认双方场上存在至少1张可成为对象的卡。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 发送提示信息，引导玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让己方从双方场上选择1张卡作为本次效果的破坏对象。
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：预计破坏所选定的1张对象卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ②效果的处理函数：检查对象卡仍与效果保持联系后将其破坏。
function c13482262.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁指定的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 以效果破坏该对象卡。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
