--No.44 白天馬スカイ・ペガサス
-- 效果：
-- 4星怪兽×2
-- ①：1回合1次，把这张卡1个超量素材取除，以对方场上1只表侧表示怪兽为对象才能发动。对方可以支付1000基本分让这个效果无效。没支付的场合，作为对象的怪兽破坏。
function c80764541.initial_effect(c)
	-- 设置XYZ召唤手续：4星怪兽×2
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除，以对方场上1只表侧表示怪兽为对象才能发动。对方可以支付1000基本分让这个效果无效。没支付的场合，作为对象的怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetDescription(aux.Stringid(80764541,0))  --"破坏"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c80764541.descost)
	e1:SetTarget(c80764541.destg)
	e1:SetOperation(c80764541.desop)
	c:RegisterEffect(e1)
end
-- 设置该卡片的「No.」编号为44
aux.xyz_number[80764541]=44
-- 效果发动的代价：取除这张卡的1个超量素材
function c80764541.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤条件：表侧表示的怪兽
function c80764541.filter(c)
	return c:IsFaceup()
end
-- 效果发动的目标：选择对方场上1只表侧表示怪兽为对象
function c80764541.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c80764541.filter(chkc) end
	-- 检查对方场上是否存在可以作为对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c80764541.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只表侧表示怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c80764541.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 检查对方玩家的基本分是否大于1000
	if Duel.GetLP(1-tp)>1000 then
		-- 设置效果处理的操作信息为破坏选中的怪兽
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	end
end
-- 效果处理：对方可以选择支付1000基本分使效果无效，否则破坏对象怪兽
function c80764541.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前效果是否可以被无效，且对方玩家是否能够支付1000基本分
	if Duel.IsChainDisablable(0) and Duel.CheckLPCost(1-tp,1000)
		-- 询问对方玩家是否选择支付1000基本分来无效该效果
		and Duel.SelectYesNo(1-tp,aux.Stringid(80764541,1)) then  --"是否要支付1000基本分无效「No.44 白天马」的效果？"
		-- 对方玩家支付1000基本分
		Duel.PayLPCost(1-tp,1000)
		-- 使当前连锁的效果无效
		Duel.NegateEffect(0)
		return
	end
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果将作为对象的怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
