--大地震
-- 效果：
-- 自己场上存在的恐龙族怪兽被破坏送去墓地时才能发动。从对方场上的魔法与陷阱卡区域指定3处。指定的魔法·陷阱卡区域不能使用。这个时候有卡存在的地方不能指定。这张卡发动后第3次的自己准备阶段时破坏。因这个效果破坏的场合，可以使自己墓地的1只恐龙族怪兽回到手卡。
function c79569173.initial_effect(c)
	-- 自己场上存在的恐龙族怪兽被破坏送去墓地时才能发动。从对方场上的魔法与陷阱卡区域指定3处。指定的魔法·陷阱卡区域不能使用。这个时候有卡存在的地方不能指定。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c79569173.condition)
	e1:SetTarget(c79569173.target)
	e1:SetOperation(c79569173.activate)
	c:RegisterEffect(e1)
	-- 因这个效果破坏的场合，可以使自己墓地的1只恐龙族怪兽回到手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(79569173,0))  --"返回手牌"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CUSTOM+79569173)
	e2:SetTarget(c79569173.thtg)
	e2:SetOperation(c79569173.thop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上被破坏并送去墓地的恐龙族怪兽
function c79569173.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousControler(tp)
		and c:IsReason(REASON_DESTROY) and c:IsRace(RACE_DINOSAUR)
end
-- 检查是否有满足条件的怪兽被破坏送去墓地
function c79569173.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c79569173.cfilter,1,nil,tp)
end
-- 效果发动时的对象选择与准备阶段破坏效果的注册
function c79569173.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否有3个及以上未被占用的魔法与陷阱区域
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_SZONE,PLAYER_NONE,0)>2 end
	local c=e:GetHandler()
	c:SetTurnCounter(0)
	-- 这张卡发动后第3次的自己准备阶段时破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(c79569173.descon)
	e1:SetOperation(c79569173.desop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
	-- 让玩家选择对方魔法与陷阱卡区域的3个空格子
	local dis=Duel.SelectDisableField(tp,3,0,LOCATION_SZONE,0)
	e:SetLabel(dis)
	-- 向玩家提示所选择的区域
	Duel.Hint(HINT_ZONE,tp,dis)
end
-- 效果处理：使指定的魔法与陷阱卡区域不能使用
function c79569173.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方场上可用的魔法与陷阱区域是否少于3个，若是则不处理
	if Duel.GetLocationCount(1-tp,LOCATION_SZONE,PLAYER_NONE,0)<3 then return end
	local zone=e:GetLabel()
	if tp==1 then
		zone=((zone&0xffff)<<16)|((zone>>16)&0xffff)
	end
	-- 指定的魔法·陷阱卡区域不能使用。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCode(EFFECT_DISABLE_FIELD)
	e1:SetValue(zone)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e:GetHandler():RegisterEffect(e1)
end
-- 检查当前是否为自己的回合
function c79569173.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己
	return tp==Duel.GetTurnPlayer()
end
-- 累计回合数，并在第3次自己准备阶段时将这张卡破坏并触发后续效果
function c79569173.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetTurnCounter()
	ct=ct+1
	c:SetTurnCounter(ct)
	-- 如果是第3次准备阶段且成功将这张卡破坏
	if ct==3 and Duel.Destroy(c,REASON_EFFECT)>0 then
		-- 触发自定义事件，用于发动墓地恐龙族怪兽回收的效果
		Duel.RaiseSingleEvent(e:GetHandler(),EVENT_CUSTOM+79569173,e,0,tp,tp,0)
	end
end
-- 过滤条件：墓地的恐龙族怪兽且能加入手卡
function c79569173.thfilter(c)
	return c:IsRace(RACE_DINOSAUR) and c:IsAbleToHand()
end
-- 墓地恐龙族怪兽回收效果的对象选择与操作信息设置
function c79569173.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c79569173.thfilter(chkc) end
	-- 检查自己墓地是否存在可以加入手卡的恐龙族怪兽
	if chk==0 then return Duel.IsExistingTarget(c79569173.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要返回手卡的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择自己墓地1只恐龙族怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c79569173.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息为将选中的卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 墓地恐龙族怪兽回收效果的处理
function c79569173.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标怪兽加入手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 让对方确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,tc)
	end
end
