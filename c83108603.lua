--陽炎柱
-- 效果：
-- 只要这张卡在场上存在，自己可以把名字带有「阳炎兽」的怪兽召唤的场合需要的解放减少1只。此外，1回合1次，选择自己场上1只超量怪兽才能发动。把自己的手卡·场上1只名字带有「阳炎兽」的怪兽在选择的超量怪兽下面重叠作为超量素材。
function c83108603.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上存在，自己可以把名字带有「阳炎兽」的怪兽召唤的场合需要的解放减少1只。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DECREASE_TRIBUTE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_HAND,0)
	-- 设置减少解放效果的对象为名字带有「阳炎兽」的怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x107d))
	e2:SetValue(0x1)
	c:RegisterEffect(e2)
	-- 1回合1次，选择自己场上1只超量怪兽才能发动。把自己的手卡·场上1只名字带有「阳炎兽」的怪兽在选择的超量怪兽下面重叠作为超量素材。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(83108603,0))  --"增加素材"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetTarget(c83108603.mattg)
	e3:SetOperation(c83108603.matop)
	c:RegisterEffect(e3)
end
-- 过滤自己场上表侧表示的超量怪兽，且手卡或场上存在可作为其超量素材的「阳炎兽」怪兽
function c83108603.xyzfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
		-- 检查手卡或场上是否存在至少1张不等于该超量怪兽、且满足素材过滤条件的卡
		and Duel.IsExistingMatchingCard(c83108603.matfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,c)
end
-- 过滤手卡或场上表侧表示的、可以作为超量素材的名字带有「阳炎兽」的怪兽
function c83108603.matfilter(c,e)
	return (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsSetCard(0x107d) and c:IsType(TYPE_MONSTER) and c:IsCanOverlay() and not (e and c:IsImmuneToEffect(e))
end
-- 效果发动的目标选择与合法性检查（Target阶段）
function c83108603.mattg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c83108603.xyzfilter(chkc,tp) end
	-- 在发动效果时，检查自己场上是否存在符合条件的超量怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(c83108603.xyzfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 给玩家发送提示信息：请选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的超量怪兽作为效果对象
	Duel.SelectTarget(tp,c83108603.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
end
-- 效果处理的执行逻辑（Operation阶段）
function c83108603.matop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在Target阶段选择的超量怪兽对象
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		-- 给玩家发送提示信息：请选择要作为超量素材的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
		-- 让玩家从手卡或场上选择1只满足条件的「阳炎兽」怪兽
		local g=Duel.SelectMatchingCard(tp,c83108603.matfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,1,tc,e)
		if g:GetCount()>0 then
			local mg=g:GetFirst():GetOverlayGroup()
			if mg:GetCount()>0 then
				-- 若被选为素材的怪兽自身带有超量素材，则根据规则将这些素材送去墓地
				Duel.SendtoGrave(mg,REASON_RULE)
			end
			-- 将选择的「阳炎兽」怪兽重叠在目标超量怪兽下面作为超量素材
			Duel.Overlay(tc,g)
		end
	end
end
