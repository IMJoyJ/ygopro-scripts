--クロノダイバー・フライバック
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：以自己场上1只「时间潜行者」超量怪兽为对象才能发动。从手卡·卡组选1张「时间潜行者」卡在作为对象的怪兽下面重叠作为超量素材。
-- ②：把墓地的这张卡除外，以自己场上1只「时间潜行者」超量怪兽为对象才能发动。从对方墓地选1张卡在作为对象的怪兽下面重叠作为超量素材。
function c18678554.initial_effect(c)
	-- ①：以自己场上1只「时间潜行者」超量怪兽为对象才能发动。从手卡·卡组选1张「时间潜行者」卡在作为对象的怪兽下面重叠作为超量素材。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(18678554,0))  --"自己的卡作为超量素材"
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,18678554)
	e1:SetTarget(c18678554.target)
	e1:SetOperation(c18678554.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己场上1只「时间潜行者」超量怪兽为对象才能发动。从对方墓地选1张卡在作为对象的怪兽下面重叠作为超量素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(18678554,1))  --"对方的卡作为超量素材"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,18678554)
	-- 将此卡除外作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c18678554.mattg)
	e2:SetOperation(c18678554.matop)
	c:RegisterEffect(e2)
end
-- 判断目标是否为表侧表示的超量怪兽且为时间潜行者卡组
function c18678554.xyzfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(0x126)
end
-- 判断卡是否为时间潜行者卡组且可以作为超量素材
function c18678554.matfilter(c)
	return c:IsSetCard(0x126) and c:IsCanOverlay()
end
-- 检查是否满足效果1的发动条件：自己场上存在时间潜行者超量怪兽，且自己手卡或卡组存在时间潜行者卡
function c18678554.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c18678554.xyzfilter(chkc) end
	-- 检查是否满足效果1的发动条件：自己场上存在时间潜行者超量怪兽
	if chk==0 then return Duel.IsExistingTarget(c18678554.xyzfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查是否满足效果1的发动条件：自己手卡或卡组存在时间潜行者卡
		and Duel.IsExistingMatchingCard(c18678554.matfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择满足条件的时间潜行者超量怪兽作为效果对象
	Duel.SelectTarget(tp,c18678554.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果1的处理流程：选择目标怪兽并将其作为超量素材
function c18678554.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		-- 提示玩家选择要作为超量素材的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
		-- 从手卡或卡组中选择一张时间潜行者卡作为超量素材
		local g=Duel.SelectMatchingCard(tp,c18678554.matfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,tc)
		if g:GetCount()>0 then
			-- 将选中的卡叠放在目标怪兽下面
			Duel.Overlay(tc,g)
		end
	end
end
-- 效果2的发动条件检查：自己场上存在时间潜行者超量怪兽，且对方墓地存在可作为超量素材的卡
function c18678554.mattg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c18678554.xyzfilter(chkc) end
	-- 检查是否满足效果2的发动条件：自己场上存在时间潜行者超量怪兽
	if chk==0 then return Duel.IsExistingTarget(c18678554.xyzfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查是否满足效果2的发动条件：对方墓地存在可作为超量素材的卡
		and Duel.IsExistingMatchingCard(Card.IsCanOverlay,tp,0,LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择满足条件的时间潜行者超量怪兽作为效果对象
	Duel.SelectTarget(tp,c18678554.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果2的处理流程：选择目标怪兽并将其作为超量素材
function c18678554.matop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		-- 提示玩家选择要作为超量素材的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
		-- 获取对方墓地的所有卡
		local g=Duel.GetFieldGroup(tp,0,LOCATION_GRAVE)
		-- 检查是否因王家长眠之谷而无效该操作
		if aux.NecroValleyNegateCheck(g) then return end
		local tg=g:FilterSelect(tp,Card.IsCanOverlay,1,1,nil)
		if #tg>0 then
			-- 将选中的卡叠放在目标怪兽下面
			Duel.Overlay(tc,tg)
		end
	end
end
