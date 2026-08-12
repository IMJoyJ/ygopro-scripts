--劫火の翼竜 ゴースト・ワイバーン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1张「幽合-幽鬼融合」加入手卡。
-- ②：这张卡被除外的回合的结束阶段才能发动。从卡组选1只2星以下的不死族调整加入手卡或送去墓地。
function c61103515.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1张「幽合-幽鬼融合」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(61103515,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,61103515)
	e1:SetTarget(c61103515.thtg)
	e1:SetOperation(c61103515.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡被除外的
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_REMOVE)
	e3:SetOperation(c61103515.regop)
	c:RegisterEffect(e3)
	-- ②：这张卡被除外的回合的结束阶段才能发动。从卡组选1只2星以下的不死族调整加入手卡或送去墓地。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(61103515,1))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_REMOVED)
	e4:SetCountLimit(1,61103516)
	e4:SetCondition(c61103515.sumcon)
	e4:SetTarget(c61103515.sumtg)
	e4:SetOperation(c61103515.sumop)
	c:RegisterEffect(e4)
end
-- 过滤卡组中卡名为「幽合-幽鬼融合」且可以加入手牌的卡片
function c61103515.thfilter(c)
	return c:IsCode(35705817) and c:IsAbleToHand()
end
-- 效果①的发动准备与效果分类设置
function c61103515.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以加入手牌的「幽合-幽鬼融合」
	if chk==0 then return Duel.IsExistingMatchingCard(c61103515.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置当前连锁的操作信息为：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理：从卡组将「幽合-幽鬼融合」加入手牌
function c61103515.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足过滤条件的卡片
	local g=Duel.SelectMatchingCard(tp,c61103515.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 在这张卡被除外时，给自身注册一个在回合结束阶段前有效的标记
function c61103515.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(61103515,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 检查自身是否带有被除外回合的标记，作为效果②的发动条件
function c61103515.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(61103515)>0
end
-- 过滤卡组中等级2以下的不死族调整，且可以加入手牌或送去墓地的卡片
function c61103515.thcheck(c)
	return c:IsLevelBelow(2) and c:IsRace(RACE_ZOMBIE) and c:IsType(TYPE_TUNER) and (c:IsAbleToHand() or c:IsAbleToGrave())
end
-- 效果②的发动准备
function c61103515.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查卡组中是否存在满足条件的2星以下不死族调整
	if chk==0 then return Duel.IsExistingMatchingCard(c61103515.thcheck,tp,LOCATION_DECK,0,1,nil) end
end
-- 效果②的效果处理：从卡组选1只满足条件的怪兽加入手牌或送去墓地
function c61103515.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要操作的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从卡组中选择1张满足过滤条件的卡片
	local g=Duel.SelectMatchingCard(tp,c61103515.thcheck,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()<=0 then return end
	local tc=g:GetFirst()
	-- 判断该卡是否能加入手牌，若不能送去墓地或玩家选择加入手牌，则执行加入手牌分支
	if tc:IsAbleToHand() and (not tc:IsAbleToGrave() or Duel.SelectOption(tp,1190,1191)==0) then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的怪兽
		Duel.ConfirmCards(1-tp,tc)
	else
		-- 将选中的怪兽送去墓地
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end
