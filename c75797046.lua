--フォトン・アレキサンドラ・クィーン
-- 效果：
-- 名字带有「幻蝶刺客」的4星怪兽×2
-- 把这张卡1个超量素材取除才能发动。场上的怪兽全部回到持有者手卡。那之后，这个效果让卡加入手卡的玩家受到那个数量×300的数值的伤害。
function c75797046.initial_effect(c)
	-- 设置XYZ召唤手续：名字带有「幻蝶刺客」的4星怪兽×2
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x6a),4,2)
	c:EnableReviveLimit()
	-- 把这张卡1个超量素材取除才能发动。场上的怪兽全部回到持有者手卡。那之后，这个效果让卡加入手卡的玩家受到那个数量×300的数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(75797046,0))  --"返回手卡"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c75797046.retcost)
	e1:SetTarget(c75797046.rettg)
	e1:SetOperation(c75797046.retop)
	c:RegisterEffect(e1)
end
-- 检查并执行发动代价：把这张卡1个超量素材取除
function c75797046.retcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果发动的目标确认与操作信息设置
function c75797046.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在至少1只可以回到手卡的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取场上所有可以回到手卡的怪兽
	local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置将场上所有可回手卡的怪兽送回手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
	-- 设置给与双方玩家伤害的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,0)
end
-- 过滤函数：检查卡片是否在指定玩家的手卡中
function c75797046.hfilter(c,tp)
	return c:IsLocation(LOCATION_HAND) and c:IsControler(tp)
end
-- 效果处理：将场上怪兽全部送回手卡，并根据加入手卡的卡片数量给与双方玩家伤害
function c75797046.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有可以回到手卡的怪兽
	local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()==0 then return end
	-- 将这些怪兽全部送回持有者的手卡
	Duel.SendtoHand(g,nil,REASON_EFFECT)
	local ct1=g:FilterCount(c75797046.hfilter,nil,tp)
	local ct2=g:FilterCount(c75797046.hfilter,nil,1-tp)
	if ct1==0 and ct2==0 then return end
	-- 中断当前效果，使之后的效果处理视为不同时处理
	Duel.BreakEffect()
	-- 给与回合玩家其加入手卡的卡片数量×300的伤害（分步处理）
	Duel.Damage(tp,ct1*300,REASON_EFFECT,true)
	-- 给与对手玩家其加入手卡的卡片数量×300的伤害（分步处理）
	Duel.Damage(1-tp,ct2*300,REASON_EFFECT,true)
	-- 完成伤害处理并触发相关时点
	Duel.RDComplete()
end
