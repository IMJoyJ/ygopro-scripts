--アルケミック・マジシャン
-- 效果：
-- 魔法师族4星怪兽×3
-- 这张卡的攻击力上升自己墓地的魔法卡数量×200的数值。此外，自己的结束阶段时1次，把这张卡1个超量素材取除，把1张手卡送去墓地才能发动。从卡组选1张魔法卡，在自己的魔法与陷阱卡区域盖放。
function c65301952.initial_effect(c)
	-- 添加XYZ召唤手续：魔法师族4星怪兽×3
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_SPELLCASTER),4,3)
	c:EnableReviveLimit()
	-- 这张卡的攻击力上升自己墓地的魔法卡数量×200的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(c65301952.atkval)
	c:RegisterEffect(e1)
	-- 此外，自己的结束阶段时1次，把这张卡1个超量素材取除，把1张手卡送去墓地才能发动。从卡组选1张魔法卡，在自己的魔法与陷阱卡区域盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(65301952,0))  --"盖放魔法卡"
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c65301952.setcon)
	e2:SetCost(c65301952.setcost)
	e2:SetTarget(c65301952.settg)
	e2:SetOperation(c65301952.setop)
	c:RegisterEffect(e2)
end
-- 计算攻击力上升数值的辅助函数
function c65301952.atkval(e,c)
	-- 获取自己墓地的魔法卡数量并乘以200
	return Duel.GetMatchingGroupCount(Card.IsType,c:GetControler(),LOCATION_GRAVE,0,nil,TYPE_SPELL)*200
end
-- 效果发动条件判断函数
function c65301952.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 效果发动代价（Cost）处理函数
function c65301952.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST)
		-- 检查手牌中是否存在可以送去墓地的卡
		and Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从手牌中选择1张卡送去墓地
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的卡作为代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤卡组中可以盖放的非场地魔法卡
function c65301952.filter(c)
	return c:IsType(TYPE_SPELL) and not c:IsType(TYPE_FIELD) and c:IsSSetable()
end
-- 效果发动目标（Target）检查函数
function c65301952.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的魔法与陷阱区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查卡组中是否存在可以盖放的魔法卡
		and Duel.IsExistingMatchingCard(c65301952.filter,tp,LOCATION_DECK,0,1,nil) end
end
-- 效果处理（Operation）函数
function c65301952.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 若魔法与陷阱区域没有空位则不处理
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从卡组中选择1张满足条件的魔法卡
	local g=Duel.SelectMatchingCard(tp,c65301952.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的魔法卡在自己的魔法与陷阱区域盖放
		Duel.SSet(tp,g:GetFirst())
	end
end
