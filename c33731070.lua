--暗黒界の尖兵 ベージ
-- 效果：
-- ①：这张卡被效果从手卡丢弃去墓地的场合发动。这张卡特殊召唤。
function c33731070.initial_effect(c)
	-- ①：这张卡被效果从手卡丢弃去墓地的场合发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(33731070,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c33731070.spcon)
	e1:SetTarget(c33731070.sptg)
	e1:SetOperation(c33731070.spop)
	c:RegisterEffect(e1)
end
-- 判断触发条件：该卡在送去墓地之前位于手牌，且本次送去墓地的原因包含“效果丢弃”（即同时带有效果与丢弃的标记）。
function c33731070.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND) and bit.band(r,0x4040)==0x4040
end
-- 目标函数：当chk==0时返回true表示允许发动，并登记特殊召唤的操作信息；此效果不取对象。
function c33731070.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：声明本次连锁处理将把这张卡自身特殊召唤，数量为1，供其他卡进行效果发动检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理函数：处理时先确认这张卡仍然与效果有关联（未因中途离场等原因失去联系），若有关联则执行特殊召唤。
function c33731070.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 实际特殊召唤：将这张卡以表侧表示特殊召唤到当前效果发动者的场上（无特殊召唤类型，且按常规检查召唤条件/苏生限制）。
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
