--転生炎獣ファルコ
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡被送去墓地的场合，以自己墓地1张「转生炎兽」魔法·陷阱卡为对象才能发动。那张卡在自己场上盖放。
-- ②：这张卡在墓地存在的场合，以「转生炎兽 猎鹰」以外的自己场上1只「转生炎兽」怪兽为对象才能发动。那只怪兽回到持有者手卡，这张卡从墓地特殊召唤。
function c20618081.initial_effect(c)
	-- ①：这张卡被送去墓地的场合，以自己墓地1张「转生炎兽」魔法·陷阱卡为对象才能发动。那张卡在自己场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20618081,0))
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,20618081)
	e1:SetTarget(c20618081.settg)
	e1:SetOperation(c20618081.setop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，以「转生炎兽 猎鹰」以外的自己场上1只「转生炎兽」怪兽为对象才能发动。那只怪兽回到持有者手卡，这张卡从墓地特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(20618081,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,20618081)
	e2:SetTarget(c20618081.sptg)
	e2:SetOperation(c20618081.spop)
	c:RegisterEffect(e2)
end
-- 检索满足条件的「转生炎兽」魔法·陷阱卡（可盖放）
function c20618081.filter(c)
	return c:IsSetCard(0x119) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- 设置效果处理时的选卡目标为满足条件的墓地魔法·陷阱卡
function c20618081.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c20618081.filter(chkc) end
	-- 判断是否满足发动条件：场上是否存在满足条件的墓地魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c20618081.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 选择满足条件的墓地魔法·陷阱卡作为对象
	local g=Duel.SelectTarget(tp,c20618081.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：将该卡从墓地离开
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 处理效果的发动后操作：将选中的卡在场上盖放
function c20618081.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选中的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡在场上盖放
		Duel.SSet(tp,tc)
	end
end
-- 筛选满足条件的「转生炎兽」怪兽（非猎鹰，可回手）
function c20618081.thfilter(c,tp)
	-- 筛选条件：场上正面表示的「转生炎兽」怪兽，且不是猎鹰，且可送入手牌，且有可用怪兽区
	return c:IsFaceup() and c:IsSetCard(0x119) and not c:IsCode(20618081) and c:IsAbleToHand() and Duel.GetMZoneCount(tp,c)
end
-- 设置效果处理时的选卡目标为满足条件的场上怪兽
function c20618081.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c20618081.thfilter(chkc,tp) end
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 判断是否满足发动条件：场上是否存在满足条件的场上怪兽
		and Duel.IsExistingTarget(c20618081.thfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择满足条件的场上怪兽作为对象
	local g=Duel.SelectTarget(tp,c20618081.thfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 设置操作信息：将该怪兽送入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 设置操作信息：将此卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 处理效果的发动后操作：将选中的怪兽送入手牌，并将此卡特殊召唤
function c20618081.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选中的目标卡
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否有效且成功送入手牌，且此卡是否有效
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) and c:IsRelateToEffect(e) then
		-- 将此卡以正面表示形式特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
