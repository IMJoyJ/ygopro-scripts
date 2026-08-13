--ツッパリーチ
-- 效果：
-- ①：自己抽卡阶段通常抽卡时，把那1张卡给对方观看才能发动。那张卡回到卡组最下面，自己从卡组抽1张。
-- ②：自己因效果抽卡时，把那1张卡给对方观看才能发动。这张卡送去墓地，给人观看的卡回到卡组最下面，自己从卡组抽1张。
function c20216608.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己抽卡阶段通常抽卡时，把那1张卡给对方观看才能发动。那张卡回到卡组最下面，自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(20216608,0))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DRAW)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCondition(c20216608.drcon)
	e2:SetCost(c20216608.drcost)
	e2:SetTarget(c20216608.drtg)
	e2:SetOperation(c20216608.drop)
	c:RegisterEffect(e2)
	-- ②：自己因效果抽卡时，把那1张卡给对方观看才能发动。这张卡送去墓地，给人观看的卡回到卡组最下面，自己从卡组抽1张。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(20216608,1))
	e3:SetCategory(CATEGORY_TOGRAVE+CATEGORY_TODECK+CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DRAW)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCondition(c20216608.drcon2)
	e3:SetCost(c20216608.drcost)
	e3:SetTarget(c20216608.drtg2)
	e3:SetOperation(c20216608.drop2)
	c:RegisterEffect(e3)
end
-- ①效果的发动条件：检测是否为自己在抽卡阶段的通常抽卡（ep==tp且r==REASON_RULE），即仅规则抽卡时触发。
function c20216608.drcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and r==REASON_RULE
end
-- ①效果的发动代价：将效果Label设为100作为已支付代价标记，返回true表示可以发动（实际无消耗）。
function c20216608.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
-- 过滤函数：筛选出非公开状态且可以返回卡组的卡（即刚抽到的那1张未公开手卡）。
function c20216608.tdfilter(c)
	return not c:IsPublic() and c:IsAbleToDeck()
end
-- ①效果的发动时选发处理：从抽到的卡中筛选可回卡组的非公开卡；满足条件时，若多于1张则选择1张给对方确认，随后洗切手卡、将选择的卡设为对象，并登记回卡组底和抽1张的操作信息。
function c20216608.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tg=eg:Filter(c20216608.tdfilter,1,nil)
	-- 发动时点合法性检查：确认已支付代价（Label==100）、存在可回卡组的非公开手卡，且自己可以抽1张卡。
	if chk==0 then return e:GetLabel()==100 and #tg>0 and Duel.IsPlayerCanDraw(tp,1) end
	e:SetLabel(0)
	local tc=tg:GetFirst()
	if #tg>1 then
		-- 显示选择提示，让玩家选择要展示给对方确认的那1张卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		tc=tg:Select(tp,1,1,nil):GetFirst()
	end
	-- 将选择的卡展示给对方玩家确认。
	Duel.ConfirmCards(1-tp,tc)
	-- 洗切自己的手卡，避免因展示卡而暴露手牌顺序。
	Duel.ShuffleHand(tp)
	-- 将选择的卡设为当前连锁的（广义）对象，供效果处理时关联。
	Duel.SetTargetCard(tc)
	-- 登记操作信息：对象卡将被返回卡组（实际为卡组最底端）。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,tc,1,0,0)
	-- 登记操作信息：自己将抽1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ①效果处理：获取目标卡，若目标卡仍与效果关联且成功返回卡组最底端并位于卡组中，则自己抽1张卡。
function c20216608.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中已关联的目标卡（即被确认并选择的那张手卡）。
	local tc=Duel.GetFirstTarget()
	-- 条件判断：目标卡仍与效果关联、成功送入卡组最底端（返回值>0）且目标卡仍在卡组中，才继续执行抽卡。
	if tc and tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_DECK) then
		-- 自己抽1张卡（作为效果处理的结果）。
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
-- ②效果的发动条件：检测是否为自己因效果抽卡（ep==tp且r==REASON_EFFECT）。
function c20216608.drcon2(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and r==REASON_EFFECT
end
-- ②效果的发动时选发处理：从抽到的卡中筛选可回卡组的非公开卡；满足条件时，选择1张给对方确认，洗切手卡、将该卡设为对象，并登记本卡送墓、目标卡回卡组底、自己抽1张的操作信息。
function c20216608.drtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local tg=eg:Filter(c20216608.tdfilter,1,nil)
	-- 发动时点合法性检查：确认已支付代价（Label==100）、本卡可送墓地、存在可回卡组的非公开手卡，且自己可以抽1张卡。
	if chk==0 then return e:GetLabel()==100 and c:IsAbleToGrave() and #tg>0 and Duel.IsPlayerCanDraw(tp,1) end
	e:SetLabel(0)
	local tc=tg:GetFirst()
	if #tg>1 then
		-- 显示选择提示，让玩家选择要展示给对方确认的那1张卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		tc=tg:Select(tp,1,1,nil):GetFirst()
	end
	-- 将选择的卡展示给对方玩家确认。
	Duel.ConfirmCards(1-tp,tc)
	-- 洗切自己的手卡，避免因展示卡而暴露手牌顺序。
	Duel.ShuffleHand(tp)
	-- 将选择的卡设为当前连锁的（广义）对象，供效果处理时关联。
	Duel.SetTargetCard(tc)
	-- 登记操作信息：本卡（这张卡）将被送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,c,1,0,0)
	-- 登记操作信息：对象卡将被返回卡组（实际为卡组最底端）。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,tc,1,0,0)
	-- 登记操作信息：自己将抽1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ②效果处理：先将本卡送去墓地，若本卡仍与效果关联且送墓成功并在墓地，则获取目标卡，若目标卡仍与效果关联且成功返回卡组最底端并位于卡组中，则自己抽1张卡。
function c20216608.drop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若本卡已与效果失去联系、送墓失败或不在墓地，则中止本次处理。
	if not c:IsRelateToEffect(e) or Duel.SendtoGrave(c,REASON_EFFECT)<=0 or not c:IsLocation(LOCATION_GRAVE) then return end
	-- 获取当前连锁中已关联的目标卡（即被确认并选择的那张手卡）。
	local tc=Duel.GetFirstTarget()
	-- 条件判断：目标卡仍与效果关联、成功送入卡组最底端（返回值>0）且目标卡仍在卡组中，才继续执行抽卡。
	if tc and tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_DECK) then
		-- 自己抽1张卡（作为效果处理的结果）。
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
