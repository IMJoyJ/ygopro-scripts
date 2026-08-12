--ウィッチクラフト・サボタージュ
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：以自己墓地1只「魔女术」怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：这张卡在墓地存在，自己场上有「魔女术」怪兽存在的场合，自己结束阶段才能发动。这张卡加入手卡。
function c83301414.initial_effect(c)
	-- ①：以自己墓地1只「魔女术」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,83301414)
	e1:SetTarget(c83301414.target)
	e1:SetOperation(c83301414.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，自己场上有「魔女术」怪兽存在的场合，自己结束阶段才能发动。这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(83301414,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1,83301414)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c83301414.thcon)
	e2:SetTarget(c83301414.thtg)
	e2:SetOperation(c83301414.thop)
	c:RegisterEffect(e2)
end
-- 过滤自己墓地中可以特殊召唤的「魔女术」怪兽
function c83301414.filter(c,e,tp)
	return c:IsSetCard(0x128) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动准备与对象选择判定
function c83301414.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc,exc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c83301414.filter(chkc,e,tp) end
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在可以特殊召唤的「魔女术」怪兽
		and Duel.IsExistingTarget(c83301414.filter,tp,LOCATION_GRAVE,0,1,exc,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只「魔女术」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c83301414.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息为特殊召唤选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果的实际处理：特殊召唤作为对象的怪兽
function c83301414.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤自己场上表侧表示的「魔女术」怪兽
function c83301414.rccfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x128)
end
-- ②效果的发动条件判定：自己回合的结束阶段且自己场上有「魔女术」怪兽存在
function c83301414.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为自己的回合
	return Duel.GetTurnPlayer()==tp
		-- 检查自己场上是否存在表侧表示的「魔女术」怪兽
		and Duel.IsExistingMatchingCard(c83301414.rccfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ②效果的发动准备：检查自身是否能加入手卡并设置操作信息
function c83301414.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置效果处理信息为将墓地的这张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- ②效果的实际处理：将这张卡加入手卡
function c83301414.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡通过效果加入手卡
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
