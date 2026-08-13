--エルシャドール・アノマリリス
-- 效果：
-- 「影依」怪兽＋水属性怪兽
-- 这张卡用融合召唤才能从额外卡组特殊召唤。
-- ①：只要这张卡在怪兽区域存在，双方不能用魔法·陷阱卡的效果从手卡·墓地把怪兽特殊召唤。
-- ②：这张卡被送去墓地的场合，以自己墓地1张「影依」魔法·陷阱卡为对象才能发动。那张卡加入手卡。
function c19261966.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡注册影依融合召唤手续：设定其融合素材为「影依」怪兽＋水属性怪兽。
	aux.AddFusionProcShaddoll(c,ATTRIBUTE_WATER)
	-- 这张卡用融合召唤才能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetValue(c19261966.splimit)
	c:RegisterEffect(e2)
	-- ①：只要这张卡在怪兽区域存在，双方不能用魔法·陷阱卡的效果从手卡·墓地把怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,1)
	e3:SetTarget(c19261966.sumlimit)
	c:RegisterEffect(e3)
	-- ②：这张卡被送去墓地的场合，以自己墓地1张「影依」魔法·陷阱卡为对象才能发动。那张卡加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(19261966,0))  --"加入手卡"
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e4:SetTarget(c19261966.thtg)
	e4:SetOperation(c19261966.thop)
	c:RegisterEffect(e4)
end
-- 特殊召唤条件判定：仅当本次特殊召唤的召唤类型为融合召唤（SUMMON_TYPE_FUSION）时，才允许这张卡从额外卡组特殊召唤。
function c19261966.splimit(e,se,sp,st)
	return bit.band(st,SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
end
-- 禁止特殊召唤判定：若发动特殊召唤的效果来源为魔法·陷阱卡（且属于会实际进行特殊召唤的效果类型），并且要特殊召唤的怪兽位于手卡或墓地，则这个特殊召唤行为被禁止。
function c19261966.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return se:IsActiveType(TYPE_SPELL+TYPE_TRAP) and se:IsHasType(EFFECT_TYPE_ACTIONS)
		and c:IsLocation(LOCATION_GRAVE+LOCATION_HAND) and c:IsType(TYPE_MONSTER)
end
-- 检索条件：筛选自己墓地中满足「影依」字段、类型为魔法或陷阱卡、并且可以加入手卡的卡。
function c19261966.thfilter(c)
	return c:IsSetCard(0x9d) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- ②效果的发动时点与对象选择：检查是否存在合法对象，并让玩家从自己墓地选择1张符合条件的「影依」魔法·陷阱卡作为效果对象。
function c19261966.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c19261966.thfilter(chkc) end
	-- 发动条件判定：检查自己墓地是否存在至少1张满足条件的「影依」魔法·陷阱卡，作为效果能否发动的依据。
	if chk==0 then return Duel.IsExistingTarget(c19261966.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手卡的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己墓地选择1张符合条件的「影依」魔法·陷阱卡作为效果对象，并将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c19261966.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息，声明本效果处理的类别为加入手卡，处理对象为已选择的1张卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理时：获取对象卡，若其仍与效果存在关联，则将其加入手卡。
function c19261966.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因将对象卡加入其持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
