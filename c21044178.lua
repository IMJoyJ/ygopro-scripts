--深淵に潜む者
-- 效果：
-- 4星怪兽×2
-- ①：这张卡有水属性怪兽在作为超量素材的场合，自己场上的水属性怪兽的攻击力上升500。
-- ②：自己·对方回合1次，把这张卡1个超量素材取除才能发动。这个回合，对方不能把墓地的卡的效果发动。
function c21044178.initial_effect(c)
	-- 为这张卡添加超量召唤手续：4星怪兽×2叠放（4星怪兽2只才能超量召唤）。
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- ①：这张卡有水属性怪兽在作为超量素材的场合，自己场上的水属性怪兽的攻击力上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCondition(c21044178.atkcon)
	-- 设置效果对象：选择自己场上表侧表示的水属性怪兽作为攻击力提升的适用对象。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsAttribute,ATTRIBUTE_WATER))
	e1:SetValue(500)
	c:RegisterEffect(e1)
	-- ②：自己·对方回合1次，把这张卡1个超量素材取除才能发动。这个回合，对方不能把墓地的卡的效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21044178,0))  --"效果发动限制"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_DRAW_PHASE)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c21044178.cost)
	e2:SetTarget(c21044178.target)
	e2:SetOperation(c21044178.operation)
	c:RegisterEffect(e2)
end
-- 效果①的适用条件：这张卡持有的超量素材中存在水属性怪兽时，攻击力上升效果才适用。
function c21044178.atkcon(e)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_WATER)
end
-- 效果②的发动代价：从这张卡上取除1个超量素材作为cost；先检查能否取除，实际发动时执行取除。
function c21044178.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果②的发动合法性目标函数：确认自己本回合尚未发动过同名效果（通过标识判断），若没有则允许发动。
function c21044178.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时点检查玩家tp的21044178标识数量为0，即本回合该效果还未发动过，满足发动条件。
	if chk==0 then return Duel.GetFlagEffect(tp,21044178)==0 end
end
-- 效果②的发动处理：在对方场上生成一个禁止从墓地发动效果的永续效果，并给自己设置已发动标识，持续到回合结束。
function c21044178.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 这个回合，对方不能把墓地的卡的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(0,1)
	e1:SetValue(c21044178.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将新建的禁止对方从墓地发动卡效果的永续效果注册到场上，使其正式生效。
	Duel.RegisterEffect(e1,tp)
	-- 给玩家tp注册一个标识效果，记录本回合已经使用过②效果，用于防止同回合重复发动。
	Duel.RegisterFlagEffect(tp,21044178,RESET_PHASE+PHASE_END,0,0)
end
-- 禁止发动效果的判定条件：若对方发动的效果的发动位置是墓地，则禁止该效果发动。
function c21044178.aclimit(e,re,tp)
	return re:GetActivateLocation()==LOCATION_GRAVE
end
