--エクシーズ・ギフト
-- 效果：
-- ①：自己场上有超量怪兽2只以上存在的场合才能发动。自己场上2个超量素材取除，自己从卡组抽2张。
function c72355441.initial_effect(c)
	-- ①：自己场上有超量怪兽2只以上存在的场合才能发动。自己场上2个超量素材取除，自己从卡组抽2张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c72355441.condition)
	e1:SetTarget(c72355441.target)
	e1:SetOperation(c72355441.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：是否为表侧表示的超量怪兽
function c72355441.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- 发动条件：自己场上有超量怪兽2只以上存在
function c72355441.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在2只以上的表侧表示超量怪兽
	return Duel.IsExistingMatchingCard(c72355441.cfilter,tp,LOCATION_MZONE,0,2,nil)
end
-- 发动时的合法性检测与操作信息设置
function c72355441.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自身是否能抽2张卡，且自己场上是否有2个以上的超量素材可供取除
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) and Duel.CheckRemoveOverlayCard(tp,1,0,2,REASON_EFFECT) end
	-- 设置效果分类为抽卡，数量为2张
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果运行空间，处理取除素材和抽卡
function c72355441.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 安全检查：若此时自己场上可取除的超量素材不足2个，则效果不适用
	if not Duel.CheckRemoveOverlayCard(tp,1,0,2,REASON_EFFECT) then return end
	-- 取除自己场上的2个超量素材
	Duel.RemoveOverlayCard(tp,1,0,2,2,REASON_EFFECT)
	-- 自己从卡组抽2张卡
	Duel.Draw(tp,2,REASON_EFFECT)
end
