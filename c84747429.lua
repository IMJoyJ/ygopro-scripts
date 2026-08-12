--エアジャチ
-- 效果：
-- 1回合1次，可以从手卡把1只鱼族·海龙族·水族怪兽从游戏中除外，选择对方场上表侧表示存在的1张卡破坏。那之后，这张卡直到下次的自己的准备阶段时从游戏中除外。
local s,id,o=GetID()
-- 注册该卡在场上发动的起动效果，包含破坏和除外分类，取对象，1回合1次
function c84747429.initial_effect(c)
	-- 1回合1次，可以从手卡把1只鱼族·海龙族·水族怪兽从游戏中除外，选择对方场上表侧表示存在的1张卡破坏。那之后，这张卡直到下次的自己的准备阶段时从游戏中除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(84747429,0))  --"破坏"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c84747429.descost)
	e1:SetTarget(c84747429.destg)
	e1:SetOperation(c84747429.desop)
	c:RegisterEffect(e1)
end
-- 过滤手牌中可以作为除外代价的鱼族、海龙族或水族怪兽
function c84747429.cfilter(c)
	return c:IsRace(RACE_FISH+RACE_SEASERPENT+RACE_AQUA) and c:IsAbleToRemoveAsCost()
end
-- 效果发动的代价处理：检查并从手卡将1只鱼族·海龙族·水族怪兽表侧表示除外
function c84747429.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查手牌中是否存在满足条件的可以除外的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c84747429.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从手牌选择1张满足条件的鱼族·海龙族·水族怪兽
	local g=Duel.SelectMatchingCard(tp,c84747429.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选择的卡片作为发动代价表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤场上表侧表示的卡片
function c84747429.filter(c)
	return c:IsFaceup()
end
-- 效果的目标选择处理：选择对方场上表侧表示存在的1张卡作为对象，并设置破坏的操作信息
function c84747429.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c84747429.filter(chkc) end
	-- 在发动阶段检查对方场上是否存在表侧表示的卡
	if chk==0 then return Duel.IsExistingTarget(c84747429.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择对方场上表侧表示存在的1张卡作为效果对象
	local g=Duel.SelectTarget(tp,c84747429.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置当前连锁的处理信息为破坏选中的卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果运行处理：破坏选中的对象，若破坏成功，则将自身暂时除外，并注册一个在下次自己准备阶段将自身返回场上的效果
function c84747429.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选为对象的卡片
	local tc=Duel.GetFirstTarget()
	-- 若对象卡片仍表侧表示存在且该卡与此效果有关联，则将其破坏；若破坏成功且自身仍与此效果有关联，则继续处理
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 and c:IsRelateToEffect(e) then
		-- 中断当前效果处理，使后续的除外处理不与破坏同时进行
		Duel.BreakEffect()
		-- 将自身暂时除外，若除外成功且该卡未改变卡号，则继续处理
		if Duel.Remove(c,0,REASON_EFFECT+REASON_TEMPORARY)~=0 and c:GetOriginalCode()==id then
			-- 那之后，这张卡直到下次的自己的准备阶段时从游戏中除外。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
			e1:SetCountLimit(1)
			e1:SetLabelObject(c)
			e1:SetCondition(c84747429.retcon)
			e1:SetOperation(c84747429.retop)
			e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN)
			-- 将用于自身返回场上的延迟效果注册给玩家
			Duel.RegisterEffect(e1,tp)
		end
	end
end
-- 判断当前回合玩家是否为自己，作为返回场上效果的触发条件
function c84747429.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 将暂时除外的自身返回到场上
function c84747429.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将作为标签对象保存的自身卡片返回到场上
	Duel.ReturnToField(e:GetLabelObject())
end
