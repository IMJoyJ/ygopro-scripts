--E・HERO フラッシュ
-- 效果：
-- 这张卡被战斗破坏送去墓地时，可以从自己墓地把这张卡和名字带有「元素英雄」的怪兽卡3种类从游戏中除外，选择自己墓地存在的1张通常魔法卡加入手卡。
function c69572169.initial_effect(c)
	-- 这张卡被战斗破坏送去墓地时，可以从自己墓地把这张卡和名字带有「元素英雄」的怪兽卡3种类从游戏中除外，选择自己墓地存在的1张通常魔法卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(69572169,0))  --"魔法回收"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c69572169.condition)
	e1:SetCost(c69572169.cost)
	e1:SetTarget(c69572169.target)
	e1:SetOperation(c69572169.operation)
	c:RegisterEffect(e1)
end
-- 判断发动条件：这张卡是否被战斗破坏并送去墓地
function c69572169.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 过滤条件：自己墓地中名字带有「元素英雄」的怪兽且可以作为代价除外
function c69572169.rfilter(c)
	return c:IsSetCard(0x3008) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 发动代价：从自己墓地把这张卡和3种名字带有「元素英雄」的怪兽除外
function c69572169.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己墓地中除这张卡以外的所有符合条件的「元素英雄」怪兽组
	local rg=Duel.GetMatchingGroup(c69572169.rfilter,tp,LOCATION_GRAVE,0,e:GetHandler())
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() and rg:GetClassCount(Card.GetCode)>=3 end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从符合条件的怪兽中筛选出3张卡名不同的卡
	local g=rg:SelectSubGroup(tp,aux.dncheck,false,3,3)
	g:AddCard(e:GetHandler())
	-- 将选中的怪兽（包含这张卡本身）正面表示除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤条件：自己墓地中可以加入手牌的魔法卡
function c69572169.filter(c)
	return c:GetType()==TYPE_SPELL and c:IsAbleToHand()
end
-- 效果目标：选择自己墓地存在的1张魔法卡作为对象
function c69572169.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c69572169.filter(chkc) end
	-- 检查自己墓地是否存在可以成为效果对象的魔法卡
	if chk==0 then return Duel.IsExistingTarget(c69572169.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择并确定自己墓地的1张魔法卡作为效果对象
	local g=Duel.SelectTarget(tp,c69572169.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息：将目标卡片加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果处理：将选择的魔法卡加入手牌并给对方确认
function c69572169.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的第一个效果对象
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标卡片加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,tc)
	end
end
