--マジェスペクター・サイクロン
-- 效果：
-- ①：把自己场上1只魔法师族·风属性怪兽解放，以对方场上1只怪兽为对象才能发动。那只怪兽破坏。
function c49366157.initial_effect(c)
	-- ①：把自己场上1只魔法师族·风属性怪兽解放，以对方场上1只怪兽为对象才能发动。那只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCost(c49366157.cost)
	e1:SetTarget(c49366157.target)
	e1:SetOperation(c49366157.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：判断怪兽是否为魔法师族且风属性，用于选择可解放的素材。
function c49366157.cfilter(c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_WIND)
end
-- 代价函数：发动时从自己场上选择并解放1只魔法师族·风属性怪兽作为COST。
function c49366157.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检查：确认自己场上是否存在至少1只可解放的魔法师族·风属性怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c49366157.cfilter,1,nil) end
	-- 选择代价素材：从自己场上选择1只魔法师族·风属性怪兽用于解放。
	local g=Duel.SelectReleaseGroup(tp,c49366157.cfilter,1,1,nil)
	-- 解放所选择的怪兽，作为效果的发动代价。
	Duel.Release(g,REASON_COST)
end
-- 目标函数：让玩家选择对方场上1只怪兽作为对象，并设置本次操作的破坏信息。
function c49366157.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 发动检查：确认对方场上是否存在至少1只可作为对象的怪兽。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 弹出选择提示，提示玩家选择要破坏的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从对方场上的怪兽中选择1只作为效果对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息，标记本次处理将破坏1张卡，以便触发相关时点和检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：取得对象怪兽，若对象仍与效果关联则将其破坏。
function c49366157.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取出效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以效果原因破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
