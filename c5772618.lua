--HSRカイドレイク
-- 效果：
-- 机械族·风属性调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡同调召唤成功的场合，可以从以下效果选择1个发动。
-- ●这张卡以外的场上的卡全部破坏。
-- ●对方场上的全部表侧表示的卡的效果无效。
-- ②：这张卡被对方送去墓地的场合才能发动。从卡组把1只「疾行机人」怪兽加入手卡。
function c5772618.initial_effect(c)
	-- 添加同调召唤手续：机械族·风属性调整+调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,c5772618.sfilter,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤成功的场合，可以从以下效果选择1个发动。●这张卡以外的场上的卡全部破坏。●对方场上的全部表侧表示的卡的效果无效。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(5772618,0))  --"选择效果发动"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,5772618)
	e1:SetCondition(c5772618.con)
	e1:SetTarget(c5772618.target)
	e1:SetOperation(c5772618.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡被对方送去墓地的场合才能发动。从卡组把1只「疾行机人」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(5772618,3))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,5772619)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(c5772618.thcon)
	e2:SetTarget(c5772618.thtg)
	e2:SetOperation(c5772618.thop)
	c:RegisterEffect(e2)
end
-- 过滤条件：机械族且风属性的怪兽
function c5772618.sfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_WIND)
end
-- 发动条件：此卡同调召唤成功
function c5772618.con(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 效果①的发动准备：检查可行性、让玩家选择要发动的效果分支并设置对应的操作信息
function c5772618.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取场上除这张卡以外的所有卡片
	local b1=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	-- 获取对方场上所有可以被无效的表侧表示卡片
	local b2=Duel.GetMatchingGroup(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,nil)
	if chk==0 then return #b1>0 or #b2>0 end
	local off=1
	local ops={}
	local opval={}
	if #b1>0 then
		ops[off]=aux.Stringid(5772618,1)  --"这张卡以外的场上的卡全部破坏"
		opval[off]=0
		off=off+1
	end
	if #b2>0 then
		ops[off]=aux.Stringid(5772618,2)  --"对方场上的全部表侧表示的卡的效果无效"
		opval[off]=1
		off=off+1
	end
	-- 让玩家选择要发动的效果分支
	local op=Duel.SelectOption(tp,table.unpack(ops))+1
	local sel=opval[op]
	e:SetLabel(sel)
	-- 向对方玩家提示所选择的效果分支
	Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(5772618,sel+1))
	if sel==0 then
		e:SetCategory(CATEGORY_DESTROY)
		-- 设置破坏效果的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,b1,b1:GetCount(),0,0)
	else
		e:SetCategory(CATEGORY_DISABLE)
	end
end
-- 效果①的处理逻辑：根据选择的分支，执行全部破坏或全部无效
function c5772618.operation(e,tp,eg,ep,ev,re,r,rp)
	local sel=e:GetLabel()
	local c=e:GetHandler()
	-- 获取效果处理时场上除这张卡以外的所有卡片
	local b1=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	-- 获取效果处理时对方场上所有可以被无效的表侧表示卡片
	local b2=Duel.GetMatchingGroup(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,nil)
	if sel==0 then
		-- 因效果破坏选定的卡片组
		Duel.Destroy(b1,REASON_EFFECT)
	else
		local nc=b2:GetFirst()
		while nc do
			-- 效果无效
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			nc:RegisterEffect(e1)
			-- 效果无效
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			nc:RegisterEffect(e2)
			if nc:IsType(TYPE_TRAPMONSTER) then
				-- 效果无效
				local e3=Effect.CreateEffect(c)
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
				e3:SetReset(RESET_EVENT+RESETS_STANDARD)
				nc:RegisterEffect(e3)
			end
			nc=b2:GetNext()
		end
	end
end
-- 发动条件：这张卡被对方送去墓地
function c5772618.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsPreviousControler(tp)
end
-- 过滤条件：卡组中可以加入手牌的「疾行机人」怪兽
function c5772618.thfilter(c)
	return c:IsSetCard(0x2016) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果②的发动准备：检查卡组中是否存在可检索的怪兽并设置检索的操作信息
function c5772618.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1只满足条件的「疾行机人」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c5772618.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置检索卡组的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的处理逻辑：从卡组选择1只「疾行机人」怪兽加入手牌并给对方确认
function c5772618.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1只满足条件的「疾行机人」怪兽
	local g=Duel.SelectMatchingCard(tp,c5772618.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选定的怪兽因效果加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡片给对方玩家确认
		Duel.ConfirmCards(1-tp,g)
	end
end
