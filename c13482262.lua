--魔神儀の隠れ房
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：作为这张卡的发动时的效果处理，可以把手卡1只「魔神仪」怪兽给对方观看，那2只同名怪兽从卡组特殊召唤。那之后，给人观看的怪兽回到卡组。
-- ②：1回合1次，自己场上有仪式怪兽特殊召唤的场合，以场上1张卡为对象才能发动。那张卡破坏。
function c13482262.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：作为这张卡的发动时的效果处理，可以把手卡1只「魔神仪」怪兽给对方观看，那2只同名怪兽从卡组特殊召唤。那之后，给人观看的怪兽回到卡组。
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
-- 检查手卡中是否存在可展示的「魔神仪」怪兽：属于0x117系列、是怪兽、未公开、能被送回卡组，并且卡组中有至少2张与其同名的怪兽可被特殊召唤。
function c13482262.filter(c,e,tp)
	return c:IsSetCard(0x117) and c:IsType(TYPE_MONSTER) and not c:IsPublic() and c:IsAbleToDeck()
		-- 确认卡组中存在至少2张与展示怪兽同名的、可被效果特殊召唤的「魔神仪」怪兽。
		and Duel.IsExistingMatchingCard(c13482262.spfilter,tp,LOCATION_DECK,0,2,nil,e,tp,c:GetCode())
end
-- 判断卡组中的怪兽是否与指定展示怪兽同名，且能够被效果特殊召唤（需满足其召唤条件与苏生限制）。
function c13482262.spfilter(c,e,tp,code)
	return c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动处理：先确认此卡仍在场上生效且没有“青眼精灵龙”的禁止同时特殊召唤限制；然后如果有可展示的手卡「魔神仪」怪兽且玩家选择发动，则选择1张给对方观看，从卡组挑选2只同名怪兽表侧表示特殊召唤，最后将展示的手卡怪兽洗回持有者卡组。
function c13482262.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if not e:GetHandler():IsRelateToEffect(e) or Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 获取手卡中所有满足c13482262.filter条件的「魔神仪」怪兽组。
	local g=Duel.GetMatchingGroup(c13482262.filter,tp,LOCATION_HAND,0,nil,e,tp)
	-- 若存在可展示的手卡怪兽，并且玩家确认发动“特殊召唤”时，进入执行分支。
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(13482262,0)) then  --"是否特殊召唤？"
		-- 弹出选择提示，提示玩家选择1张手卡怪兽给对方确认。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		local tc=g:Select(tp,1,1,nil):GetFirst()
		-- 根据所选展示怪兽的卡名，从卡组中获取所有同名且可特殊召唤的怪兽组。
		local tg=Duel.GetMatchingGroup(c13482262.spfilter,tp,LOCATION_DECK,0,nil,e,tp,tc:GetCode())
		local sg
		if #tg>2 then
			-- 如果卡组中可选同名怪兽多于2张，提示玩家选择其中2张进行特殊召唤。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			sg=tg:Select(tp,2,2,nil)
		else
			sg=tg:Clone()
		end
		-- 将选择出来的同名怪兽以表侧表示特殊召唤到己方场上，并检查其召唤条件/苏生限制。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		-- 中断当前效果处理，使特殊召唤与随后的回卡组处理分开，避免因为连锁处理而错失时点。
		Duel.BreakEffect()
		-- 将展示过的手卡怪兽以效果原因洗回持有者的卡组，并洗牌。
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 判断怪兽是否满足条件：表侧表示、是仪式怪兽、且由自己控制。
function c13482262.cfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_RITUAL) and c:IsControler(tp)
end
-- ②效果的发动条件：本次特殊召唤成功的怪兽组中存在至少1只自己场上的表侧仪式怪兽。
function c13482262.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c13482262.cfilter,1,nil,tp)
end
-- ②效果的发动与目标选择：若效果发动时检查对象合法性；确认场上存在可取对象后，选择场上1张卡为对象，并登记破坏处理信息。
function c13482262.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 效果发动时（chk==0）检查场上是否存在至少1张能够成为对象的卡，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 显示“请选择要破坏的卡”的提示消息，引导玩家选择对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择双方场上1张卡作为对象，并自动登记为该连锁的对象。
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 将本次操作信息登记为“破坏1张卡”，用于连锁/时点判定。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ②效果处理：取得对象卡，若对象仍与效果关联，则将其破坏。
function c13482262.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得这个效果发动时选择的对象卡（第一张）。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 以效果原因将对象卡破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
