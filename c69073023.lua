--無限起動要塞メガトンゲイル
-- 效果：
-- 超量怪兽3只
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡只要在怪兽区域存在，不受这张卡以及超量怪兽以外的怪兽的效果影响，不会被和超量怪兽以外的怪兽的战斗破坏。
-- ②：以自己墓地1只超量怪兽和对方场上1张卡为对象才能发动。那只墓地的超量怪兽特殊召唤，那张对方的卡在下面重叠作为超量素材。这个效果的发动后，直到回合结束时对方受到的全部伤害变成一半。
function c69073023.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置连接召唤手续：用3只超量怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_XYZ),3,3)
	-- ①：这张卡只要在怪兽区域存在，不受这张卡以及超量怪兽以外的怪兽的效果影响
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetValue(c69073023.immunefilter)
	c:RegisterEffect(e1)
	-- 不会被和超量怪兽以外的怪兽的战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(c69073023.indes)
	c:RegisterEffect(e2)
	-- ②：以自己墓地1只超量怪兽和对方场上1张卡为对象才能发动。那只墓地的超量怪兽特殊召唤，那张对方的卡在下面重叠作为超量素材。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(69073023,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,69073023)
	e3:SetTarget(c69073023.sptg)
	e3:SetOperation(c69073023.spop)
	c:RegisterEffect(e3)
end
-- 过滤不受影响的效果：除自身以及超量怪兽以外的怪兽发动的效果
function c69073023.immunefilter(e,te)
	return te:IsActiveType(TYPE_MONSTER) and te:GetOwner()~=e:GetOwner() and not te:GetHandler():IsType(TYPE_XYZ)
end
-- 过滤不会被战斗破坏的怪兽：超量怪兽以外的怪兽
function c69073023.indes(e,c)
	return not c:IsType(TYPE_XYZ)
end
-- 过滤自己墓地中可以特殊召唤的超量怪兽
function c69073023.spfilter(c,e,tp)
	return c:IsType(TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备与对象选择判定
function c69073023.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 判定自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判定自己墓地是否存在可以特殊召唤的超量怪兽
		and Duel.IsExistingTarget(c69073023.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 判定对方场上是否存在可以作为超量素材的卡
		and Duel.IsExistingTarget(Card.IsCanOverlay,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只超量怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c69073023.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	e:SetLabelObject(g:GetFirst())
	-- 提示玩家选择要作为超量素材的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 选择对方场上1张卡作为效果对象
	Duel.SelectTarget(tp,Card.IsCanOverlay,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②的实际处理：特殊召唤墓地的超量怪兽，将对方场上的卡叠放为其素材，并使对方受到的伤害减半
function c69073023.spop(e,tp,eg,ep,ev,re,r,rp)
	local hc=e:GetLabelObject()
	-- 获取当前连锁中被选择为对象的所有卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc=g:GetFirst()
	if tc==hc then tc=g:GetNext() end
	-- 若作为对象的超量怪兽仍符合条件，则将其在自己场上表侧表示特殊召唤
	if hc:IsRelateToEffect(e) and Duel.SpecialSummon(hc,0,tp,tp,false,false,POS_FACEUP)>0 then
		if tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) and tc:IsControler(1-tp) and tc:IsCanOverlay() then
			local og=tc:GetOverlayGroup()
			if og:GetCount()>0 then
				-- 将作为超量素材的卡片原本拥有的超量素材送去墓地
				Duel.SendtoGrave(og,REASON_RULE)
			end
			tc:CancelToGrave()
			-- 将作为对象的对方场上的卡重叠在特殊召唤的怪兽下面作为超量素材
			Duel.Overlay(hc,tc)
		end
	end
	-- 这个效果的发动后，直到回合结束时对方受到的全部伤害变成一半。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetValue(c69073023.damval)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册该回合内对方受到的伤害减半的全局效果
	Duel.RegisterEffect(e1,tp)
end
-- 伤害减半的计算函数，返回原始伤害值的一半（向下取整）
function c69073023.damval(e,re,val,r,rp,rc)
	return math.floor(val/2)
end
