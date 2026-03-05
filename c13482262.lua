--魔神儀の隠れ房
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：作为这张卡的发动时的效果处理，可以把手卡1只「魔神仪」怪兽给对方观看，那2只同名怪兽从卡组特殊召唤。那之后，给人观看的怪兽回到卡组。
-- ②：1回合1次，自己场上有仪式怪兽特殊召唤的场合，以场上1张卡为对象才能发动。那张卡破坏。
function c13482262.initial_effect(c)
	-- ①：作为这张卡的发动时的效果处理，可以把手卡1只「魔神仪」怪兽给对方观看，那2只同名怪兽从卡组特殊召唤。那之后，给人观看的怪兽回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK+CATEGORY_DECKDES)
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
-- 过滤函数，用于判断手牌中是否存在满足条件的「魔神仪」怪兽
function c13482262.filter(c,e,tp)
	return c:IsSetCard(0x117) and c:IsType(TYPE_MONSTER) and not c:IsPublic() and c:IsAbleToDeck()
		-- 检查卡组中是否存在至少2只与所选怪兽同名且可特殊召唤的怪兽
		and Duel.IsExistingMatchingCard(c13482262.spfilter,tp,LOCATION_DECK,0,2,nil,e,tp,c:GetCode())
end
-- 过滤函数，用于判断卡组中是否存在可特殊召唤的同名怪兽
function c13482262.spfilter(c,e,tp,code)
	return c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 处理魔神仪的隐蔽房间的发动效果
function c13482262.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中：禁止该玩家同时特殊召唤2只以上怪兽
	if not e:GetHandler():IsRelateToEffect(e) or Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 获取满足条件的手牌怪兽组
	local g=Duel.GetMatchingGroup(c13482262.filter,tp,LOCATION_HAND,0,nil,e,tp)
	-- 若存在满足条件的怪兽则询问玩家是否发动效果
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(13482262,0)) then  --"是否特殊召唤？"
		-- 提示玩家选择要确认的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		local tc=g:Select(tp,1,1,nil):GetFirst()
		-- 获取卡组中与所选怪兽同名且可特殊召唤的怪兽组
		local tg=Duel.GetMatchingGroup(c13482262.spfilter,tp,LOCATION_DECK,0,nil,e,tp,tc:GetCode())
		local sg
		if #tg>2 then
			-- 提示玩家选择要特殊召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			sg=tg:Select(tp,2,2,nil)
		else
			sg=tg:Clone()
		end
		-- 将符合条件的2只怪兽特殊召唤到场上
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		-- 中断当前效果处理，使后续处理视为不同时处理
		Duel.BreakEffect()
		-- 将所选怪兽送回卡组
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 过滤函数，用于判断场上是否存在仪式怪兽
function c13482262.cfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_RITUAL) and c:IsControler(tp)
end
-- 判断是否满足效果发动条件（自己场上有仪式怪兽特殊召唤）
function c13482262.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c13482262.cfilter,1,nil,tp)
end
-- 设置效果的目标选择函数
function c13482262.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 检查是否满足目标选择条件（场上存在可破坏的卡）
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	-- 选择场上1张卡作为破坏对象
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息，表明此效果将破坏1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 处理效果的破坏操作
function c13482262.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 以效果原因破坏目标卡
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
