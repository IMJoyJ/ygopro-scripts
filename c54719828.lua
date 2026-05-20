--No.16 色の支配者ショック・ルーラー
-- 效果：
-- 4星怪兽×3
-- ①：1回合1次，把这张卡1个超量素材取除，宣言卡的种类（怪兽·魔法·陷阱）才能发动。直到对方回合结束时，宣言的种类的卡双方不能发动。
function c54719828.initial_effect(c)
	-- 设置XYZ召唤手续：4星怪兽×3
	aux.AddXyzProcedure(c,nil,4,3)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除，宣言卡的种类（怪兽·魔法·陷阱）才能发动。直到对方回合结束时，宣言的种类的卡双方不能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(54719828,0))  --"发动限制"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c54719828.cost)
	e1:SetTarget(c54719828.target)
	e1:SetOperation(c54719828.operation)
	c:RegisterEffect(e1)
end
-- 设置这张卡的「No.」编号为16
aux.xyz_number[54719828]=16
-- 检查并取除这张卡的1个超量素材作为发动的代价
function c54719828.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果发动的目标处理：让玩家宣言卡片种类并记录
function c54719828.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 提示玩家选择一个卡片种类
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)  --"请选择一个种类"
	-- 让玩家宣言一个卡片种类（怪兽·魔法·陷阱），并将宣言结果记录在Label中
	e:SetLabel(Duel.AnnounceType(tp))
end
-- 效果运行的处理：在全局注册一个直到对方回合结束时使双方不能发动宣言种类卡片的效果
function c54719828.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 直到对方回合结束时，宣言的种类的卡双方不能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,1)
	if e:GetLabel()==0 then
		e1:SetDescription(aux.Stringid(54719828,2))  --"「No.16 色之支配者」宣言怪兽卡"
		e1:SetValue(c54719828.aclimit1)
	elseif e:GetLabel()==1 then
		e1:SetDescription(aux.Stringid(54719828,3))  --"「No.16 色之支配者」宣言魔法卡"
		e1:SetValue(c54719828.aclimit2)
	else
		e1:SetDescription(aux.Stringid(54719828,4))  --"「No.16 色之支配者」宣言陷阱卡"
		e1:SetValue(c54719828.aclimit3)
	end
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,1)
	-- 将限制发动的效果注册给全局环境
	Duel.RegisterEffect(e1,tp)
end
-- 限制怪兽效果发动的过滤函数
function c54719828.aclimit1(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER)
end
-- 限制魔法卡发动的过滤函数
function c54719828.aclimit2(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL)
end
-- 限制陷阱卡发动的过滤函数
function c54719828.aclimit3(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_TRAP)
end
