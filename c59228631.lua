--ホーリーナイツ・アステル
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1只光属性怪兽为对象才能发动。那只怪兽解放，从手卡把1只龙族·光属性·7星怪兽特殊召唤。这个效果在对方回合也能发动。
-- ②：把墓地的这张卡除外，以自己场上1只龙族·光属性·7星怪兽为对象才能发动。那只怪兽的攻击力直到对方回合结束时上升1000。
function c59228631.initial_effect(c)
	-- ①：以自己场上1只光属性怪兽为对象才能发动。那只怪兽解放，从手卡把1只龙族·光属性·7星怪兽特殊召唤。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(59228631,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,59228631)
	e1:SetTarget(c59228631.sptg)
	e1:SetOperation(c59228631.spop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己场上1只龙族·光属性·7星怪兽为对象才能发动。那只怪兽的攻击力直到对方回合结束时上升1000。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(59228631,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,59228632)
	-- 将墓地的这张卡除外作为发动效果的代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c59228631.atktg)
	e2:SetOperation(c59228631.atkop)
	c:RegisterEffect(e2)
end
-- 过滤自己场上表侧表示、可被效果解放且解放后有可用怪兽区域的光属性怪兽
function c59228631.releasefilter(c,tp)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT)
		-- 判定卡片是否能被效果解放，且该卡解放后能腾出可用的怪兽区域
		and c:IsReleasableByEffect() and Duel.GetMZoneCount(tp,c)>0
end
-- 过滤手卡中可以特殊召唤的7星·龙族·光属性怪兽
function c59228631.spfilter(c,e,tp)
	return c:IsLevel(7) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_DRAGON)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备与合法性检测（选择要解放的怪兽作为对象，并确认手卡有可特召的怪兽）
function c59228631.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c59228631.releasefilter(chkc,tp) end
	-- 在发动阶段，检测自己场上是否存在可作为解放对象的光属性怪兽
	if chk==0 then return Duel.IsExistingTarget(c59228631.releasefilter,tp,LOCATION_MZONE,0,1,nil,tp)
		-- 同时检测手卡中是否存在可特殊召唤的7星·龙族·光属性怪兽
		and Duel.IsExistingMatchingCard(c59228631.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 提示玩家选择要解放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 选择自己场上1只满足条件的光属性怪兽作为对象
	local g=Duel.SelectTarget(tp,c59228631.releasefilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 设置效果处理信息：包含解放对象怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,g,1,0,0)
	-- 设置效果处理信息：从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果①的效果处理（解放对象怪兽，并从手卡特殊召唤7星·龙族·光属性怪兽）
function c59228631.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为解放对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍适用此效果，则将其因效果解放，并确认是否解放成功
	if tc and tc:IsRelateToEffect(e) and Duel.Release(tc,REASON_EFFECT)~=0
		-- 确认自己场上是否有可用的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手卡选择1只满足条件的7星·龙族·光属性怪兽
		local g=Duel.SelectMatchingCard(tp,c59228631.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的怪兽以表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 过滤自己场上表侧表示的7星·龙族·光属性怪兽
function c59228631.atkfilter(c)
	return c:IsFaceup() and c:IsLevel(7) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_DRAGON)
end
-- 效果②的发动准备与合法性检测（选择自己场上1只7星·龙族·光属性怪兽作为对象）
function c59228631.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c59228631.atkfilter(chkc) end
	-- 在发动阶段，检测自己场上是否存在可作为对象的7星·龙族·光属性怪兽
	if chk==0 then return Duel.IsExistingTarget(c59228631.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只满足条件的7星·龙族·光属性怪兽作为对象
	Duel.SelectTarget(tp,c59228631.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果②的效果处理（使作为对象的怪兽攻击力上升1000直到对方回合结束）
function c59228631.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为攻击力上升对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽的攻击力直到对方回合结束时上升1000。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		tc:RegisterEffect(e1)
	end
end
