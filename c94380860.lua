--No.103 神葬零嬢ラグナ・ゼロ
-- 效果：
-- 4星怪兽×2
-- ①：自己·对方回合1次，把这张卡1个超量素材取除，以持有和原本攻击力不同攻击力的对方场上1只攻击表示怪兽为对象才能发动。那只怪兽破坏，自己抽1张。
function c94380860.initial_effect(c)
	-- 添加XYZ召唤手续：4星怪兽×2
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- ①：自己·对方回合1次，把这张卡1个超量素材取除，以持有和原本攻击力不同攻击力的对方场上1只攻击表示怪兽为对象才能发动。那只怪兽破坏，自己抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(94380860,0))  --"破坏抽卡"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c94380860.cost)
	e1:SetTarget(c94380860.target)
	e1:SetOperation(c94380860.operation)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	c:RegisterEffect(e1)
end
-- 设置该卡片的No.编号为103
aux.xyz_number[94380860]=103
-- 代价处理：把这张卡1个超量素材取除
function c94380860.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤条件：持有和原本攻击力不同攻击力的表侧攻击表示怪兽
function c94380860.filter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and not c:IsAttack(c:GetBaseAttack())
end
-- 靶向/目标选择：检查发动条件，并选择符合条件的对象
function c94380860.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c94380860.filter(chkc) end
	-- 检查自己是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 检查对方场上是否存在符合条件的对象怪兽
		and Duel.IsExistingTarget(c94380860.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只符合条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c94380860.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：破坏选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息：自己抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理：破坏对象怪兽并抽卡
function c94380860.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍对该效果有效，则将其破坏
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 破坏成功时，自己抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
