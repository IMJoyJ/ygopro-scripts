--エクシーズ・エージェント
-- 效果：
-- 这张卡在墓地存在的场合，自己的主要阶段时选择自己场上1只名字带有「希望皇 霍普」的超量怪兽才能发动。把墓地的这张卡在选择的怪兽下面重叠作为超量素材。「超量谍报士」的效果在决斗中只能使用1次。
function c72502414.initial_effect(c)
	-- 这张卡在墓地存在的场合，自己的主要阶段时选择自己场上1只名字带有「希望皇 霍普」的超量怪兽才能发动。把墓地的这张卡在选择的怪兽下面重叠作为超量素材。「超量谍报士」的效果在决斗中只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(72502414,0))  --"素材补充"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,72502414+EFFECT_COUNT_CODE_DUEL)
	e1:SetTarget(c72502414.target)
	e1:SetOperation(c72502414.operation)
	c:RegisterEffect(e1)
end
-- 过滤出自己场上表侧表示的名字带有「希望皇 霍普」的超量怪兽
function c72502414.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x107f) and c:IsType(TYPE_XYZ)
end
-- 效果发动的目标选择与合法性检测，判断场上是否存在符合条件的「希望皇 霍普」超量怪兽，且自身是否能作为超量素材
function c72502414.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c72502414.filter(chkc) end
	-- 在发动效果时，检测自己场上是否存在可以作为效果对象的表侧表示「希望皇 霍普」超量怪兽
	if chk==0 then return Duel.IsExistingTarget(c72502414.filter,tp,LOCATION_MZONE,0,1,nil)
		and e:GetHandler():IsCanOverlay() end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只表侧表示的「希望皇 霍普」超量怪兽作为效果对象
	Duel.SelectTarget(tp,c72502414.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果处理信息，表示此效果包含“卡片离开墓地”的操作，涉及卡片为自身
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 效果处理，若自身与目标怪兽均在场/墓地且状态合法，则将自身重叠在目标怪兽下方作为超量素材
function c72502414.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) and c:IsCanOverlay() then
		-- 将自身重叠在目标怪兽下面作为超量素材
		Duel.Overlay(tc,Group.FromCards(c))
	end
end
