--オーバーレイ・イーター
-- 效果：
-- 自己的主要阶段时，把墓地的这张卡从游戏中除外才能发动。把对方场上1个超量素材在自己场上的超量怪兽下面重叠作为超量素材。
function c81816475.initial_effect(c)
	-- 自己的主要阶段时，把墓地的这张卡从游戏中除外才能发动。把对方场上1个超量素材在自己场上的超量怪兽下面重叠作为超量素材。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(81816475,0))  --"素材夺取"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	-- 设置发动代价为将墓地的这张卡除外
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(c81816475.target)
	e1:SetOperation(c81816475.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：表侧表示的超量怪兽
function c81816475.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- 效果发动的目标检查：对方场上存在超量素材，且自己场上存在表侧表示的超量怪兽
function c81816475.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在超量素材
	if chk==0 then return Duel.GetOverlayCount(tp,0,1)~=0
		-- 并且自己场上存在至少1只表侧表示的超量怪兽
		and Duel.IsExistingMatchingCard(c81816475.filter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 效果处理：选择对方场上的1个超量素材重叠在自己场上的1只超量怪兽下面，并触发素材被取除的时点
function c81816475.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有的超量素材
	local g1=Duel.GetOverlayGroup(tp,0,1)
	-- 获取自己场上所有表侧表示的超量怪兽
	local g2=Duel.GetMatchingGroup(c81816475.filter,tp,LOCATION_MZONE,0,nil)
	if g1:GetCount()==0 or g2:GetCount()==0 then return end
	-- 提示玩家选择要转移的超量素材
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(81816475,2))  --"请选择要转移的素材"
	local mg=g1:Select(tp,1,1,nil)
	-- 提示玩家选择自己场上的一只超量怪兽
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(81816475,1))  --"请选择一只超量怪兽"
	local tc=g2:Select(tp,1,1,nil):GetFirst()
	local oc=mg:GetFirst():GetOverlayTarget()
	-- 将选中的超量素材重叠在选中的自己超量怪兽下面
	Duel.Overlay(tc,mg)
	-- 为失去素材的怪兽触发“去除超量素材”的单体时点
	Duel.RaiseSingleEvent(oc,EVENT_DETACH_MATERIAL,e,0,0,0,0)
	-- 触发“去除超量素材”的全局时点
	Duel.RaiseEvent(oc,EVENT_DETACH_MATERIAL,e,0,0,0,0)
end
