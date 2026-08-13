--メガリス・アラトロン
-- 效果：
-- 「巨石遗物」卡降临。这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段，把这张卡从手卡丢弃才能发动。等级合计直到变成仪式召唤的怪兽的等级以上为止，把自己的手卡·场上的怪兽解放，从手卡把1只「巨石遗物」仪式怪兽仪式召唤。
-- ②：自己场上的卡为对象的对方的效果发动时才能发动。从自己墓地选1只仪式怪兽回到卡组最下面，那个发动无效并破坏。
function c25726386.initial_effect(c)
	c:EnableReviveLimit()
	-- 通过辅助函数为这张卡添加一个仪式召唤效果，该效果支持用等级合计大于或等于仪式怪兽等级的方式降临；filter用于限定可仪式召唤的「巨石遗物」仪式怪兽，matfilter限制素材不能是效果发动者自身；pause=true表示先不注册，以便后续修改效果类型等属性。
	local e1=aux.AddRitualProcGreater2(c,c25726386.filter,nil,nil,c25726386.matfilter,true)
	e1:SetDescription(aux.Stringid(25726386,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCountLimit(1,25726386)
	e1:SetCondition(c25726386.rscon)
	e1:SetCost(c25726386.rscost)
	c:RegisterEffect(e1)
	-- ②：自己场上的卡为对象的对方的效果发动时才能发动。从自己墓地选1只仪式怪兽回到卡组最下面，那个发动无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(25726386,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,25726387)
	e2:SetCondition(c25726386.discon)
	e2:SetTarget(c25726386.distg)
	e2:SetOperation(c25726386.disop)
	c:RegisterEffect(e2)
end
-- 仪式召唤对象的过滤函数：候选卡必须是「巨石遗物」系列怪兽，并且在作为仪式召唤对象时不能是发动效果的这张卡自身（因为它已作为代价丢弃）。
function c25726386.filter(c,e,tp,chk)
	return c:IsSetCard(0x138) and (not chk or c~=e:GetHandler())
end
-- 仪式召唤素材的过滤函数：在检查素材时，不能选择发动效果的这张卡自身（这张卡已经作为代价被丢弃，不能用作解放素材）。
function c25726386.matfilter(c,e,tp,chk)
	return not chk or c~=e:GetHandler()
end
-- ①效果的发动条件：只在主要阶段1或主要阶段2（即自己或对方的主要阶段）才能发动，对应“自己·对方的主要阶段”的限制。
function c25726386.rscon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否为主要阶段1或主要阶段2，以此限定仪式召唤效果只能在主要阶段发动。
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- ①效果的发动代价：先检查这张卡能否从手卡丢弃；若能，则支付代价将其丢弃（送去墓地），对应“把这张卡从手卡丢弃才能发动”。
function c25726386.rscost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 实际支付代价：将效果发动者（这张卡）从手卡送去墓地，代价类型为丢弃（COST+DISCARD）。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 用于②效果的发动判定：判断某张卡是否在自己场上且由自己控制，用于确认对方取对象效果是否以自己场上的卡为对象。
function c25726386.tfilter(c,tp)
	return c:IsOnField() and c:IsControler(tp)
end
-- 墓地中可作为②效果回卡组对象的过滤条件：必须是仪式怪兽（怪兽卡）且能够返回卡组，用于“从自己墓地选1只仪式怪兽回到卡组最下面”。
function c25726386.disfilter(c)
	return c:IsType(TYPE_RITUAL) and c:IsAbleToDeck() and c:IsType(TYPE_MONSTER)
end
-- ②效果的发动条件：对方发动效果、且该效果是取对象效果并指定了自己场上的卡为对象，同时该连锁可以被无效，且本卡没有被战斗破坏确定。满足这些条件才能发动②。
function c25726386.discon(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取对方发动效果时连锁中登记的对象卡组，用于后续判断这些对象是否包含自己场上的卡。
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 判断对象卡组存在且其中至少包含1张自己场上的卡，并且该连锁能够被无效；三个条件同时满足时②效果才能发动。
	return tg and tg:IsExists(c25726386.tfilter,1,nil,tp) and Duel.IsChainNegatable(ev)
end
-- ②效果的目标设定与发动时的合法检查：确认自己墓地存在符合条件的仪式怪兽后，设置本效果将进行的操作：回卡组、无效发动、并可能破坏对方效果卡。
function c25726386.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时（chk==0）检查自己墓地是否存在至少1张符合条件的仪式怪兽，作为②效果能否发动的必要条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c25726386.disfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息：本效果包含从自己墓地返回卡组的处理，目标数为1，区域为墓地。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
	-- 设置操作信息：本效果包含无效对方效果发动的处理，对象是正在连锁发动的效果卡eg。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 如果对方效果卡能够被破坏且与效果仍有关联，则追加设置破坏处理的类别，对象仍是eg。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- ②效果的实际处理：选择1张墓地仪式怪兽返回卡组最下面；若成功返回且该连锁可被无效，则无效对方效果发动并将其破坏。
function c25726386.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示框，提示玩家选择一张要返回卡组的墓地仪式怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从自己墓地选择1张满足条件且不受王家长眠之谷影响的仪式怪兽，作为②效果要返回卡组最下面的卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c25726386.disfilter),tp,LOCATION_GRAVE,0,1,1,nil)
	-- 若成功选择到卡，且将其返回卡组最下面的操作实际成功（返回值不为0），才继续执行后续无效与破坏的处理。
	if g:GetCount()>0 and Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT)~=0 then
		-- 确认被返回的卡确实在卡组中，且该连锁发动可以被无效，同时对方效果卡仍与效果有关联；三个条件均满足时执行最终的无效并破坏。
		if g:GetFirst():IsLocation(LOCATION_DECK) and Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
			-- 破坏对方发动的效果的那张卡（eg），破坏原因为本效果处理。
			Duel.Destroy(eg,REASON_EFFECT)
		end
	end
end
